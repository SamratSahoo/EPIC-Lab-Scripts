%% Intialize Variables
clear
load('Processed_1119_2.mat');
load('NMMparams_default.mat');
process_data_script = "process_data.m";
filter_data_script = "filter_data.m";

%% Load Params
params = default;
for ii = 1:length(param_names)
    if ~istable(Control)
        params.(param_names{ii}) = Control(ii);
    else
        params.(param_names{ii}) = Control{1,ii};
    end
end

%% Preprocess Data
run(process_data_script);
trial_data.angle_enc = angle_enc;
for muscle_number = 1:3
    run(filter_data_script)
    if muscle_number == 1
        trial_data.EMGsignal_vasti = EMGsignal_vasti;
    elseif muscle_number == 2
        trial_data.EMGsignal_hams = EMGsignal_vasti;
    elseif muscle_number == 3
        trial_data.EMGsignal_gastroc = EMGsignal_vasti;
    end
end
trial_data.EMGtime = [1:length(EMGsignal_vasti)]./100;

%% Run Model
[commanded_torque, sim_time]= NMMrun(params,trial_data);

%% Plot data
plot(commanded_torque / max(commanded_torque), 'LineWidth',2.0);
hold on;
torque_l = Ttable1{:,"Torque_l"};
plot(torque_l(1:length(commanded_torque),:), 'LineWidth',2.0);
legend('Commanded Torque', 'Jetson Torque')
xlabel('Time');
ylabel('Torque');