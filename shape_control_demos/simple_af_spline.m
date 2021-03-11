function Nmat = simple_af_spline(x,y,Ncp,order)
%% Wrapper function to spline a closed-loop aerofoil
%
%
% Laurence Kedward 2021

% Input curve knots, u
%  (Parameterised by arc distance in a normalised space)
AR = 0.5*(max(x)-min(x))/(max(y)-min(y));
du = sqrt( diff(x./AR).^2 + diff(y).^2 );
u = [0, cumsum(du)]/sum(du);

% Control point knots, v
%  (uniform distribution)
v = linspace(0,1,2+Ncp-order);

% Generate spline matrix
%  (Evaluates spline defined by knots v at knots u)
Nmat = splineMat(u, v, order);

% Remove repeated TE point in control points
Nmat(:,1) = Nmat(:,1) + Nmat(:,end);
Nmat = Nmat(:,1:end-1);

% Evaluation of last point equal to evaluation of first point (TE point)
Nmat(end,:) = Nmat(1,:);