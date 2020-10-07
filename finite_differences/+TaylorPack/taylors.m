function y = taylors(fcn,x0,x,n)


y = zeros(size(x));

for i=0:n
    
    an = fcn(x0,i);

    y = y + an.*((x-x0).^i)./(factorial(i));
    
end %for