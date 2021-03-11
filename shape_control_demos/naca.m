function [x,y] = naca(m,p,tc,n)
%% Generate naca 4-series aerofoil points with sharp trailing edge
%
%   Uses a 'cosine' x distribution
%
% Laurence Kedward 2016

n1 = n/2 + 1;

m = m/100;
p = p/10;
tc = tc/100;

x = cosine_x(n1);

yt = naca_yt(x,tc);

ip = find(x<=p,1,'last');

if p~=0     % Check for symmetric case
    dyc = zeros(1,n1);
    dyc(1:ip) = 2*m*(p-x(1:ip))/(p^2);
    dyc(ip+1:end) = 2*m*(p-x(ip+1:end))/((1-p)^2);

    theta = atan(dyc);
    
    yc = zeros(1,n1);
    yc(1:ip) = m*(2*p*x(1:ip) - x(1:ip).^2)/(p.^2);
    yc(ip+1:end) = m*((1-2*p) + 2*p*x(ip+1:end) - x(ip+1:end).^2)/((1-p).^2);
else
   theta = zeros(1,n1);
   yc = zeros(1,n1);
end



xu = x - yt.*sin(theta);
yu = yc + yt.*cos(theta);

xl = x + yt.*sin(theta);
yl = yc - yt.*cos(theta);

x = [ flip(x(2:end)), x(1:end-1) ];
y = [ flip(yl(2:end)), yu(1:end-1) ];

end

function x = cosine_x(n)
theta = linspace(0,pi,n);
x = (1 - cos(theta))/2;
end

function yt = naca_yt(x,tc)
xs = sqrt(x);
yt = 5*tc*(0.2969*xs - 0.126*xs.^2 - 0.3516*xs.^4 + 0.2843*xs.^6 - 0.1036*xs.^8);
end