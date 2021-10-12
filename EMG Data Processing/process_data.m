%% Data files to read
emg_info_file = "data_log5.mot";
angle_info_file  = "data_log_5_712.txt";

%% Read data from files to tables
emg_table = readtable(emg_info_file,"FileType", "text");
% Change this to try other muscles !!
EMGsignal_vasti = emg_table{:,muscle_number};
% Read angle table of angles
angle_table = readtable(angle_info_file);

%% Get column with command initiation + find the 1s
command_init_column = angle_table{:,5};
% Find where ones start in the command initiation column
one_row = find(diff(command_init_column) == 1);
% Get first and second one
first_one_command_init = one_row(1,:);
second_one_command_init = one_row(2,:);

%% Get NAN Rows from EMG Data to know where to use data from
col_with_nan = emg_table{:,8};
[nan_rows, nan_cols] = find(isnan(col_with_nan));
% Get first and second NAN rows
first_nan_emg = nan_rows(1, :);
second_nan_emg = nan_rows(2, :);


%% Final Data to use in other script
% Splice angle table from the first "1" to the second "1"
angle_enc = angle_table{first_one_command_init:second_one_command_init, 6};