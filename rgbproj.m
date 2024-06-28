% Vykresli barvy RGB modelu jako body v 3D grafu (scatter plot) a ukaze totez pro barvy prevedene do stupnu sedi

% (c) 2022 Pavel Rajmic, Brno University of Technology

close all
clear param

%% vstupni parametry
% RGB vahy (museji dohromady dat jednicku)
% weights = [1 1 1]/3;   % prumerovani
weights = [.299 .587 0.114]
% weights = [.2126 .7152 .0722];  % HDTV, ITU-R BT.709-3

%% scatterplot celeho RGB modelu
% nalezeni vsech kombinaci = zaplneni cele krychle
% v = 0:31:255;
v = round(linspace(0, 255, 5));
C = uint8(nmultichoosek(v, 3));
C = [C; C(:, [1 3 2]); C(:, [3 1 2]); C(:, [3 2 1]); C(:, [2 3 1]); C(:, [2 1 3])]; % vsechny mozne kombinace trojic RGB
C = unique(C, 'rows');

image = uint8(zeros(size(C, 1), 1, 3)); % fiktivni jednosloupcovy RGB obrazek
image(:, 1, 1) = C(:, 1);
image(:, 1, 2) = C(:, 2);
image(:, 1, 3) = C(:, 3);

% vykresleni
param.quantization = 5;
scatter3d(image, param);  % plot scatter
title('Barvy v modelu RGB')
axis square
view(30.3944, 38.8085)

%% Prepocet do stupnu sedi
% Prepocet lze realizovat pomoci nasobeni matici, ale pre- a postprocessing je zbytecne zdlouhavy...
image_projected = zeros(size(image));
image_projected(:, :, 1) = weights(1)*image(:, :, 1) + weights(2)*image(:, :, 2) + weights(3)*image(:, :, 3); % kanal R
image_projected(:, :, 2) = image_projected(:, :, 1); % kopie do kanalu G
image_projected(:, :, 3) = image_projected(:, :, 1); % kopie do kanalu B
image_projected = uint8(image_projected);  % se zaokrouhlenim

%% Scatter prepocteneho
param.quantization = 1;
scatter3d(image_projected, param);  % plot scatter
title(['Stupne sedi z modelu RGB, vahy [' num2str(weights) ']'])
axis square

%% Dokresleni sipek
hold on
% prevod na double kvuli odecitani poli (aby mohlo byt zaporne)
image = double(image);
image_projected = double(image_projected);
% vykresleni vektoroveho pole
quiver3(...
    image(:, :, 1), ...
    image(:, :, 2), ...
    image(:, :, 3), ...
    image_projected(:, :, 1)-image(:, :, 1), ...
    image_projected(:, :, 2)-image(:, :, 2), ...
    image_projected(:, :, 3)-image(:, :, 3), 0, ...
    "-o");
view(30.3944, 38.8085)

function combs = nmultichoosek(values, k)
% Return number of multisubsets or actual multisubsets.
% https://stackoverflow.com/questions/28284671/generating-all-combinations-with-repetition-using-matlab

if numel(values)==1 
    n = values;
    combs = nchoosek(n+k-1, k);
else
    n = numel(values);
    combs = bsxfun(@minus, nchoosek(1:n+k-1, k), 0:k-1);
    combs = reshape(values(combs), [], k);
end

end

function h = scatter3d(im, param)
% 3D scatter plot of pixels in image
% 
% im ...... input 3D array, each coordinate corresponds to one matrix
% param ... structure of optional parameters:
%      .coloraxes .......... axes labels
%      .coloraxeslimits .... axes limits
%      .colorsToPlot ....... RGB triples in [0 1]x[0 1]x[0 1] to be used
%                            for corresponding positions in 'im';
%                            it has to bear the same structure as 'im'
%      .quantization ....... width of quantization interval 
%                            (quant. is beneficial for large images to accelerate plotting)

% (c) 2019 Syrine Ben Ameur, Pavel Rajmic, Brno University of Technology

im = double(im);

% Extract components
first = im(:, :, 1);
second = im(:, :, 2);
third = im(:, :, 3);

% Form matrix with triplets as rows
data = [first(:) second(:) third(:)];

% Check if parameters are present
if ~exist('param', 'var')
    param = struct; % structure with no fields (necessary for correct further processing)
end

% Quantize if requested
if isfield(param, 'quantization')  % if requested
    data =  round(data / param.quantization) * param.quantization;  % quantize
end

%% Plot
% Avoid pixels with identical RGB values
if ~isfield(param, 'colorsToPlot')
    data = unique(data, 'rows');
    param.colorsToPlot = data/255; % default colors are RGB values itself
else % make the colors the same structure
    firstC = param.colorsToPlot(:, :, 1);
    secondC = param.colorsToPlot(:, :, 2);
    thirdC = param.colorsToPlot(:, :, 3);
    param.colorsToPlot = [firstC(:) secondC(:) thirdC(:)];
end

% Plot
figure
h = scatter3(data(:, 1), data(:, 2), data(:, 3), 20, param.colorsToPlot, 'filled');

% Axes labes
if ~isfield(param, 'coloraxes')  % default is RGB axes
    param.coloraxes = {'R', 'G', 'B'};
end

xlabel(param.coloraxes{1})
ylabel(param.coloraxes{2})
zlabel(param.coloraxes{3})

% Axes limits
% please be aware that if quantization happens above, the new values can
% fall outside of the original axis limit (e.g. 255 could become 260)
if ~isfield(param, 'coloraxeslimits')  % default is RGB axes
    param.coloraxeslimits = {[0 255], [0 255], [0 255]};
end

set(gca, 'XLim', param.coloraxeslimits{1})
set(gca, 'YLim', param.coloraxeslimits{2})
set(gca, 'ZLim', param.coloraxeslimits{3})

axis equal  % identical scaling

end