function eqstr = taylor_equation(n)

eqstr = 'f(x) \approx ';
eqstr = [eqstr, 'f(x_0)'];
for i=1:min(n,5)
    if (i==1)
        eqstr = [eqstr, '+f''(x_0)(x-x_0)'];
    else
        eqstr = [eqstr, '+\frac{f^{(',num2str(i),')}(x_0)}'];
        eqstr = [eqstr, '{',num2str(i),'!}(x-x_0)^',num2str(i)];
    end %
end %for
if n>5
    eqstr = [eqstr, '+...'];
end %if