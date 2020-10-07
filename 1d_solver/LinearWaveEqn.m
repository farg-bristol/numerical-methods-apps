classdef LinearWaveEqn
    %% Implements time-marching relations for the 1D linear wave eqn
    %
    % Laurence Kedward, October 2020
    
    methods(Static)
        
        function eqn = latex_eqn()
            %%
            
            eqn = '$\frac{\partial u}{\partial t}';
            eqn = [eqn, ' + c\frac{\partial u}{\partial x} = 0$'];
            
        end %function
        
        
        function dt = timestep(CFL,wavespeed,dx)
            %%
            dt = CFL*dx/abs(wavespeed);
            
        end %function
        
        
        function [u_new, dt] = update_u(u,c)
            %%
            
            npts = size(u,1);
            
            if c.wavespeed > 0
                u(1) = 0;
                u(end) = u(end-1);
            else
                u(1) = u(2);
                u(end) = 0;
            end %if
            
            u_new = u;
            
            dt = LinearWaveEqn.timestep(c.CFL,c.wavespeed,c.dx);
            
            for i=2:(npts-1)
                
                if c.artificial_dissipation
                    ad = -0.5*(u(i+1) - 2*u(i) + u(i-1))/c.dx;
                else
                    ad = 0;
                end %if
                
                switch (c.scheme)
                    
                    case ('FTCS')
                        
                        u_new(i) = u(i) - 0.5*c.wavespeed*dt*(u(i+1)-u(i-1))/c.dx - abs(c.wavespeed)*dt*ad;
                        
                    case ('FTBS')
                        
                        u_new(i) = u(i) - c.wavespeed*dt*(u(i)-u(i-1))/c.dx;
                        
                    case ('FTFS')
                        
                        u_new(i) = u(i) - c.wavespeed*dt*(u(i+1)-u(i))/c.dx;
                        
                    case ('UPWIND')
                        
                        % NOT IMPLEMENTED
                        error('NOT IMPLEMENTED: I''m off to the pub; the upwind implementation is left as an exercise for the user.')
                        
                end %switch
                
            end %for
            
            
            
        end %function
        
        
        function u_exact = exact_solution(x,init,wavespeed,t)
           %% 
            
            u_exact = init_conditions(x - wavespeed*t,init);
            
        end %function
        
    end %methods
    
    
end %classde

