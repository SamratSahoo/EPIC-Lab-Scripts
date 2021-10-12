process_data_script = 'process_data.m';
filter_data_script = 'filter_data.m';
neuro_muscular_model_script = 'NMM_script2.m';
combined_assistance = 0;

for muscle_number = 2:4 
    run(process_data_script);
    run(filter_data_script);
    run(neuro_muscular_model_script);
    combined_assistance = combined_assistance + assistance;
    hold on;
end
plot(time,combined_assistance); 