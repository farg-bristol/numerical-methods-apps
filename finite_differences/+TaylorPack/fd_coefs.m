function [coefs, s] = fd_coefs(diffMode,order,nPts)

% Calculate stencil coefficients
if diffMode == 1
    % Central
    
%     nPts = 2*floor((diffN+1)/2) - 1 + order;
    p = (nPts-1)/2;
    s = -p:p;
    
elseif diffMode == 2
    % Forward
    
%     nPts = diffN + order;
    s = 0:(nPts-1);
    
else %if diffMode == 3
    % Backward
    
%     nPts = diffN + order;
    s = (1-nPts):0;
    
end %if

M = zeros(nPts,nPts);
    
for i=1:nPts
    M(i,:) = s.^(i-1);
end %for

RHS = zeros(nPts,1);
RHS(order+1) = factorial(order);

coefs = (M\RHS)';