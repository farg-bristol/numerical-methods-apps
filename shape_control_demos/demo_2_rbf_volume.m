function demo_2_rbf_volume()
%% Interactive demo for RBF volume spline for deformative shape control
%
% ABOUT:
%  The volume spline interpolates the DISPLACEMENTS of control points
%  to produce displacements for the surface grid.
%
%  When you 'move' a volume spline control point, you are not moving it 
%  within the RBF interpolation, rather you are defining the (x,y)
%  displacements at that control point, which are used to define the
%  interpolating displacement function.
%  
% Laurence Kedward 2021


SR = 1;      % RBF support radius
nCol = 5;    % Number of chordwise control points
nRow = 2;    % Number of depthwise control points
Npts = 300;  % Number of points on aerofoil
[x,y] = naca(0,0,12,Npts);

limx = [-0.2 1.2];
limy = [-0.07 0.07];

nColbg = 15;
nRowbg = 5;

[Xbg, Ybg] = ndgrid(linspace(limx(1),limx(2),nColbg),linspace(limy(1),limy(2),nRowbg));
Xbg = reshape(Xbg,[numel(Xbg),1]);
Ybg = reshape(Ybg,[numel(Ybg),1]);

% Generate & plot background grid
figure;
Cgrid = mesh(reshape(Xbg,[nColbg,nRowbg]),reshape(Ybg,[nColbg,nRowbg]),zeros(nColbg,nRowbg));
hold on;view([0 90]);

% Generate & plot grid for RBF control points

K = 1;
[Xcp Ycp] = ndgrid(linspace(K*min(x),K*max(x),nCol),linspace(K*min(y),K*max(y),nRow));

Ncp = nCol*nRow;

Xcp = reshape(Xcp,[Ncp,1]);
Ycp = reshape(Ycp,[Ncp,1]);

plot(Xcp,Ycp,'x');

% Generate the interpolation matrix
Cmat = rbf_mat([Xcp,Ycp],[Xcp,Ycp],SR);

% Evaluation matrix for the aerofoil points
Amat = rbf_mat([Xcp,Ycp],[x',y'],SR);

% Evaluation matrix for the background grid
Amat_bg = rbf_mat([Xcp,Ycp],[Xbg,Ybg],SR);

% Global coupling matrix for the aerofoil points
Gmat = Amat*Cmat^-1;

% Global coupling matrix for the background grid
Gmat_bg = Amat_bg*Cmat^-1;

% Plot aerofoil
C0 = plot(x,y,'.-');
xlim(limx); ylim(limy); axis equal;

% Plot RBF control points
plot_draggable(Xcp,Ycp,'ro',@dragmarker);

function dragmarker(xcp,ycp)
%% Function to update aerofoil & background grid when control points move

Cx_new = x' - Gmat*(Xcp - xcp');
Cy_new = y' - Gmat*(Ycp - ycp');

set(C0,'XData',Cx_new);
set(C0,'YData',Cy_new);

Cx_bg = Xbg - Gmat_bg*(Xcp - xcp');
Cy_bg = Ybg - Gmat_bg*(Ycp - ycp');

set(Cgrid,'XData',reshape(Cx_bg,[nColbg,nRowbg]));
set(Cgrid,'YData',reshape(Cy_bg,[nColbg,nRowbg]));

end

end %function
