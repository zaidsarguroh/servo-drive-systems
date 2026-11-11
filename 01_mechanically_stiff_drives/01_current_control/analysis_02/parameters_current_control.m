clc; clear all; close all;

%% Parameters


% Plant / Motor
R = 1.5;        % motor resistance [ohm]
L = 6e-3;       % motor inductance [H]
Tel = L/R;      % electrical constant

% Controller / Current Control
Kp_norm = 50;

Kp = Kp_norm*R;
Ti = Tel;
Ki = Kp/Ti;
Kd = 0;

Ts = 50e-6;