clc; clear all; close all;

parameters_current_control;

% Control flags
plot_results = 1;

%% Analysis 01.1: PI Controller
Kp_norm  = [5, 10, 20, 50];
Ti = 4e-3;
Kd = 0;

model = "model_analysis_01";
sigNames = ["w_c", "y_c", "u_c"];

% linearization points (I/O for defining the transfer function)
io(1) = linio(model + "/Step", 1, "input");
io(2) = linio(model + "/Transfer Fcn", 1, "output");

results = struct("Kp_norm", {}, "Kp", {}, "Ki", {}, "Gw", {});

for k = 1:numel(Kp_norm)
    Kp = R*Kp_norm(k);
    Ki = Kp/Ti;

    out = sim(model);
    logs = out.logsout;

    results(k).Kp_norm = Kp_norm(k);
    results(k).Kp = Kp;
    results(k).Ki = Ki;
    
    for s = sigNames
        results(k).(s) = logs.get(s).Values;
    end

    G = tf(linearize(model, io));
    [num, den] = tfdata(G, "v");
    c = den(end);
    if c ~= 0
        G = tf(num/c, den/c);
    end
    results(k).Gw = G;
end

save("analysis_01_PI_controller.mat", "results");

% Plot
if plot_results
    fig = figure;
    hold on

    for k = 1:numel(results)
        if k == 1
            w = results(k).w_c;
            plot(w.Time*1e3, w.Data, "k--", "LineWidth", 2, "DisplayName", "w_c (ref)")
        end
        y = results(k).y_c;
        plot(y.Time*1e3, y.Data, "LineWidth", 2, "DisplayName", "Kp_{norm} = " + results(k).Kp_norm)
    end

    xlim([0, 30]);
    ylim([-0.1, 1.2]);
    xlabel("t [ms]");
    ylabel("w(t), y(t) [A]");
    title("P Controller");
    legend("Location", "southeast");
    grid on;
end