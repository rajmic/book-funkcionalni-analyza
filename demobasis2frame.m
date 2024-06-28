clear
close all

%% nastavení dimenze
% dim = 3 ... vykreslí ONB ve 3D a frame jako projekci této báze do 2D
% dim > 3 ... vykreslí pouze frame
dim = 3;

%% vytvoření ONB
% nejdříve je vytvořena náhodná matice, o které předpokládáme, že je
% regulární
% následně je použita Gramova–Schmidtova ortogonalizace, která zajistí, že
% sloupce matice B tvoří ONB
rng(100)
B = randn(dim);
B(:, 1) = B(:, 1) / norm(B(:, 1));
for d = 2:dim
    for i = 1:d-1
        B(:, d) = B(:, d) - (B(:, d)'*B(:, i)) * B(:, i);
    end
    B(:, d) = B(:, d) / norm(B(:, d));
end

%% projekce do 2D
T = B(1:2, :);

%% kreslení
% příprava os
figure
ax(1) = axes;
colors = lines(dim);
if dim == 3
    figure
    ax(2) = axes;
end

% vykreslení báze a framu
for d = 1:dim
    if dim == 3
        % bázový vektor
        plot3(ax(2), [0, B(1, d)], [0, B(2, d)], [0, B(3, d)], ...
            "Color", colors(d, :), "LineWidth", 1, "LineStyle", "-.")
        hold(ax(2), "on")

        % odpovídající atom framu
        plot3(ax(2), [0, T(1, d)], [0, T(2, d)], [0, 0], ...
            "Color", colors(d, :), "LineWidth", 2)
        
        % spojnice
        plot3(ax(2), [B(1, d), B(1, d)], [B(2, d), B(2, d)], [B(3, d), 0], ...
            "Color", colors(d, :), "LineStyle", ":")
    end

    % atom framu
    plot(ax(1), [0, T(1, d)], [0, T(2, d)], "Color", colors(d, :), "LineWidth", 2)
    hold(ax(1), "on")
end

% nastavení vzhledu os
for a = ax
    grid(a, "on")
    a.PlotBoxAspectRatio = [1 1 1]; % axis square
end
xline(ax(1), 0, "k")
yline(ax(1), 0, "k")
if dim == 3
    patch(ax(2), [1 -1 -1 1], [1 1 -1 -1], [0 0 0 0], ...
        "FaceColor", 0.85*[1 1 1], ...
        "FaceAlpha", 0.5, ...
        "EdgeColor", "none")
    line(ax(2), [-1, 1], [0, 0], [0, 0], "Color", "k")
    line(ax(2), [0, 0], [-1, 1], [0, 0], "Color", "k")
end

%% ověření, že se jedná o Parsevalův frame
fprintf("Tato matice by měla být jednotková:\n")
disp(T*T')