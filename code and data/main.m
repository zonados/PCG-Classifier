clear
close all
clc
%
mmax = 6;   % Numero de lotes de registros a usar (si 1, solo a, si 2 a y b, etc)
layertype = 1;
%
%% Carga de valores y datos iniciales
load('Training_all_2000Hz.mat');
Num_Registros = [409,490,31,55,2141,114]; % Registros en a,b,c,d,e y f respectiva
fn = fieldnames(Training);             % Nombres de objetos en Training (a,b, etc)
%
% Datos de segmentacion
cycles = 5;                 % Número de ciclos cardiacos por señal
Fs = Training.(fn{1}){1,2}; 
%
% Datos ICEEMDAN
Nstd = 0.2;             % STD de ruido blanco
NR = 10;                % Numero de realizaciones
MaxIter = 100;          % Numero maximo de iteraciones
SNRFlag = 1;            % Usar modelo del ano 2014 en lugar del modelo de 2011
L = 7;
%
% Datos Coeficientes cepstrales de Mel
melwindow = 0.025;      % Ventanas [ms]
meloverlap = 0.01;      % Solapamiento [ms]
%
% Datos de entrenamiento
kfold = 10;     % Número de iteraciones para la validación cruzada
Epochs = 32;    % Número máximo de epochs al entrenar
L1 = 1;         % Primer modo
Lend = 9;       % Último modo hasta el que se irán incrementando los modos
Conftest = cell(Lend-L1+1+1,kfold);  % En las filas, se suma 1 para sea el número
                                 % de iteraciones entre L1 y L2 y se suma otro
                                 % 1 para contemplar el caso de todos los modos
                                 % señal completa).
Nettest =  cell(Lend-L1+1+1,kfold);  % Conf son las matrices de confusión, Net son
Infotest = cell(Lend-L1+1+1,kfold);  % las redes entrenadas, Info son los valores
                                 % de validación y entrenamiento obtenidos.
%
%% Segmentacion
disp('Segmentacion')
segmented_signals = {};
Annotations = [];
segments = zeros(sum(Num_Registros),4); % Primera columna m (a,b,c, etc)
                                   % Segunda columna n (numero registro)
                                     % Tercera columna Segmento inicial
                                        % Cuarta columna Segmento final
segments(1,3:4) = 1;                         
k = 0;      % Posicion dentro de las senales segmentadas
kk = 0;     % Contador
tic
for m = 1:mmax  
    for n = 1:Num_Registros(m)
        kk = kk + 1;
        x = Training.(fn{m}){n,1};              % Senal PCG
        x = detrend(x);
        x = hampel(x);
        x = medfilt1(x,10);
        %
        States = Training.(fn{m}){n,4};     % S1, sistole, S2, diastole
        % Segmentacion de senal
        signals = segmentacion_cardiaccycles(x,cycles,States)'; 
        if not(isempty(signals))
            sizevals = size(signals);
            %
            segmented_signals = [segmented_signals;signals];
            % Anotacion normal o anormal
            Ann = Training.(fn{m}){n,3} * ones(sizevals(1),1);      
            Annotations = [Annotations ; Ann];
            %
            segments(kk,1) = m;
            segments(kk,2) = n;
            segments(kk,3) = k + 1;
            k = k + sizevals(1);
            segments(kk,4) = k;       
            segments(kk,5) = kk;
        end
    end
        fprintf('Senal: %i , Tiempo : %.3f segundos , Total senales: %i \n',...
        kk,toc,sum(Num_Registros))
end
if kk<sum(Num_Registros)
    segments(kk+1:end,:) = [];
end
Annotations = string(Annotations);
Annotations = categorical(Annotations); 
%
%% Descomposicion en modos usando Iceemdan
disp('Descomposicion y reconstruccion usando Iceemdan:')
k = length(segmented_signals);
prepros_signals = cell(k,1);
modes_prepros = cell(k,1);
tic
for i = 1:k
    modes=ceemdan(segmented_signals{i},Nstd,NR,MaxIter,SNRFlag);
    modes_prepros{i} = modes;
    if size(modes,1) >= L % Si hay mas de L modos, solo sumar los primeros L
        prepros_signals{i} = sum(modes(1:L,:));
    else
        prepros_signals{i} = sum(modes(1:end,:));
    end
  fprintf('Senal: %i , Tiempo : %.3f segundos , Total senales: %i \n',i,toc,k)
end
%
%% Eliminar datos que requieren modificacion manual de los sonidos cardiacos
Ann = readtable('REFERENCE.csv'); % Anotaciones requieren correccion o no
Ann = table2array(Ann(:,2));
modes_prepros2 = {};
Annotations2 = [];
for i = 1:length(Ann)
    if Ann(i) == 0
        idx = segments(i,3):segments(i,4);
        modes_prepros2 = [modes_prepros2;modes_prepros(idx)];
        Annotations2 = [Annotations2 ; Annotations(idx)];
    end
end
Annotations2 = categorical(Annotations2); 
%% Modelo Deep Learning
if layertype==1
    filterSize = 5;
    numFilters = 32;
    layers = [ ...
        sequenceInputLayer(13)
        convolution1dLayer(filterSize,numFilters,Padding="causal")
        reluLayer
        layerNormalizationLayer
        convolution1dLayer(filterSize,2*numFilters,Padding="causal")
        reluLayer
        layerNormalizationLayer
        globalAveragePooling1dLayer
        bilstmLayer(10,"OutputMode","sequence")      
        fullyConnectedLayer(2)
        softmaxLayer
        classificationLayer];
end
%% Reconstruir señales con desde el modo L1 hasta el modo L2
cont = 0; % Contador
for L2 =L1:Lend+1
    cont = cont + 1;
    if L2 == Lend+1
        fprintf('Modos: %i - ultimo \n',L1)
    else
        fprintf('Modos: %i - %i \n',L1,L2)
    end
    [k,~] = size(modes_prepros2);
    prepros_signals2 = cell(k,1);
    tic
    for i = 1:k
        modes=modes_prepros2{i};
        if L2 == Lend+1 % Sumar todos los modos desde L1 siempre
            prepros_signals2{i} = sum(modes(L1:end,:));
        else
            if L2 == L1
                prepros_signals2{i} = modes(L1,:);
            elseif size(modes,1) >= L2 % Si hay mas de L modos, 
                                       % solo sumar los primeros L
                prepros_signals2{i} = sum(modes(L1:L2,:));
            else
                prepros_signals2{i} = sum(modes(L1:end,:));
            end
        end
    end
    fprintf('Reconstrucción, Tiempo : %.3f segundos \n',toc)
%% Coeficientes cepstrales de Mel
   k = length(prepros_signals2);
   windowLength = round(melwindow*Fs);
   overlapLength = round(meloverlap*Fs);
   %
   melcc = cell(k,1);
   tic
   for i = 1:k
        melcc{i} = cepstralcoeffs(prepros_signals2{i},windowLength,...
                overlapLength,Fs,1)';
   end
    fprintf('Coef de Mel, Tiempo : %.3f segundos \n',toc)
%% Train, testing and validation data
    % 90% de los datos para entrenamiento y validación, 10% para prueba
    %
    cvp = cvpartition(Annotations2,'HoldOut',0.1);    % 10% de los datos para
                                                      % pruebas
    melcctest = melcc(cvp.test(1));
    melcctrainval = melcc(cvp.training(1));
    Anntest = Annotations2(cvp.test(1));
    Anntrainval = Annotations2(cvp.training(1));
    %
    Anntest = categorical(double(Anntest));
%% Kfold
    cvp3 = cvpartition(Anntrainval, 'KFold', kfold);
    for fold=1:kfold
        melcctrain = melcctrainval(cvp3.training(fold));
        melccval = melcctrainval(cvp3.test(fold));
        Anntrain = Anntrainval(cvp3.training(fold));
        Annval = Anntrainval(cvp3.test(fold));
        Anntrain = categorical(double(Anntrain));
        Annval = categorical(double(Annval));
        %% Opciones de entrenamiento modelo
        miniBatchSize = 32;
        Initialrate = 0.002;
        LearnRateDropPeriod = 5;
        LearnRateDropFactor = 0.5;
        options = trainingOptions("adam", ...
            MiniBatchSize=miniBatchSize, ...
            MaxEpochs=Epochs, ...
            SequencePaddingDirection="left", ...
            ValidationData={melccval,Annval}, ...
            InitialLearnRate=Initialrate,...
            LearnRateSchedule='piecewise',...
            LearnRateDropPeriod=LearnRateDropPeriod,...
            LearnRateDropFactor=LearnRateDropFactor,...
            Verbose=0);
%% Entrenamiento modelo
        [net,info] = trainNetwork(melcctrain,Anntrain,layers,options);
%% Prueba modelo
        testPred = predict(net,melcctest);
        [~,Annpred] = max(testPred,[],2);
        Annpred = categorical(Annpred);
        C = confusionmat(Anntest,Annpred);
        tp = C(2,2);
        tn = C(1,1);
        fp = C(1,2);
        fn = C(2,1);
        %
        prec = tp ./ (tp + fp); % precision
        sen = tp ./ (tp + fn); % sensitivity, recall
        spc = tn ./ (tn + fp); % specificity
        acc = (tp+tn) ./ (tp + tn + fp + fn);
        F1  = (2 .* prec .* sen) ./ (prec + sen);
%% Guardar info
        Conftest{cont,fold} = C;
        Nettest{cont,fold}  = net;
        Infotest{cont,fold} = info;
      fprintf('Iteración validación cruzada %i, Tiempo : %.3f segundos \n',fold,toc)
    end
end

