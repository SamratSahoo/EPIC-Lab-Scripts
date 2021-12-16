function [assistance,time] = NMMmodel2(params)
%% NMM model

%fixed parameters
frequency = params.frequency; % 200 (Hz)
EMGdelay = params.EMGdelay; % 0 (s)  - EMG
Tact = params.Tact; %0.01 (s) - Activation Dynamics
Tdeact = params.Tdeact; %0.04 (s) - Activation Dynamics
Fmax = params.Fmax; %5000 (N) - Tendon Dynamics, Active Muscle Dynamics
tendon_length_slack = params.tendon_length_slack; %0.135166 (m) - Tendon Dynamics
tendon_stiffness = params.tendon_stiffness; %Fmax/0.049 (N/m) - Tendon Dynamics
optimal_fiber_length = params.optimal_fiber_length; %0.124679 (m) - Active Muscle Dynamics
a = params.a; %3.1108 (FL relationships) - Active Muscle Dynamics
b = params.b; %.8698 (FL relationships) - Active Muscle Dynamics
B = params.B; %5.31 (passive relationships) - Passive Muscle Dynamics
lever_arm = params.lever_arm; %0.0475 (m) - MTU Length
B_tendon = params.B_tendon; %2750 (N*s/m) tendon damping
EMGgain = params.EMGgain; %0.8 runs from 0 to 1 where 1 is complete EMG and 0 is no EMG  - EMG
s = params.s; %.3914 (FL relationships) - Active Muscle Dynamics
A = params.A; %2.38*10^(-2) (passive relationships) - Passive Muscle Dynamics
Vmax = params.Vmax; %-10*optimal_fiber_length (m/s) - Active Muscle Dynamics

assistance_pct = params.assistance_pct;

%initial calculations
iteration_time = 1/frequency; %(s)
MTU_slack_length = tendon_length_slack + optimal_fiber_length;

%initialize starting states
previous_activation = 0;
previous_muscle_force = 0;
previous_muscle_length = optimal_fiber_length;
previous_MTU_length = MTU_slack_length;
previous_tendon_length = tendon_length_slack;

%inputs 
EMGsignal = params.EMGsignal; % sampled at frequency set above
angle_enc = params.angle_enc; %.*pi./180 (rad) sampled at frequency set above - is flexion
initial_time = params.initial_time; %(s)
initial_angle = params.initial_angle;

for iteration = 1:length(EMGsignal)
    
current_time = iteration_time*iteration;

%% EMG
delay_time = current_time - EMGdelay;
delay_iter = floor(delay_time/iteration_time);

activation = EMGsignal(iteration)*EMGgain;

%EMG thresholds
if activation > 1
    activation = 1;
elseif activation < 0
    activation = 0;
end

%% Activation Dynamics
%Equation is taken from Zajac (1989) Eq. 1
ratioB=Tact/Tdeact;
derivative_act= activation/Tact - (1/Tact*(ratioB+(1-ratioB)*activation))*previous_activation;
activation = derivative_act*iteration_time; %integrate
previous_activation = activation; %reset feedback

%% Muscle Length
muscle_length = previous_MTU_length - previous_tendon_length;

%% Active Muscle Dynamics
muscle_velocity = (muscle_length - previous_muscle_length)/iteration_time; %derivative of length

%Hill Type Muscle F-V relationship.  Returns a normalized force-velocity value
if (muscle_velocity < Vmax)
    norm_force_velocity=0;
else
    if (muscle_velocity >= Vmax && muscle_velocity < 0)
        norm_force_velocity = ((1-(muscle_velocity/Vmax))/(1+(muscle_velocity/0.17/Vmax)));
    else
        norm_force_velocity =(1.8-0.8*((1+(muscle_velocity/Vmax))/(1-7.56*muscle_velocity/0.17/Vmax)));
    end
end
    
%Active muscle F-L relationships.  Returns a normalized F-L value

if muscle_length < 0
    muscle_length = 0;
end
norm_force_length = exp(-(abs(((muscle_length/optimal_fiber_length)^b-1)/s))^a);

%Total active force of muscle based on normalized F-V and F-L relationships
active_muscle_force(iteration) = Fmax* activation * norm_force_velocity * norm_force_length;

%% Passive Muscle Dynamics
% Passive CE F_L taken from Rubenson et. al.
if muscle_length >= optimal_fiber_length   
    %old passive_muscle_force=
    %Fmax*A*exp(B*((muscle_length/optimal_fiber_length)-1)); len>0
    passive_muscle_force = Fmax*A*(exp(B*((muscle_length/optimal_fiber_length)-1))-1);
else
    passive_muscle_force=0;
end
%% Muscle Force
if delay_iter < iteration_time
    muscle_force = passive_muscle_force;
else
    muscle_force = active_muscle_force(delay_iter) + passive_muscle_force;
end

%% MTU Length
%check how measuring initial angle to see if +or-
MTU_length = (-angle_enc(iteration) + initial_angle)*lever_arm + MTU_slack_length;

%% Tendon Dynamics
% Lichtwark, G.A. and Wilson, A.M., 2008. Journal of theoretical biology, 252(4), pp.662-673.
% no damping
%    change_tendon_length = (previous_muscle_force + (Fmax*log((-9*exp(-(20*previous_muscle_force)/Fmax)) + 10))/20)/tendon_stiffness;
%    tendon_length = change_tendon_length + tendon_length_slack;
% With damping
    change_tendon_length = (muscle_force - tendon_stiffness*(previous_tendon_length-tendon_length_slack))/B_tendon*iteration_time;
    tendon_length = change_tendon_length + previous_tendon_length;
    
%% Update parameters for next iteration
previous_muscle_length = muscle_length;
previous_tendon_length = tendon_length;
previous_muscle_force = muscle_force;
previous_MTU_length = MTU_length;

%% Contribution to joint torque
%use lever arm from above
extension_torque = muscle_force*lever_arm;
assistance (iteration) = extension_torque*assistance_pct;
end

time = [1:length(EMGsignal)].*iteration_time + initial_time;
%new_time = time + delay2;
%assistance = interp1(new_time,assistance,time,'spline',0);
%plot(time,assistance)

end