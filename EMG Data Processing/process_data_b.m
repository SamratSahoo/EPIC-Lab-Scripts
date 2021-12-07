%% Data files to read
emg_info_file = "data/data_log_1109_1_b.mot";
load("data\Processed_1b.mat")

%% Read data from files to tables
emg_table = readtable(emg_info_file,"FileType", "text");
if exist('muscle_number','var') == 0
    muscle_number = 1;
end 
% Read angle table of angles
angle_table = EMGtable;

%% Get column with command initiation + find the 1s
command_init_column = EMGtable1{:,"indx"};
% Get first and second one
first_one_command_init = Switches(:,1);
second_one_command_init = Switches(:,2);

%% Get NAN Rows from EMG Data to know where to use data from
col_with_nan = emg_table{:,8};
[nan_rows, nan_cols] = find(isnan(col_with_nan));
% Get first and second NAN rows
first_nan_emg = nan_rows(1, :);
second_nan_emg = nan_rows(2, :);

%% Final Data to use in other script
% Splice angle table from the first "1" to the second "1"
angle_enc = angle_table{first_one_command_init:second_one_command_init, "Angle_r"};
angle_enc = angle_enc / max(angle_enc);