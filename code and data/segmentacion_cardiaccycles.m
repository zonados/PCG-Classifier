%% Funcion para segmentar senales en intervalos una cantidad de ciclos cardiacos
% (Function to segment signals in some specific number of cardiac cycles)
%
% Inputs:
%
% - x = signal to be segmented
% - cycles = number of cycles (for example 2, 5 or 8)
% - States = S1, Sistole, S2 Diastole
% 
% Output:
% 
% - signals = cell with signals segmented with the data provided
%
% Example:
%
%
% clear
% close all
% clc
% load('TestData2.mat')
% x = Test2{1};
% cycles = 5;
% States = Test2{2};
%%
function signals = segmentacion_cardiaccycles(x,cycles,States)
%
signals = {};
States2.S1 = find(States==1);            % Samples dnd se encuentra S1
States2.Sis = find(States==2);           % Samples dnd se encuentra Sistole
States2.S2 = find(States==3);            % Samples dnd se encuentra S2
States2.Dia = find(States==4);           % Samples dnd se encuentra Diastole
fn_states = fieldnames(States2);
%
s = States(States~=0);                   % Sometimes, some States start with 0
s = s(1);                                % 1 = S1, 2 = Sis, 3 = S2, 4 = Dia
%
run = 1;
k = 0;                                   % Counter
num_signals = 0;                         % Number of saved signals
num_cycle = 0;                           % Number of cycles so far
tini = States2.(fn_states{s})(1);        % Inicial value
tref = 1;
while run
    s_next = s + 1;
    if s_next > 4                        % There are only 4 states S1, Sis, S2, Dia 
        s_next = 1;
    end
    k = k + 1;
    if k == 4                            % If k = 4, then i did a complete cycle
        num_cycle = num_cycle + 1;
        k = 0;
    end
    %
    vals = States2.(fn_states{s_next})( find(States2.(fn_states{s_next}) > tref , 1) );
    if not(isempty(vals))
        tfin = vals - 1;
    else
        run = 0;
        tfin = States2.(fn_states{s})(end);
    end
    %
    if num_cycle == cycles               % If number of cycles reached, save signal
        num_signals = num_signals + 1;
        signals{end+1} = x(tini:tfin);
        num_cycle = 0;    
        tini = tfin + 1;
    end
    %
    s = s_next;
    tref = tfin + 1; 
end