clear
close all

figure
tiledlayout(1, 2)

% interpreter for axes and text
set(gcf, 'defaultAxesTickLabelInterpreter', 'latex');
set(gcf, 'defaultColorbarTickLabelInterpreter', 'latex');
set(gcf, 'defaultLegendInterpreter', 'latex');
set(gcf, 'defaultTextInterpreter', 'latex');

for k = 1:2

    % data
    if k == 1
        x = [3, -2]';
    else
        x = [3, 0]';
    end

    p = 1;
    q = 1/(1-1/p);
    
    %% figure and axes
    nexttile
    hold on
    grid on
    xlims = [-1.5, 3.5];
    ylims = [-3, 1.5];
    zlims = [-7.5, 16.5];
    basewidth = 0.75;
    pointsize = 24;
    C = colororder;
    C = C([2, 1, 4, 5, 6, 7], :);
    
    % lines
    line([0, 0], ylims, [0, 0], 'linewidth', basewidth, 'color', 'k')
    line(xlims, [0, 0], [0, 0], 'linewidth', basewidth, 'color', 'k')
    
    % labels
    xlabel('$$\eta_1$$', 'Interpreter', 'latex')
    ylabel('$$\eta_2$$', 'Interpreter', 'latex')
    zlabel(sprintf('$$\\langle \\mathbf{x}, \\mathbf{y} \\rangle = %d\\eta_1 %+d\\eta_2$$', x(1), x(2)), 'Interpreter', 'latex')
    
    %% unit ball in q-norm
    if q < Inf
        xs = -1:0.01:1;
        f = @(x) (1 - abs(x).^q).^(1/q);
        plot3(xs, f(xs), 0*xs, 'color', C(1, :), 'linewidth', 2*basewidth)
        plot3(xs, -f(xs), 0*xs, 'color', C(1, :), 'linewidth', 2*basewidth)
        clear f
    else
        line([-1, 1, 1, -1, -1], [-1, -1, 1, 1, -1], zeros(1, 5), ...
            'linewidth', 2*basewidth, ...
            'color', C(1, :))
    end
    
    %% the point x
    scatter3(x(1), x(2), 0, pointsize, C(2, :), 'filled')
    if x(1) ~= 0 && x(2) ~= 0
        line(x(1)*[1, 1], [0, x(2)], [0, 0], 'color', C(2, :), 'linestyle', '--')
        line([0, x(1)], x(2)*[1, 1], [0, 0], 'color', C(2, :), 'linestyle', '--')
    end
    text(x(1)*1.1, x(2)*1.1, 0, ...
        sprintf('$$\\mathbf{x} = [%d, %d]$$', x(1), x(2)), 'Interpreter', 'latex')
    
    %% the objective: |x'*y| for given x and any y
    % the surface
    [X, Y, Z] = griddata(x, xlims, ylims);
    surf(X, Y, Z, ...
        'FaceAlpha', 0.15, ...
        'EdgeColor', 'none', ...
        'FaceColor', 'interp')
    
    %% the objective: |x'*y| for given x and any y from the unit ball
    if q < Inf
        [X, Y] = meshgrid(-1:0.01:1);
        XY = [X(:)'; Y(:)'];
        XY = [cos(atan(-x(1)/x(2))), -sin(atan(-x(1)/x(2))); ...
              sin(atan(-x(1)/x(2))), cos(atan(-x(1)/x(2)))] ...
              * XY;
        X = reshape(XY(1, :), size(X));
        Y = reshape(XY(2, :), size(Y));
        Z = zeros(size(X));
        N = zeros(size(X));
        f = @(y) x'*y;
        for i = 1:size(X, 1)
            for j = 1:size(X, 2)
                Z(i, j) = f([X(i, j); Y(i, j)]);
                N(i, j) = norm([X(i, j); Y(i, j)], q);
                if N(i, j) > 1.01 || (N(i, j) < 0.9 && Z(i, j) > 0.1)
                    X(i, j) = 0;
                    Y(i, j) = 0;
                    Z(i, j) = 0;
                end
            end
        end
    else
        [X, Y, Z] = griddata(x, [-1, 1], [-1, 1]);
    end
    surf(X, Y, Z + 0.01, ...
            'FaceAlpha', 0.85, ...
            'EdgeColor', 'none', ...
            'FaceColor', 'interp')
    
    %% the optimum
    if q == Inf
        % find it
        [M, I] = max(Z(:));
        
        % plot it
        if x(1) == 0
            X = [-1, 1];
            Y = sign(x(2)) * [1, 1];
            plot3(X, Y, M*[1, 1] + 0.01, 'linewidth', 2, 'color', C(3, :))
        elseif x(2) == 0
            X = sign(x(1)) * [1, 1];
            Y = [-1, 1];
            plot3(X, Y, M*[1, 1] + 0.01, 'linewidth', 2, 'color', C(3, :))
        else
            X = X(I);
            Y = Y(I);
            scatter3(X, Y, M + 0.01, pointsize, C(3, :), 'filled')
        end
    else
        % find it
        cvx_begin quiet
            variables y(2)
            maximize (y' * x)
            subject to
                norm( y, q ) <= 1; %#ok<*VUNUS>
        cvx_end
        X = y(1);
        Y = y(2);
        M = y'*x;
        clear y
        
        % plot it
        scatter3(X, Y, M + 0.01, pointsize, C(3, :), 'filled')
    end
    for i = 1:length(X)
        % horizontal lines for each point
        if q ~= Inf || (abs(X(i)) ~= 1)
            line(X(i)*[1, 1], [0, Y(i)], [0, 0], 'color', C(3, :), 'linestyle', '--')
        end
        if q ~= Inf || (abs(Y(i)) ~= 1)
            line([0, X(i)], Y(i)*[1, 1], [0, 0], 'color', C(3, :), 'linestyle', '--')
        end
        
        % vertical line for each point
        line(X(i)*[1, 1], Y(i)*[1, 1], [0, M], 'color', C(3, :), 'linestyle', '--')
    end
    
    
    %% limits and view
    % axes limits
    xlim(xlims)
    ylim(ylims)
    zlim(zlims)
    
    % view
    set(gca, 'View', [-20.4448 38.9149])

end

% figure position and size
set(gcf, 'Position', [1340 617 686 242])
    

%% useful function
function [X, Y, Z] = griddata(x, plotlimsx, plotlimsy)
    vlevo  = [plotlimsx(1), -x(1)*plotlimsx(1)/x(2)];
    vpravo = [plotlimsx(2), -x(1)*plotlimsx(2)/x(2)];
    nahore = [-x(2)*plotlimsy(2)/x(1), plotlimsy(2)];
    dole   = [-x(2)*plotlimsy(1)/x(1), plotlimsy(1)];
    if abs(x(1)/x(2)) > 1
        X = [plotlimsx(1), nahore(1), plotlimsx(2); ...
             plotlimsx(1), dole(1),   plotlimsx(2)];
        Y = [plotlimsy(2), plotlimsy(2), plotlimsy(2); ...
             plotlimsy(1), plotlimsy(1), plotlimsy(1)];
    elseif abs(x(1)/x(2)) < 1
        X = [plotlimsx(1), plotlimsx(2); ...
             plotlimsx(1), plotlimsx(2); ...
             plotlimsx(1), plotlimsx(2)];
        Y = [plotlimsy(2), plotlimsy(2); ...
             vlevo(2), vpravo(2); ...
             plotlimsy(1), plotlimsy(1)];
    else
        X = [plotlimsx(1), plotlimsx(2); ...
             plotlimsx(1), plotlimsx(2)];
        Y = [plotlimsy(2), plotlimsy(2); ...
             plotlimsy(1), plotlimsy(1)];
    end
    
    Z = zeros(size(X)); % objective value
    
    f = @(y) x'*y;
    for i = 1:size(X, 1)
        for j = 1:size(X, 2)
            Z(i, j) = f([X(i, j); Y(i, j)]);
        end
    end
end