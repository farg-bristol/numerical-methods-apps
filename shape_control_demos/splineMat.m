function Nmat = splineMat(dataKnots, splineKnots, order)
%% Generate B-Spline basis matrix with interpolating ends
%
% Original by: Dominic Masters 2016

splineKnots = [zeros(1,order) , splineKnots, ones(1,order)];
L = length(splineKnots) - (1+ order);

Nmat = zeros(length(dataKnots),L);
for i=1:L
    Nmat(:,i) = N(i-1,order,dataKnots, splineKnots);
end

end





%% Recursive basis function generator
function Z = N(i,p,u,U)  % from dom
i = i+1;
if p==0
   % Z=zeros(1,length(u));
    for j=1:length(u);
        if j==length(u)
            if u(j)>=U(i) && u(j)<=U(i+1)
                Z(j)=1;
            else
                Z(j) = 0;
            end
        else
            if u(j)>=U(i) && u(j)<U(i+1)
                Z(j)=1;
            else
                Z(j)=0;
            end
        end
    end
else
        
        t1n = (u-U(i));
        t1d = (U(i+p)-U(i));
        t2n = (U(i+p+1)-u);
        t2d = (U(i+p+1)-U(i+1));
        
        b1 = N(i-1,p-1,u,U);
        b2 = N((i+1)-1,p-1,u,U);
        
        if t1d ~= 0
            t1 = t1n/t1d;
        else
            t1 = 0;
        end
        
        if t2d ~= 0
            t2 = t2n/t2d;
        else
            t2 = 0;
        end
        
        Z = t1 .* b1 + t2 .* b2;
        
        
        
end
end