classdef InviscidBurgersEqn
    %% Implements time-marching relations for the 1D inviscid Burgers eqn
    %
    % Laurence Kedward, October 2020
    
    methods(Static)
        
        function eqn = latex_eqn()
            %%
            
            eqn = '$\frac{\partial u}{\partial t}';
            eqn = [eqn, ' + \frac{\partial \frac{1}{2} u^2}{\partial x} = 0$'];
            
        end %function
        
        
        function dt = timestep(CFL,u,dx)
            %% Global time-stepping - use smallest timestep across grid
            
            wavespeeds = 0.5*(u(1:end-1)+u(2:end));
            
            dt = min( CFL*dx./abs(wavespeeds) );
            
        end %function
        
        
        function [u_new, dt] = update_u(u,c)
            %%
            
            npts = size(u,1);
            
            if 0.5*(u(1) + u(2)) > 0
                u(1) = 0;
            else
                u(1) = u(2);
            end %if
            
            if 0.5*(u(end-1) + u(end)) > 0
                u(end) = u(end-1);
            else
                u(end) = 0;
            end %if
            
            u_new = u;
            
            dt = InviscidBurgersEqn.timestep(c.CFL,u,c.dx);
            
            for i=2:(npts-1)
                
                if c.artificial_dissipation
                    ad = -0.5*(u(i+1) - 2*u(i) + u(i-1))/c.dx;
                else
                    ad = 0;
                end %if
                
                switch (c.scheme)
                    
                    case ('FTCS')
                        
                        u_new(i) = u(i) - 0.5*dt*(0.5*u(i+1)^2-0.5*u(i-1)^2)/c.dx - 0.5*abs(u(i+1)+u(i-1))*dt*ad;
                        
                    case ('FTBS')
                        
                        u_new(i) = u(i) - dt*(0.5*u(i)^2-0.5*u(i-1)^2)/c.dx;
                        
                    case ('FTFS')
                        
                        u_new(i) = u(i) - dt*(0.5*u(i+1)^2-0.5*u(i)^2)/c.dx;
                        
                    case ('UPWIND')
                        
                        % NOT IMPLEMENTED
                        error('NOT IMPLEMENTED: I''m off to the pub; the upwind implementation is left as an exercise for the user.')

                end %switch
                
            end %for
            
            
        end %function
        
        
    end %methods
    
    
end %classde

