clear

muscles = ["Vasti_l", "Hamstring_l", "Gastroc_l"];
filter_data_script = "filter_data_b.m"; 
neuro_muscular_model_script = 'NMM_script2.m';
process_data_script = "process_data_b.m";
combined_assistance = 0;

for muscle_number = 1:3 
    run(process_data_script)
    current_muscle = muscles(muscle_number);
    run(filter_data_script);
    run(neuro_muscular_model_script);
    combined_assistance = combined_assistance - assistance;
    if muscle_number == 1
        combined_assistance = combined_assistance + 2*assistance;
    end
    hold on;
end

plot(time,combined_assistance,'color',[1 .41 .70]);