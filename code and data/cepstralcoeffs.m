%% Funcion para obtener los coeficientes cepstrales de Mel
% Esta funcion sigue un ejemplo de mathworks, ubicado en:
% https://la.mathworks.com/help/audio/ref/cepstralcoefficients.html
%
function melcc = cepstralcoeffs(x,windowLength,overlapLength,Fs,normalice)
%
%
S = stft(x',"Window",hann(windowLength,"periodic"),"OverlapLength",overlapLength,"Centered",false);
melcc = mfcc(S,Fs,NumCoeffs=12);
if normalice == 1
    melcc = zscore(melcc,0,1);
end

