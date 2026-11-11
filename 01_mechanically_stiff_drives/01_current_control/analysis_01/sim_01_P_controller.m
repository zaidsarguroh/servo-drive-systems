clc; clear all; close all;

parameters_plant;

% Control flags
plot_results = 1;
plot_bode = 1;

%% Analysis 01.1: P Controller
Kp_norm  = [5, 10, 20, 50];
Ki = 0;
Kd = 0;
model = "model_current_control_01";
sigNames = ["w_c", "y_c", "u_c"];

% linearization points (I/O for defining the transfer function)
io(1) = linio(model + "/Reference Current", 1, "input");
io(2) = linio(model + "/Motor (Electrical Plant)", 1, "output");

results = struct("Kp_norm", {}, "Kp", {}, "Ki", {},"Gw", {});

for k = 1:numel(Kp_norm)
    Kp = R*Kp_norm(k);
    
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

save("out_01_P_controller.mat", "results");

%% Plot
if plot_results
    fig = figure;
    hold on

    for k = 1:numel(results)
        if k == 1
            w = results(k).w_c;
            plot(w.Time*1e3, w.Data, "k--", "LineWidth", 2, "DisplayName", "w_c (ref)")
        end
        y = results(k).y_c;
        plot(y.Time*1e3, y.Data, "DisplayName", "Kp_{norm} = " + results(k).Kp_norm)

    end

    xlim([0, 30]);
    ylim([-0.1, 1.2]);
    xlabel("t [ms]");
    ylabel("w(t), y(t) [A]");
    title("P Controller - Step Response");
    legend("Location", "southeast");
    grid on;

    fig = figure;
    hold on

    for k = 1:numel(results)
        u = results(k).u_c;
        plot(u.Time*1e3, u.Data, "DisplayName", "Kp_{norm} = " + results(k).Kp_norm)

    end
    xlim([8, 13]);
    xlabel("t [ms]");
    ylabel("u_{c}(t) [V]");
    title("P Controller - Controller Output");
    legend("Location", "northeast");
    grid on;
end

if plot_bode
    fig = figure;
    hold on

    for k = 1:numel(results)
        bode(results(k).Gw)
    end
    grid on;
    title("P Controller - Bode Plot")
    legend('Kp_{norm} = 5','Kp_{norm} = 10','Kp_{norm} = 20','Kp_{norm} = 50')

end