clear
close all
clc
%% Store training signals
% Stores the signals in a "structure" named Training. For example, to look
% up the PCG from the 5th subject of the training registry B:
%
% PCG = Training.b{5,1};
%
% The sampling frequency for the same subject is:
%
% Fs = Training.b{5,2};
%
% The third column corresponds to the annotations:
%
% Ann = Training.b{5,3};
%
% These annotations represent whether it is a normal signal (value -1) 
% or an abnormal signal (value 1).
%
% In the fourth column the different states of the cardiac cycle are stored
% (S1, systole, S2, dyastole)
%
% States = Training.b{5,4};
%
% To find the samples of a signal during S1 or S2 state:
%
% S1 = find(States==1);
% S2 = find(States==3);
% 
% To plot the PCG with S1 and S2
%
% tf = 1/Fs*length(PCG); % Tiempo final [seg]
% t =  linspace(0,tf,length(PCG)); % [seg]
% plot(t,PCG,'b',t(S1),PCG(S1)*0,'r.',t(S2),PCG(S2)*0,'y.')
%
%
% The script does NOT store the files automatically in the PC
%% Initial data
Num_Registros = [409,490,31,55,2141,114]; % # of registers a,b,c,d,e y f
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
% Options to obtain S1 and S2
springer_options   = default_Springer_HSMM_options; 
load('Springer_B_matrix.mat');
load('Springer_pi_vector.mat');
load('Springer_total_obs_distribution.mat');
%
tic
for m=1:length(Num_Registros)      % Loop in folders a-f
    cd(Carpeta_Registros(m))    % Enter a folder
    clear Ann;
    Ann = readtable('REFERENCE.csv'); % Annotations normal-anormal
    Ann = table2array(Ann(:,2));
    addpath(fileparts(pwd));
    %
    for n=1:Num_Registros(m)  % Loop in the number of records in each folder a-f
        % 
        Num = num2str(n);   % Generate the name of the file of each record
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
        File = join([Nombre_Registros(m),Num,'.wav'],'');   % File name
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
    
    cd('..')                    % Exit de folder
    
end