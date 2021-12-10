load("data\Processed_1b.mat");

emg_matrix = table2array(EMGtable1(:,[1,4,1,2,2,5,3]));
[int_MF,previous_activation,previous_muscle_length,previous_MTU_length,previous_tendon_length,previous_muscle_force] = RT_MuscleF_model(emg_matrix, angle_enc);
RTObjectiveFunction(int_MF)

