function [commanded_torque,sim_time] = NMMrun(params,trial_data)

fields = fieldnames(params);
for p = 1:length(fields)
    if contains(fields{p},'vasti_') == 1
        vasti.(fields{p}(7:end)) = params.(fields{p});
    elseif contains(fields{p},'hams_') == 1
        hams.(fields{p}(6:end)) = params.(fields{p});
    else
        gastroc.(fields{p}(9:end)) = params.(fields{p});
    end
end

vasti.EMGsignal = trial_data.EMGsignal_vasti;
hams.EMGsignal = trial_data.EMGsignal_hams;
gastroc.EMGsignal = trial_data.EMGsignal_gastroc;
vasti.EMGtime = trial_data.EMGtime;
hams.EMGtime = trial_data.EMGtime;
gastroc.EMGtime = trial_data.EMGtime;
vasti.angle_enc = trial_data.angle_enc;
hams.angle_enc = trial_data.angle_enc;
gastroc.angle_enc = trial_data.angle_enc;
vasti.frequency = 1/(trial_data.EMGtime(2) - trial_data.EMGtime(1));
hams.frequency = 1/(trial_data.EMGtime(2) - trial_data.EMGtime(1));
gastroc.frequency = 1/(trial_data.EMGtime(2) - trial_data.EMGtime(1));
vasti.initial_time = trial_data.EMGtime(1);
hams.initial_time = trial_data.EMGtime(1);
gastroc.initial_time = trial_data.EMGtime(1);
vasti.initial_angle = 0;
hams.initial_angle = 0;
gastroc.initial_angle = 0;

vasti.B_tendon = 100*vasti.B_tendon;
hams.B_tendon = 100*hams.B_tendon;
gastroc.B_tendon = 100*gastroc.B_tendon;
if vasti.EMGgain > 1
    vasti.B_tendon = 100*vasti.B_tendon*vasti.EMGgain;
end
if hams.EMGgain > 1
    hams.B_tendon = 100*hams.B_tendon*hams.EMGgain;
end
if gastroc.EMGgain > 1
    gastroc.B_tendon = 100*gastroc.B_tendon*gastroc.EMGgain;
end

[assistance_vasti,time] = NMMmodel2(vasti);
[assistance_hams,~] = NMMmodel2(hams);
[assistance_gastroc,~] = NMMmodel2(gastroc);

commanded_torque = assistance_vasti + assistance_hams + assistance_gastroc;
sim_time = time;

end