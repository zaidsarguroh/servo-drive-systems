clc; clear all; close all;

%% Parameters
% Plant / Motor
R = 1.5;        % motor resistance [ohm]
L = 6e-3;       % motor inductance [H]
Tel = L/R;      % electrical constant

% Controller / Current Control
Kp_norm = 5;
Kp = Kp_norm*R;
Ti = 4e-3;
Ki = 0;
Kd = 0;

%% Control flags
plot_response = 1;
plot_bode = 1;

%% Simulate
model = "plant_current_control";
sigNames = ["w_c", "y_c", "u_c"];

% linearization points (I/O for defining the reference transfer function)
Gw_io(1) = linio(model + "/Reference Current", 1, "input");
Gw_io(2) = linio(model + "/Motor (Electrical Plant)", 1, "output");

% linearization points (I/O for defining the disturbance transfer function)
Gd_io(1) = linio(model + "/Induced Input Disturbance (back emf)", 1, "input");
Gd_io(2) = linio(model + "/Motor (Electrical Plant)", 1, "output");

results = struct("Kp_norm", {}, "Kp", {}, "Ki", {},"Gw", {},"Gd", {});

Kp = R*Kp_norm;

out = sim(model);
logs = out.logsout;

results(1).Kp_norm = Kp_norm;
results(1).Kp = Kp;
results(1).Ki = Ki;

for s = sigNames
    results(1).(s) = logs.get(s).Values;
end

% Generate transfer functions
Gw = tf(linearize(model, Gw_io));
[num, den] = tfdata(Gw, "v");
c = den(end);
if c ~= 0
    Gw = tf(num/c, den/c);
end
results.Gw = Gw;

Gd = tf(linearize(model, Gd_io));
[num, den] = tfdata(Gd, "v");
c = den(end);
if c ~= 0
    Gd = tf(num/c, den/c);
end
results.Gd = Gd;
%%
if plot_response
    w = results.w_c;
    plot(w.Time, w.Data,"k--")
    hold on;
    y = results.y_c;
    plot(y.Time, y.Data)
    title('Step response')
    xlabel('Time [s]');
    ylabel('w(t), y(t) [A]');
    legend('Reference', 'Current');

    figure;
    u = results.u_c;
    plot(u.Time, u.Data, "DisplayName", "Kp_{norm} = " + results.Kp_norm)
    title('Controller output')
    xlabel('Time [s]');
    ylabel('u_{c}(t) [V]');
    legend('Controller output');
end

if plot_bode
    figure;
    bode(results.Gw);
    hold on;
    bode(results.Gd);
    grid on;
    legend('Reference TF', 'Disturbance TF')
end