function plot_results(field,grid,varargin)

cdata = zeros(grid.ncell,1);
cvdata = zeros(grid.nvert,1);
vert_ncell = zeros(grid.nvert);
for i=1:grid.ncell

    cdata(i,1) = field(i);
    
    for j=1:size(grid.cell_verts,2)
        
        if isnan(grid.cell_verts(i,j))
            break;
        end %if
        
        cvdata(grid.cell_verts(i,j)) = cvdata(grid.cell_verts(i,j)) + cdata(i,1);
        vert_ncell(grid.cell_verts(i,j)) = vert_ncell(grid.cell_verts(i,j)) + 1;
        
    end %for
    
end %for

for i=1:grid.nvert
    
    cvdata(i) = cvdata(i)/vert_ncell(i);
    
end %for


colormap(lib.brewermap([],'RdYlBu'));
patch('Vertices',grid.vertices,'Faces',grid.cell_verts,'FaceColor','interp', ...
    'EdgeColor','none','FaceVertexCData',cvdata);

end %function 