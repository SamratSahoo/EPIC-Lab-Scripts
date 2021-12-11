function [int_MF,previous_activation,previous_muscle_length,previous_MTU_length,previous_tendon_length,previous_muscle_force] = RT_MuscleF_model(EMG_matrix, norm_angle_enc,previous_activation,previous_muscle_length,previous_MTU_length,previous_tendon_length,previous_muscle_force,int_MF)
    %% Model for Muscle force (test on EMG)    
    %Model organization [VM, RF, VL, BF, ST, MG, LG]
    %fixed parameters
    lever_arm = [0.045,0.0507,0.0449,-0.0364,-0.0503,-0.0212,-0.0214]; %0.0475 (m) - MTU Length
    optimal_fiber_length = [0.089,0.114,0.084,0.109,0.201,0.060,0.064]; %0.124679 (m) - Active Muscle Dynamics
    tendon_length_slack = [0.126,0.310,0.157,0.326,0.2555,0.390,0.380]; %0.135166 (m) - Tendon Dynamics
    Fmax = [1294,1169,1871,896,410,1558,683]; %5000 (N) - Tendon Dynamics, Active Muscle Dynamics
    frequency = 200; % (Hz)
    Tact = 0.01; 
    Tdeact = 0.04;
    tendon_stiffness = Fmax./0.049;
    a = 3.1108;% (FL relationships) - Active Muscle Dynamics
    b = .8698;% (FL relationships) - Active Muscle Dynamics
    B = 5.31;% (passive relationships) - Passive Muscle Dynamics
    B_tendon = 2750; % (N*s/m) tendon damping
    EMGgain = 1;
    s = .3914; % (FL relationships) - Active Muscle Dynamics
    A = 2.38*10^-2; % (passive relationships) - Passive Muscle Dynamics
    Vmax = -10.*optimal_fiber_length; %(m/s) - Active Muscle Dynamics
    ratioB=Tact/Tdeact; % - Activation Dynamics
    
    %initial calculations
    iteration_time = 1/frequency; %(s)
    MTU_slack_length = tendon_length_slack + optimal_fiber_length;
    
    %initialize starting states
    if nargin < 8
        previous_activation = [0,0,0,0,0,0,0];
        previous_muscle_length = optimal_fiber_length;
        previous_MTU_length = MTU_slack_length;
        previous_tendon_length = tendon_length_slack;
        previous_muscle_force = 0;
        int_MF = 0;
    end
    
    norm_force_velocity = [0,0,0,0,0,0,0];
    
    for iteration = 1:size(EMG_matrix,1)
        %% EMG
        activation = EMG_matrix(iteration,:)*EMGgain;
        
        %EMG thresholds
        activation(activation > 1) = 1;
        activation(activation < 0) = 0;
        
        %% Activation Dynamics
        %Equation is taken from Zajac (1989) Eq. 1
        derivative_act= activation./Tact - (1/Tact.*(ratioB+(1-ratioB).*activation)).*previous_activation;
        activation = derivative_act.*iteration_time; %integrate
        previous_activation = activation; %reset feedback
        
        %% Muscle Length
        muscle_length = previous_MTU_length - previous_tendon_length;
        
        %% Active Muscle Dynamics
        muscle_velocity = (muscle_length - previous_muscle_length)./iteration_time; %derivative of length
        
        %Hill Type Muscle F-V relationship.  Returns a normalized force-velocity value
        norm_force_velocity(muscle_velocity < Vmax) = 0;
        eq1 = ((1-(muscle_velocity./Vmax))./(1+(muscle_velocity./0.17./Vmax)));
        norm_force_velocity(muscle_velocity >= Vmax & muscle_velocity < 0) = eq1(muscle_velocity >= Vmax & muscle_velocity < 0);
        eq2 = (1.8-0.8.*((1+(muscle_velocity./Vmax))./(1-7.56.*muscle_velocity./0.17./Vmax)));
        norm_force_velocity(muscle_velocity >= Vmax & muscle_velocity >= 0) = eq2(muscle_velocity >= Vmax & muscle_velocity >= 0);
        
        %Active muscle F-L relationships.  Returns a normalized F-L value
        
        muscle_length(muscle_length < 0) = 0;
        norm_force_length = exp(-(abs(((muscle_length./optimal_fiber_length).^b-1)./s)).^a);
        
        %Total active force of muscle based on normalized F-V and F-L relationships
        active_muscle_force = Fmax.* activation .* norm_force_velocity .* norm_force_length;
        
        %% Passive Muscle Dynamics
        % Passive CE F_L taken from Rubenson et. al.
        %old passive_muscle_force=
        %Fmax*A*exp(B*((muscle_length/optimal_fiber_length)-1)); len>0
        passive_muscle_force = [0,0,0,0,0,0,0];
        peq1 = Fmax.*A.*(exp(B.*((muscle_length./optimal_fiber_length)-1))-1);
        passive_muscle_force(muscle_length >= optimal_fiber_length) = peq1(muscle_length >= optimal_fiber_length);
        
        %% Muscle Force
        muscle_force = active_muscle_force + passive_muscle_force;
        
        %% MTU Length
        %check how measuring initial angle to see if +or-
        MTU_length = (-norm_angle_enc(iteration))*lever_arm + MTU_slack_length;
        
        %% Tendon Dynamics
        % Lichtwark, G.A. and Wilson, A.M., 2008. Journal of theoretical biology, 252(4), pp.662-673.
        % no damping
        %    change_tendon_length = (previous_muscle_force + (Fmax*log((-9*exp(-(20*previous_muscle_force)/Fmax)) + 10))/20)/tendon_stiffness;
        %    tendon_length = change_tendon_length + tendon_length_slack;
        % With damping
        change_tendon_length = (muscle_force - tendon_stiffness.*(previous_tendon_length-tendon_length_slack))./B_tendon.*iteration_time;
        tendon_length = change_tendon_length + previous_tendon_length;
            
        %% Update parameters for next iteration
        previous_muscle_length = muscle_length;
        previous_tendon_length = tendon_length;
        previous_MTU_length = MTU_length;
        
        %muscle_force_signal(iteration,:) = muscle_force;
        if previous_muscle_force == 0
            int_MF = 0;
        else
            int_MF = int_MF + iteration_time.*(muscle_force+previous_muscle_force)./2;
        end
        previous_muscle_force= muscle_force;
    end
    %time = [1:iteration].*iteration_time;
end