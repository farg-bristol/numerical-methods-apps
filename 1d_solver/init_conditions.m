function u0 = init_conditions(x,init)
%% Defines various initial conditions for 1D solver
%
% Laurence Kedward, October 2020

npts = length(x);

u0 = zeros(npts,1);

switch init
    
    case ('STEP')
        u0(x > 0.4 & x < 0.6) = 1;
      
    case ('RAMP')
        u0 = 1 - x';
        u0(x<0) = 0;
        
    case ('BUMP')
        Kb = 0.5; Kc = 0.05;
        u0 = exp(-((x'-Kb).^2)/(2*Kc*Kc));
    
    case ('SINE')
        u0 = sin(2*pi*x');
        u0(x<0) = 0;
        
end %switch