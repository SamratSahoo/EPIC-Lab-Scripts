process_data_script = 'process_data.m';
filter_data_script = 'filter_data.m';
neuro_muscular_model_script = 'NMM_script2.m';
rio_data_script = 'rio_data.m';

combined_assistance = 0;

for muscle_number = 2:4 
    run(process_data_script);
    run(filter_data_script);
    run(neuro_muscular_model_script);
    combined_assistance = combined_assistance - assistance;
    if muscle_number == 2
        combined_assistance = combined_assistance + 2*assistance;
    end
    hold on;
end
%run(rio_data_script);
plot(time,combined_assistance);
%hold on;
%plot(time,biological_torque_estimate*(0.6/max(biological_torque_estimate)))