biological_torque_estimate = angle_table{first_one_command_init:second_one_command_init,1};
motor_commanded_torque = angle_table{first_one_command_init:second_one_command_init,2};
timing = angle_table{first_one_command_init:second_one_command_init,3};
heelstrike = angle_table{first_one_command_init:second_one_command_init,4};
command_initiation = angle_table{first_one_command_init:second_one_command_init,5};
knee_angle = angle_table{first_one_command_init:second_one_command_init,6};
filtered_torque = angle_table{first_one_command_init:second_one_command_init,7};

biological_torque_estimate = motor_commanded_torque(1:length(time));