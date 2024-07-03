close all
clc

% filtr FIR
% f = [-0.0456   -0.1703    0.0696    0.3094    0.4521    0.3094    0.0696   -0.1703   -0.0456];
windowSize = 9;
f = ones(1, windowSize)/windowSize;

%% Originál: směs harmonických
len = 0.1; % délka signálu v sekundách
Fs = 5000;

AmpFreqPhas = ...
    [1   50   .5;
    0.5  100   0;
    0.5  1000   1];
signal = generate_sin(len, AmpFreqPhas, Fs);

figure
tls = tiledlayout(2, 1);

nexttile
plot(signal)
title('Casovy prubeh')
xlabel('n')

YL = get(gca, 'YLim');
XL = get(gca, 'XLim');

spektrum = abs(fft(signal));
df = Fs/length(signal);

nexttile
plot(-Fs/2:df:Fs/2-df, fftshift(spektrum))
title('Modul spektra')
xlabel('frekvence (Hz)')
ylabel('modul')

title(tls, 'Puvodni signal')

%% Filtrovaný: směs harmonických
% signal_filt = filter(f, 1, signal);
ff = [f zeros(1, length(signal)-windowSize)]';
signal_filt = ifft(fft(signal) .* fft(ff));

figure
tls = tiledlayout(2, 1);

nexttile
plot(signal_filt)
title('Casovy prubeh')
xlabel('n')

set(gca, 'YLim', YL)
set(gca, 'XLim', XL)

ffilt = abs(fft(signal_filt));

nexttile
plot(-Fs/2:df:Fs/2-df, fftshift(ffilt))
title('Modul spektra')
xlabel('frekvence (Hz)')
ylabel('modul')

title(tls, 'Filtrovany signal')

%% Kmitočtová odezva filtru
figure
freqz(f, 1, [], Fs)

%% Funkce na generování sinusového signálu
function out = generate_sin(len, AmpFreqPhas, Fs, normalize)
% Generates one or more real sinusoids.
%
% len ................. length of the sinusoid in seconds 
%
% AmpFreqPhas(:, 1) ... amplitudes
% AmpFreqPhas(:, 2) ... frequencies (absolute in Hz)
% AmpFreqPhas(:, 3) ... phases (in radians)
%                       (so each harmonic is specified by a single row of 
%                       AmpFreqPhas)
%
% Fs .................. sampling frequency in Hz
%
% normalize ........... (optional) if 'true' normalize the output such that
%                       maximum absolute value is 1 (default is 'false')
%
% out ................. harmonics as columns of this output matrix
%
% Example:
%   generate_sin(0.5, [5 2500 -pi/4], 8000)
%
% (c) 2010-2013, Pavel Rajmic, Vaclav Mach, Brno University of Technology


%% check inputs
[m, n] = size(AmpFreqPhas);
if n ~= 3 
    error('')
end
if ~isscalar(Fs)
    error('')
end
if nargin == 3
    normalize = false;
end

%% prepare
t = 0:floor(Fs*len-1);
lt = length(t);
out = zeros(lt, 1);

%% genereate
for cnt = 1:m
    amp = AmpFreqPhas(cnt, 1);
    freq = AmpFreqPhas(cnt, 2);
    phase = AmpFreqPhas(cnt, 3);
    tmp = amp * sin(2*pi*freq*t/Fs + phase);
    out = out + tmp';
end

%% normalize
if normalize
    out = out/max(abs(out));
end

end