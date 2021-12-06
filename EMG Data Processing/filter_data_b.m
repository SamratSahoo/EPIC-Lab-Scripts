%% Filter Settings
bandpass_low_frequency = 20;
bandpass_high_frequency = 400;
lowpass_frequency = 6;
sampling_frequency = 1000;
filter_order = 4;
downsampling_factor = 5;

%% Load Data + Choose Muscle
load("data\Processed_1b.mat")
emg_goniometer_data = EMGtable1{:, "Vasti_l"};

%% Set angle_enc variable

%% Filter Data
% Center the data (subtract from mean)
emg_goniometer_data_center = double(emg_goniometer_data-mean(emg_goniometer_data));
% Apply bandpass filter w/following attributes
[B,A] = butter(filter_order ,[bandpass_low_frequency bandpass_high_frequency]/sampling_frequency/2, "bandpass");
emg_goniometer_data_bandpass = filtfilt(B,A,emg_goniometer_data_center);
% Rectify Data (absolute value)
emg_goniometer_data_absolute = abs(emg_goniometer_data_bandpass);
% Apply lowpass filter w/following attributes
[b, a] = butter(filter_order,lowpass_frequency /(sampling_frequency/2), "low");
emg_goniometer_data_lowpass =  filtfilt(b, a, emg_goniometer_data_absolute);
% EMG_GONIOMETER_DATA_LOWPASS = filter(lowpass_filt, EMG_GONIOMETER_DATA_ABSOLUTE);
emg_goniometer_data_downsampled = downsample(emg_goniometer_data_lowpass,downsampling_factor);
% Final data to be used in NMM_script2.m
angle_enc = angle_enc(1:length(emg_goniometer_data_downsampled),:);
EMGsignal_vasti = emg_goniometer_data_downsampled;
