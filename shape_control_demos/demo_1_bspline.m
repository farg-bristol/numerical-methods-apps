function demo_1_bspline()
%% Interactive demo for B-Spline for constructive shape control
%
%  ABOUT:
%   The B-Spline parameterises a curve by generating smooth
%   continuous functions for the x and y coordinates as functions of some
%   independent parameter.
%
%   Unlike the RBF volume spline which parameterises displacements to an
%   initial aerofoil, the B-Spline curve directly generates the coordinates
%   of the aerofoil. This is called a constructive parameterisation.
%
% Laurence Kedward 2021

order = 3;
Npts = 300;  % Number of points on aerofoil
Ncp = 10;    % Number of spline control points
[x,y] = naca(0,0,12,Npts);

% B-Spline basis (interpolation) matrix
Nmat = simple_af_spline(x,y,Ncp,order);

% Least-squares spline fitting
CP = Nmat\[x', y'];

% Checking fitting error
error = Nmat*CP(:,2) - y';
disp('--- B-Spline fitting error ---');
disp(['   RMS: ',num2str(sqrt(sum(error.*error)/Npts),'%.4e')]);
disp(['   MAX: ',num2str(max(error),'%.4e')]);

% Plot the aerofoil surface
figure;
C0 = plot(x,y,'.-');hold on;
xlim([-0.2 1.2]); ylim([-0.07 0.07]); axis equal;

% Plot the control points
plot_draggable(CP(:,1),CP(:,2),'-ro',@(x,y) dragmarker(x,y,Nmat,C0));


function dragmarker(x,y,Nmat,C0)
%% Function to update aerofoil surface when control points move

C0_new = Nmat*[x',y'];
set(C0,'XData',C0_new(:,1));
set(C0,'YData',C0_new(:,2));

end

end %function