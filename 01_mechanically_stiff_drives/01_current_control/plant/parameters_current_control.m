%% Parameters

% Plant / Motor
R = 1.5;        % motor resistance [ohm]
L = 6e-3;       % motor inductance [H]
Tel = L/R;      % electrical constant

% Plant / State-Space
A = -1/Tel;
B = 1/R*1/Tel;
C = 1;
D = 0;

% Controller / Current Control
Kp = 10;
Ti = 4e-3;
Ki = Kp/Ti;
Kd = 0;