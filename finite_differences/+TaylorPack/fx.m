function fx = fx(eqn,x,n)

switch (eqn)
    
    case(1)
        fx = sin_fx(x,n);
        
    case(2)
        fx = tan_fx(x,n);
        
    case(3)
        fx = log_fx(x,n);
        
    case(4)
        fx = exp_fx(x,n);
        
    case(5)
        fx = sqrt_fx(x,n);
    
end %swtich

function fx = sin_fx(x,n)

if (mod(n,4) == 0)
    
    fx = sin(x);
    
elseif (mod(n,4) == 1)
    
    fx = cos(x);
    
elseif (mod(n,4) == 2)
    
    fx = -sin(x);
    
else %if (mod(n,4) == 3)
    
    fx = -cos(x);
    
end %if


function fx = tan_fx(x,n)

bn = zeros(n+1,n+2);

bn(1,1:2) = [0 1];
for in=2:n+1
    
    bn(in,1) = bn(in-1,2);
    bn(in,in+1) = factorial(in-1);
    for ik=2:in
        bn(in,ik) = (ik-2)*bn(in-1,ik-1) + (ik)*bn(in-1,ik+1);
    end %for

end %for

fx = bn(n+1,1);
for ik=2:n+2
    fx = fx + bn(n+1,ik)*(tan(x).^(ik-1));
end %for:).*(tan(x).^[0:n]);


function fx = sqrt_fx(x,n)

if n == 0
    fx = sqrt(1+x);
elseif n == 1
    fx = 0.5/sqrt(1+x);
else
    fx = (prod(3-2*(2:n))*(1+x).^((2*n-1)/2))/(2^n);
end %if


function fx = exp_fx(x,~)

fx = exp(x);

function fx = log_fx(x,n)

if n == 0
    fx = log(1+x);
else
    fx = ((-1)^(n-1))*factorial(n-1)*(1+x).^(-n);
end %if