% Demo Least-squares approximation:

% Problem: polynomial least-squares approximation of sin(t) on [-pi, pi]
close all

% Interpolated data:
n = 11; % sample size
d = 3; % degree of polynomial
I = [-pi, pi]; % interval
t = linspace(I(1), I(2), n).';
dt = t(2)-t(1);
x = sin(t);

% Approximation results on fine mesh
N = 1001;
tt = linspace(I(1), I(2), N).';
dtt = tt(2)-tt(1);
xx = sin(tt);
fig = figure;
plot(t, x, 'ok')
hold on
plot(tt, xx, 'color', [.5 .5 .5])
legtxt = {'Samples', 'Exact'};
legend(legtxt)
xlabel('t')
pause

%---------------------------------------------------
% 1. Discrete polynomial approximation by 'polyfit'
xi1 = polyfit(t, x, d);
x1 = polyval(xi1, tt);
plot(tt, x1)
legtxt{end+1} = 'Discrete by polyfit';
legend(legtxt)
pause

%---------------------------------------------------
% 2. Discrete polynomial approximation by left division
T = (t*ones(1, d+1)).^(ones(n, 1)*(0:d)); % coarse mesh
xi2 = T\x;
TT = (tt*ones(1, d+1)).^(ones(N, 1)*(0:d)); % fine mesh
x2 = TT*xi2;
plot(tt, x2)
legtxt{end+1} = 'Discrete by left division';
legend(legtxt)
pause

%---------------------------------------------------
% 3. Discrete polynomial approximation by pseudoinverse
xi3 = pinv(T)*x;
x3 = TT*xi3;
plot(tt, x3)
legtxt{end+1} = 'Discrete by pseudoinverse';
legend(legtxt)
pause

%---------------------------------------------------
% 4. Discrete polynomial approximation by normal equations
xi4 = inv(T'*T)*(T'*x); %#ok<MINV>
x4 = TT*xi4;
plot(tt, x4)
legtxt{end+1} = 'Discrete by normal equations';
legend(legtxt)
pause

%---------------------------------------------------
% 5. Functional polynomial approximation by normal equations
% from numerical quadrature
b = dt*T'*x; % right-hand side of normal equations by num. quadrature
R = dtt*(TT'*TT); % Gram matrix of the system by num. quadrature
xi5 = inv(R)*b; %#ok<MINV>
x5 = TT*xi5;
plot(tt, x5)
legtxt{end+1} = 'Functional by num. quadrature';
legend(legtxt)
pause

%---------------------------------------------------
% 6. Functional polynomial approximation by exact normal equations
% Exact right-hand side (requires symbolic toolbox)
clear b
b(1) = int(str2sym('sin(t)'), -pi, pi);
b(2) = int(str2sym('sin(t)*t'), -pi, pi);
b(3) = int(str2sym('sin(t)*t^2'), -pi, pi);
b(4) = int(str2sym('sin(t)*t^3'), -pi, pi);
% b = [0, 2*pi, 0, 2*pi^3-12*pi].'
b = eval(b).';
E = hankel(1:4, 4:7); % matrix of exponents
R = (pi.^E-(-pi).^E)./E; % exact Gram matrix of the system
xi6 = inv(R)*b; %#ok<MINV>
x6 = TT*xi6;
plot(tt, x6)
legtxt{end+1} = 'Functional exact';
legend(legtxt)
pause

%---------------------------------------------------
% 7. Iteratively using Neumann expansion
% R = T'*T; % discrete case
m = norm(R);
v = eig(R);
lambda = 2/(v(1) + v(4));
IR = eye(size(R)) - lambda*R;
mm = norm(IR);
% b = T'*xi; % discrete case
tol = 1e-50;
xi7 = lambda*b;
Nit = 0;
while norm(b)> tol/lambda
    Nit = Nit + 1;
    b = IR*b;
    xi7 = xi7 + lambda*b;
end
% Number of iterations:
fprintf('Number of iterations: %d\n', Nit)

% Coefficients compared with xi2 and xi6
fprintf('Coefficients compared with xi2 and xi6:\n')
fprintf('xi2 = %.3f, xi6 = %.3f, xi7 = %.3f\n', xi2, xi6, xi7)

x7 = TT*xi7;
plot(tt, x7)
legtxt{end+1} = 'Using Neumann expansion';
legend(legtxt)
hold off