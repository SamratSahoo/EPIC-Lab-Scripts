%% Load Data + Choose Muscle
load("Processed_1b.mat")

if exist('current_muscle','var') == 0
    current_muscle = "Vasti_l";
end 

emg_goniometer_data_filtered = EMGtable1{:, current_muscle};
EMGsignal_vasti = emg_goniometer_data_filtered;
