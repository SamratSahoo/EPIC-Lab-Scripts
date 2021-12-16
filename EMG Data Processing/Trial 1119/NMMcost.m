function cost = NMMcost(x,param_names,param_norm_factor,trial_data,max_torque,plotOn)
%run the NMM with parameters from the optimizer

load('NMMparams_default.mat','default') %vasti_,hams_,gastroc_
pause(rand(1)*5)

params = default;
for ii = 1:length(param_names)
    if ~istable(x)
        params.(param_names{ii}) = x(ii)*param_norm_factor(ii);
    else
        params.(param_names{ii}) = x{1,ii}*param_norm_factor(ii);
    end
end

% if params.vasti_EMGgain > 1
%     params.vasti_B_tendon = params.vasti_B_tendon*3*params.vasti_EMGgain;
% end
% if params.hams_EMGgain > 1
%     params.hams_B_tendon = params.hams_B_tendon*3*params.hams_EMGgain;
% end
% if params.gastroc_EMGgain > 1
%     params.gastroc_B_tendon = params.gastroc_B_tendon*3*params.gastroc_EMGgain;
% end

[commanded_torque,sim_time] = NMMrun(params,trial_data);
commanded_torque2 = commanded_torque.*max_torque./max(abs(commanded_torque)); %limit peak torque to 20 Nm
if ~plotOn
    [JCF,time] = JRFforprofile4(sim_time,commanded_torque2);
    cost = trapz(time,JCF)./(time(end) - time(1));

    fprintf('iteration\n')
    fprintf('Cost: %f \n', cost)
else
    actual_torque = trial_data.moment;
    actual_time = trial_data.time;
    figure;
    gc_sim = segment_data(commanded_torque2',sim_time',trial_data.tref_force);
    gc_act = segment_data(actual_torque,actual_time,trial_data.tref_force);
    ens_avg_cyc_k({gc_act.data},1,1)
    hold on
    ens_avg_cyc_k({gc_sim.data},1,2)
    ylabel('Torque (Nm)')
    xlabel('Gait Cycle (%)')
    legend ('actual', 'simulated')
    cost = -1;
end

end