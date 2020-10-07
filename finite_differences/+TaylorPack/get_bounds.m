function [lb, ub] = get_bounds(eqn)

switch (eqn)
    
    case(1) %sin
        lb = -2*pi;
        ub = 2*pi;
        
    case(2) %tan
        lb = -0.9*pi/2;
        ub = 0.9*pi/2;
        
    case(3) %log
        lb = 0;
        ub = 2;
        
    case(4) %exp
        lb = -3;
        ub = 3;
        
    case(5) %sqrt
        lb = 0;
        ub = 5;
    
end %swtich