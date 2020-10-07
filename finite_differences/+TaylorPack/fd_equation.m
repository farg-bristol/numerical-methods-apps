function eqstr = fd_equation(diffN,coefs,s)

eqstr = '';
if (diffN==1)
    eqstr = [eqstr, 'f''(x_0)'];
else
    eqstr = [eqstr, 'f^{(',num2str(diffN),')}(x_0)'];
end %
    
eqstr = [eqstr, '\approx'];

eqstr = [eqstr, '\frac{1}{\Delta x']; 

if (diffN > 1)
    eqstr = [eqstr, '^',num2str(diffN),'']; 
end %if

eqstr = [eqstr, '}('];

for i=1:length(s)
    if abs(coefs(i)) > sqrt(eps)
        if coefs(i) > 0
            if i > 1
                sign_str = '+';
            else
                sign_str = '';
            end %if
        else
            sign_str = '-';
        end %if
        
        eqstr = [eqstr,sign_str];
        if abs(abs(coefs(i))-1) < sqrt(eps)
            eqstr = [eqstr, 'x_{',num2str(s(i),'%+i'),'}']; 
        else
            [N,D] = rat(abs(coefs(i)));
            if D == 1
                coef_str = num2str(N);
            else
                coef_str = ['\frac{',num2str(N),'}{',num2str(D),'}'];
            end %if
            eqstr = [eqstr, coef_str,'x_{',num2str(s(i),'%+i'),'}']; 
        end %if
    end %if
end %for

eqstr = [eqstr, ')'];