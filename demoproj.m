clc

%% ilustrace k dualnimu framu
fmt = ['  Scitanec %d:' repmat(' %6.3f ', 1, 2) ' (skalarni soucin %.3f)\n'];
fmt_soucet = ['  Soucet:    ' repmat(' %6.3f ', 1, 2) '\n\n'];
fprintf('========================\n')
fprintf('Pripad 2D (bez projekce)\n')
fprintf('========================\n')
fprintf('\n')

T = [1  0  1;...
     0  1 -1]; % sloupce tvori frame v R2
S = T*T'; % framovy operator

fprintf('Puvodni frame:\n')
disp(T)

fprintf('Framovy operator:\n')
disp(S)

Sinv = inv(S); % inverze framoveho operatoru

fprintf('Inverze framoveho operatoru:\n')
disp(Sinv)

Tdual = Sinv*T; %#ok<MINV> % dualni frame

fprintf('Dualni frame:\n')
disp(Tdual)

%% ilustrace vety o reprezentaci pomoci dualniho framu
x = [1; 1/3]; % zvoleny vektor x
fprintf('Zvoleny vektor (transponovany):\n')
disp(x')

% reprezentace pomoci dualniho framu (bez projekce)
fprintf('Varianta prvni: Skalarni souciny s dualnim framem\n')
xhat = zeros(size(x));
for n = 1:size(T, 2)
    sksoucin = x'*Tdual(:, n);
    scitanec = sksoucin * T(:, n);
    xhat = xhat + scitanec;
    fprintf(fmt, n, scitanec', sksoucin)
end
fprintf(fmt_soucet, xhat')

fprintf('Varianta druha: Skalarni souciny s puvodnim framem\n')
xhat = zeros(size(x));
for n = 1:size(T, 2)
    sksoucin = x'*T(:, n);
    scitanec = sksoucin * Tdual(:, n);
    xhat = xhat + scitanec;
    fprintf(fmt, n, scitanec', sksoucin)
end
fprintf(fmt_soucet, xhat')

%% presun do R3
fmt = ['  Scitanec %d:' repmat(' %6.3f ', 1, 3) ' (skalarni soucin %.3f)\n'];
fmt_soucet = ['  Soucet:    ' repmat(' %6.3f ', 1, 3) '\n\n'];
fprintf('======================\n')
fprintf('Pripad 3D (s projekci)\n')
fprintf('======================\n')
fprintf('\n')

T3 = [1  0  1;...
      0  1 -1;...
      0  0  0];
  
Tdual3 = [Tdual; 0 0 0];
  
% matice rotace kolem osy n o uhel alfa
osa = [1 0 0]';
osa = osa/norm(osa);
alpha = pi/4;
R = (1-cos(alpha))*(osa*osa') + cos(alpha)*eye(3) + sin(alpha)*[0 -osa(3) osa(2); osa(3) 0 -osa(1); -osa(2) osa(1) 0 ];
T3 = R*T3;
S3 = T3*T3';

% dualni frame
Tdual3 = R*Tdual3;

fprintf('Transformacni matice:\n')
disp(R)

fprintf('Puvodni frame:\n')
disp(T3)

fprintf('Framovy operator:\n')
disp(S3)

Sinv3 = pinv(S3); % pseudoinverze framoveho operatoru

fprintf('Pseudoinverze framoveho operatoru:\n')
disp(Sinv3)

Tdual3_pinv = Sinv3*T3; % dualni frame

fprintf('Dualni frame (pseudoinverze):\n')
disp(Tdual3_pinv)

fprintf('Dualni frame (rotace puvodniho):\n')
disp(Tdual3)

% testovaci projekce
x3 = R*[1; 1/3; 2/3];

fprintf('Varianta prvni: Skalarni souciny s dualnim framem\n')
xhat3 = zeros(size(x3));
for n = 1:size(T3, 2)
    sksoucin = x3'*Tdual3(:, n);
    scitanec = sksoucin * T3(:, n);
    xhat3 = xhat3 + scitanec;
    fprintf(fmt, n, scitanec', sksoucin)
end
fprintf(fmt_soucet, xhat3')

fprintf('Varianta druha: Skalarni souciny s puvodnim framem\n')
xhat3 = zeros(size(x3));
for n = 1:size(T3, 2)
    sksoucin = x3'*T3(:, n);
    scitanec = sksoucin * Tdual3(:, n);
    xhat3 = xhat3 + scitanec;
    fprintf(fmt, n, scitanec', sksoucin)
end
fprintf(fmt_soucet, xhat3')

% baze podprostoru
B3 = R*[1 0; 0 1; 0 0];
fmt = ['Kontrola:    ' repmat(' %6.3f ', 1, 3) ' (vypocet pomoci baze)\n'];
fprintf(fmt, (B3*B3'*x3)')
fmt = ['Kontrola:    ' repmat(' %6.3f ', 1, 3) ' (otoceni puvodniho reseni)\n'];
fprintf(fmt, (R*[1; 1/3; 0])')
fprintf('\n')

%% pripad (obecne) dualniho framu
fprintf('===============================================\n')
fprintf('Pripad 3D (s projekci) a obecnym dualnim framem\n')
fprintf('===============================================\n')
fprintf('\n')

% matice W
W = [0 0 2; 0 2*sqrt(2) 0; sqrt(2) 0 0];

fprintf('Matice W:\n')
disp(W)

% vypocet matice T obecne dualniho framu
Tdual3_obecne = Tdual3 + W*(eye(3)-Tdual3'*T3);

fprintf('Obecny dualni frame:\n')
disp(Tdual3_obecne)

fmt = ['Projekce 1:' repmat(' %6.3f ', 1, 3) '\n'];
fprintf(fmt, (T3*Tdual3_obecne'*x3)')

fmt = ['Projekce 2:' repmat(' %6.3f ', 1, 3) '\n'];
fprintf(fmt, (Tdual3_obecne*T3'*x3)')

fmt = ['Kontrola:  ' repmat(' %6.3f ', 1, 3) ' (vypocet pomoci baze)\n'];
fprintf(fmt, (B3*B3'*x3)')