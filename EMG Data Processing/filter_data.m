%% Get EMG Data between two NAN Values
% Change second number for different muscles
EMG_GONIOMETER_DATA = EMG_TABLE{FIRST_NAN_EMG:SECOND_NAN_EMG,1};
% Center the data (subtract from mean)
EMG_GONIOMETER_DATA_CENTER = double(EMG_GONIOMETER_DATA-mean(EMG_GONIOMETER_DATA));
% Apply bandpass filter w/following attributes
bandpass_filt = designfilt('bandpassfir','FilterOrder',4, ...
    'CutoffFrequency1',20,'CutoffFrequency2',400, ...
    'SampleRate',1000);
EMG_GONIOMETER_DATA_BANDPASS = filter(bandpass_filt,EMG_GONIOMETER_DATA_CENTER);
% Rectify Data (absolute value)
EMG_GONIOMETER_DATA_ABSOLUTE = abs(EMG_GONIOMETER_DATA_BANDPASS);
% Apply lowpass filter w/following attributes
% Note not sure if the passband frequency is correct
lowpass_filt = designfilt('lowpassiir','FilterOrder',4, ...
         'PassbandFrequency',0.16667);
EMG_GONIOMETER_DATA_LOWPASS = filter(lowpass_filt, EMG_GONIOMETER_DATA_ABSOLUTE);
EMG_GONIOMETER_DATA_DOWNSAMPLED = downsample(EMG_GONIOMETER_DATA_LOWPASS,5);
% Final data to be used in NMM_script2.m
angle_enc = angle_enc(1:length(EMG_GONIOMETER_DATA_DOWNSAMPLED),:);
EMGsignal_vasti = EMG_GONIOMETER_DATA_DOWNSAMPLED;