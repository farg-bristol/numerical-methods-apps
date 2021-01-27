function boundaries = reorientate_boundaries(boundaries)
    
    for i=1:length(boundaries)
        
        % Remove repeated TE point
        r = boundaries{i}(end,:) - boundaries{i}(1,:);
        r = sqrt(dot(r,r));

        if r < sqrt(eps)
            boundaries{i} = boundaries{i}(1:end-1,:);
        end %if
        
        % Reorientate
        if loop_area(boundaries{i}) < 0
            
            boundaries{i} = boundaries{i}(end:-1:1,:);
            
        end %if
        
    end %for

end %function


function a = loop_area(loop)

    dy = loop(2:end,2) - loop(1:end-1,2);
    x = 0.5*(loop(1:end-1,1) + loop(2:end,1));
    a = sum(x.*dy);

end %function



