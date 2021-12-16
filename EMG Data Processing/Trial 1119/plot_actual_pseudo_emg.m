clear;
muscles = ["Vasti_l", "Hamstring_l", "Gastroc_l"];
filter_data_script = "filter_data.m"; 
neuro_muscular_model_script = 'NMM_script2.m';
process_data_script = "process_data.m";
muscle_number = 3;

run(process_data_script)
current_muscle = muscles(muscle_number);
run(filter_data_script);
plot(emg_goniometer_data_downsampled/MVC_measures(:, muscle_number), 'LineWidth',2.0);
hold on;
plot(EMGtable1{1:length(emg_goniometer_data_downsampled),current_muscle}, 'LineWidth',2.0);
legend('Forward Backward Filter','RMS Real Time')
xlabel('Time')
ylabel('Processed EMG')