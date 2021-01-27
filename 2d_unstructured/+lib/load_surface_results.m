function surf = load_surface_results(surf_file)

fh = fopen(surf_file,'r');
if fh < 0
    error('unstructured2d:load_surface_results',['Unable to open results file for reading: ',surf_file]);
end %if

C = textscan(fh,'%f %f %f %f','HeaderLines',4);

fclose(fh);

% surf.x = C{1};
% surf.y = C{2};
% surf.mach = C{3};
% surf.cp = C{4};


surf.cp = zeros(size(C{1},1),1);
surf.mach = surf.cp;
surf.x = surf.cp;
surf.y = surf.cp;

surf.x(1) = C{1}(1);
surf.y(1) = C{2}(1);
surf.mach(1) = C{3}(1);
surf.cp(1) = C{4}(1);
j = 2;
for i=1:size(C{1},1)
%     i,j
    if C{3}(i) == surf.mach(j-1) && ...
       C{4}(i) == surf.cp(j-1)
   
       continue;
       
    else
        
        surf.x(j) = C{1}(i);
        surf.y(j) = C{2}(i);
        surf.mach(j) = C{3}(i);
        surf.cp(j) = C{4}(i);
        
        j = j + 1;
        
    end %if
    
    
end %for

surf.x = surf.x(1:j-1);
surf.y = surf.y(1:j-1);
surf.mach = surf.mach(1:j-1);
surf.cp = surf.cp(1:j-1);

end %function