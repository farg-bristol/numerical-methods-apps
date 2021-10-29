%% Inputs
npts = 100;
nstep = 20000;
alpha = 1;

%% Discretisation
dx = 1/npts;
dt = dx*dx/alpha/4;

[X,Y] = meshgrid(linspace(0,1,npts),linspace(0,1,npts));

%% Initialise arrays
ERROR = zeros(npts,npts);
u = zeros(npts,npts);

f = gcf; set(f,'WindowStyle','docked');
u_new = u;

%% Main time-stepping loop
for n=1:nstep
    
    % Apply boundary conditions
    u(1,:) = 1;
    u(:,1) = 1;
%     u(end,:) = u(end-1,:);
%     u(:,end) = u(:,end-1);

    % Loop over grid points
    for i=2:npts-1
        for j=2:npts-1
            
            % Approximate spatial derivatives at position i,j
            dudx2 = ( u(i-1,j) - 2*u(i,j) + u(i+1,j) )/(dx^2);
            dudy2 = ( u(i,j-1) - 2*u(i,j) + u(i,j+1) )/(dx^2);
            
            ERROR(i,j) = alpha*(dudx2 + dudy2);

            u_new(i,j) = u(i,j) + dt*ERROR(i,j);

        end %for
    end %for
    
    residual = sqrt(sum(ERROR.^2,'all'));
    
    % Update u
    u = u_new;
    
    % Plotting
    if mod(n,100) == 0
        if ~ishghandle(f);  break; end %if
        contourf(X,Y,u_new);
        title(['Step ',num2str(n),' (t=',num2str(n*dt,'%10.6f'),') \newline',...
            'Residual = ',num2str(residual,'%6.2E')])
        pause(0.01);
    end %if
    
end %for