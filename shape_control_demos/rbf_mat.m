function mat = rbf_mat(Xcp,Xeval,SR)
%% Generate an RBF basis matrix
%
%
% Laurence Kedward 2021

% Function for Euclidian distance normalised by support radius
r = @(dx) sqrt(sum(dx.*dx,2))/SR;

% Define our rbf function (Wendland's C2)
rbf = @(dx) (r(dx)<=1).*((1-r(dx)).^4).*(4*r(dx)+1);

Ncp = size(Xcp,1);
Neval = size(Xeval,1);

mat = zeros(Neval,Ncp);

for i=1:Neval
    
    for j=1:Ncp
        
        dx = Xcp(j,:) - Xeval(i,:);
        
        mat(i,j) = rbf(dx);
        
    end %for
    
end %for


