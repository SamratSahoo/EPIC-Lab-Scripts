%% Data files to read
EMG_INFO_FILE = "data_log5.mot";
ANGLE_INFO_FILE  = "data_log_5_712.txt";

%% Read data from files to tables
EMG_TABLE = readtable(EMG_INFO_FILE,"FileType", "text");
% Change this to try other muscles !!
EMGsignal_vasti = EMG_TABLE{:,1};
% Read angle table of angles
ANGLE_TABLE = readtable(ANGLE_INFO_FILE);

%% Get column with command initiation + find the 1s
COMMAND_INIT_COLUMN = ANGLE_TABLE{:,5};
% Find where ones start in the command initiation column
ONE_ROW = find(diff(COMMAND_INIT_COLUMN) == 1);
% Get first and second one
FIRST_ONE_CMD_INIT = ONE_ROW(1,:);
SECOND_ONE_CMD_INIT = ONE_ROW(2,:);

%% Get NAN Rows from EMG Data to know where to use data from
NAN_COL = EMG_TABLE{:,8};
[NAN_ROWS, NAN_COLS] = find(isnan(NAN_COL));
% Get first and second NAN rows
FIRST_NAN_EMG = NAN_ROWS(1, :);
SECOND_NAN_EMG = NAN_ROWS(2, :);


%% Final Data to use in other script
% Splice angle table from the first "1" to the end of table
angle_enc = ANGLE_TABLE{FIRST_ONE_CMD_INIT:SECOND_ONE_CMD_INIT, 6};