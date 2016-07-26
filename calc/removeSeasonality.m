function [deSeasonedData] = removeSeasonality(sig)

%% Assumed monthly data

Nt = length(sig);

% Get frequency in cycles / year
freq = [0:1/Nt:1-1/Nt] * 12; 

% Get discrete fourier transform
F0 = fft(sig,Nt);
F=F0;

seasonalFreq = [1 2 10 11];
for i = 1:length(seasonalFreq)
    ind=find(freq==seasonalFreq(i));
    F(ind)=0;
end

% plot(freq,abs(F),freq,abs(F0));
% keyboard

deSeasonedData=(ifft(F,Nt,1)); %,'symmetric'));
end

