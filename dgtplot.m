clear
clc
close all

% vykreslení spektrogramů používá funkci sgram toolboxu LTFAT
% (https://ltfat.org/)

% glockenspiel
[glock, fs] = audioread('glockenspiel.wav');

% hudba (http://small.inria.fr/software-data/smallbox/index.html)
% =========================================================================
% LICENSE
% 
% License: Creative Commons Attribution-NonCommercial 2.5
% Please read: http://creativecommons.org/licenses/by-nc/2.5/
% 
% 
% CREDITS
% 
% "Remember the name" by Fort Minor, Warner Bros. Records and Machine Shop 
% Recordings; URL: http://www.myspace.com/fortminor
% 
% Remix is done by Michel Desnoues from Telecom ParisTech
% =========================================================================
[druhysignal, druhyfs] = audioread('music.wav');

% vykresleni glockenspiel
figure
sgram(glock, fs, 'dynrange', 80)

% vykresleni hudby
figure
sgram(druhysignal, druhyfs, 'dynrange', 60)