function x = point_dist(npts,lb,ub,x0)

dx = (ub-lb)/npts;

x1 = linspace(lb,x0-dx,npts/2);
x2 = x0 - 10.^(-1:-1:-2);
x3 = x0 + 10.^(-2:-1);
x4 = linspace(x0+dx,ub,npts/2);



x = [x1, x2, x0, x3, x4];
x = sort(x);