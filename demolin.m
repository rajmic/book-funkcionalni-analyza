close all
clc

%% Priprava vstupnich vektoru
disp('Jednotkova koule v norme l2')
x = generate_unit_ball(400, 3, 2); % jednotkova koule v R^3 s normou l2
plot3(x(:, 1), x(:, 2), x(:, 3), 'x')
grid on
hold on
axis equal
pause

%% Linearni transformace  
% diagonalni operator
clc
disp('diagonalni operator')
T0 = diag([1 5 2]) %#ok<*NOPTS>
y = T0*x';
y = y';
plot3(y(:, 1), y(:, 2), y(:, 3), 'rx')
axis('equal')
pause

% obecny operator
clc
disp('obecny operator')
T1 = [-0.9 , -0.6, 0.9; -0.1, 0.8, 0.8; 0.1, 1.1, 1.8]
disp('Hodnost: '); rank(T1)
y = T1*x';
y = y';
plot3(y(:, 1), y(:, 2), y(:, 3), 'kx')
axis('equal')
% (jeho vl. cisla a vektory)
[V, D] = eig(T1)
Vscale = V*D;
plot3([0 Vscale(1, 1)], [0 Vscale(2, 1)], [0 Vscale(3, 1)], 'k-', 'LineWidth', 3)
plot3([0 Vscale(1, 2)], [0 Vscale(2, 2)], [0 Vscale(3, 2)], 'k-', 'LineWidth', 3)
plot3([0 Vscale(1, 3)], [0 Vscale(2, 3)], [0 Vscale(3, 3)], 'k-', 'LineWidth', 3)
disp('Jeho vlastni vektory jsou na sebe kolme')
pause

% ortogonalni projektor I
clc
disp('ortogonalni projekce I')
T2 = diag([1 1 0])
T2*T2 % overeni idempotence
disp('Hodnost: '); rank(T2)
y = T2*x';
y = y';
plot3(y(:, 1), y(:, 2), y(:, 3), 'go')
axis('equal')
pause

% ortogonalni projektor II
clc
disp('ortogonalni projekce II')
T3 = [-1   -0.5
      -1.5 -0.1
       0.7  1.2];
T3 = T3*inv(T3'*T3)*T3' %#ok<MINV> % konstrukce projektoru
T3*T3 % overeni idempotence
disp('Hodnost: '); rank(T3)
y = T3*x';
y = y';
plot3(y(:, 1), y(:, 2), y(:, 3), 'mo')
axis('equal')

plot3([0 T3(1, 1)], [0 T3(2, 1)], [0 T3(3, 1)], 'm-', 'LineWidth', 3)
plot3([0 T3(1, 2)], [0 T3(2, 2)], [0 T3(3, 2)], 'm-', 'LineWidth', 3)


function out = generate_unit_ball(count, n, p)

    % generuje nahodne vektory na jednotkove kouli v R^n s normou prejatou z l^p
    x = rand(count, n); % nahodne vektory v R^n v intervalu (0, 1)
    x = 2*x-1; % symetrizace
    
    % normalizace - vytvoreni jednotkove koule
    for cnt = 1:size(x, 1)
        x(cnt, :) = x(cnt, :) ./ norm(x(cnt, :), p);
    end
    out = x;

end