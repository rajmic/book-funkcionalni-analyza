clear
clc
close all

% nacteme data
load('sinusproj.mat')
% signal ... casovy prubeh
% fs ....... vzorkovaci frekvence (Hz)
% ft ....... puvodni frekvence (Hz)
time = (0:length(signal)-1)/fs;

% zkraceni
signal = signal(1:round(0.02*fs));
time = time(1:round(0.02*fs));
signal = signal/max(abs(signal));

% prevod casu na ms
time = 1000*time;

% vykreslime
figure
plot(time, signal, 'r', 'displayname', 'pozorovaný signál')
xlabel('čas (ms)', 'interpreter', 'none')

% spocitame projekci
sinusoid = exp(2i*pi*ft*(0:length(signal)-1)'/fs);
X = [real(sinusoid), imag(sinusoid)];
projection = X*((X'*X)\(X'*signal));

% vykreslime generatory
hold on
plot(time, real(sinusoid), 'g', 'displayname', 'generátor x')
plot(time, imag(sinusoid), 'b', 'displayname', 'generátor y')

% vykreslime projekci
plot(time, projection, 'k', 'displayname', 'projekce')

% legenda
legend('interpreter', 'none')
set(gca,'TickLabelInterpreter', 'none')