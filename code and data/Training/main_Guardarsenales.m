clear
close all
clc
%% Guarda las senales de entrenamiento
% Guarda las señales en una estructura llamada Training. Para buscar por
% ejemplo el PCG de los registros de entrenamiento b para el sujeto 5:
%
% PCG = Training.b{5,1};
%
% La frecuencia de muestreo para el mismo sujeto es:
%
% Fs = Training.b{5,2};
%
% En la tercera columna se encuentran anotaciones. Es decir:
%
% Ann = Training.b{5,3};
%
% Estas anotaciones representan si es una senal normal (valor -1) o anormal
% (valor 1)
%
% En la cuarta columna se encuentran los rangos de S1, sistole, S2,
% diastole:
%
% States = Training.b{5,4};
%
% Si se quiere obtener los índices donde esta S1 o S2, basta con poner:
%
% S1 = find(States==1);
% S2 = find(States==3);
% 
% Si se quisiera graficar el PCG con S1 y S2:
%
% tf = 1/Fs*length(PCG); % Tiempo final [seg]
% t =  linspace(0,tf,length(PCG)); % [seg]
% plot(t,PCG,'b',t(S1),PCG(S1)*0,'r.',t(S2),PCG(S2)*0,'y.')
%
%
% El archivo NO se guarda automaticamente en la PC. Hay que guardarlo manualmente
% (esto para evitar que se borre por error uno previamente guardado)
%% Datos iniciales
Num_Registros = [409,490,31,55,2141,114]; % # de registros en a,b,c,d,e y f
Nombre_Registros = ['a','b','c','d','e','f'];
Carpeta_Registros = ["training-a","training-b","training-c",...
    "training-d","training-e","training-f"];
Training.a = cell(Num_Registros(1),4);
Training.b = cell(Num_Registros(2),4);
Training.c = cell(Num_Registros(3),4);
Training.d = cell(Num_Registros(4),4);
Training.e = cell(Num_Registros(5),4);
Training.f = cell(Num_Registros(6),4);
fn = fieldnames(Training);
%
% Cargar opciones que se usan para obtener S1 y S2.
springer_options   = default_Springer_HSMM_options; 
load('Springer_B_matrix.mat');
load('Springer_pi_vector.mat');
load('Springer_total_obs_distribution.mat');
%
tic
for m=1:length(Num_Registros)      % Loop en las carpetas a-f
    cd(Carpeta_Registros(m))    % Entrar en una carpeta
    clear Ann;
    Ann = readtable('REFERENCE.csv'); % Anotaciones normal-anormal
    Ann = table2array(Ann(:,2));
    addpath(fileparts(pwd));
    %
    for n=1:Num_Registros(m)   % Loop en el # de registros de cada carpeta a-f
        % 
        Num = num2str(n);   % Generar el nombre del archivo de cada registro
        if length(Num)==1
            Num = join(['000',Num],'');
        end
        if length(Num)==2
            Num = join(['00',Num],'');
        end
        if length(Num)==3
            Num = join(['0',Num],'');
        end
        %
        if Nombre_Registros(m) == 'e'
            Num = join(['0',Num],'');
        end
        %
        File = join([Nombre_Registros(m),Num,'.wav'],'');   % Nombre archivo
        %
        [PCG, Fs1] = audioread(File);  % cargar data
        % resample to springer_options.audio_Fs (2000 Hz):
        PCG_resampled = resample(PCG,springer_options.audio_Fs,Fs1);
        % obtain the locations for S1, systole, S2 and diastole
        [assigned_states] = runSpringerSegmentationAlgorithm(PCG_resampled,...
            springer_options.audio_Fs, Springer_B_matrix, Springer_pi_vector,...
            Springer_total_obs_distribution, false); 
        %
        %
        Training.(fn{m}){n,1} = PCG_resampled;
        Training.(fn{m}){n,2} = springer_options.audio_Fs;
        Training.(fn{m}){n,3} = Ann(n,1);
        Training.(fn{m}){n,4} = assigned_states;
        %
        fprintf('Registro: %s , Tiempo : %.3f segundos \n',...
            join([Nombre_Registros(m),Num],''),toc)
    end
    
    cd('..')                    % Salir de la carpeta
    
end