%% Data files to read
EMG_INFO_FILE = "data_log5.mot";
ANGLE_INFO_FILE  = "data_log_5_712.txt";

%% Read data from data files
EMGsignal_vasti = readtable(EMG_INFO_FILE,"FileType", "text");
% Change this to try other muscles !!
EMGsignal_vasti = EMGsignal_vasti{:,1};
% Read angle table of angles
ANGLE_TABLE = readtable(ANGLE_INFO_FILE);

%% Get column with command initiation + find the 1s
COMMAND_INIT_COLUMN = ANGLE_TABLE{:,5};
% Find where ones start in the command initiation column
ONE_ROW = find(diff(COMMAND_INIT_COLUMN) == 1);
% Get first one
FIRST_ONE = ONE_ROW(1,:);

%% Final Data to use in other script
% Splice angle table to get first one --> end of table
angle_enc = ANGLE_TABLE{FIRST_ONE:height(ANGLE_TABLE), 6};
% Splice EMG data for equal sized vectors
EMGsignal_vasti = EMGsignal_vasti(1:(length(COMMAND_INIT_COLUMN) - FIRST_ONE + 1),:);