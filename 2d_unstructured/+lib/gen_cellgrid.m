function grid = gen_cellgrid(grid)

    grid.cell_nedge = zeros(grid.ncell,1);
    
    for pass=1:2
        
        grid.cell_nedge(:) = 0;
        
        for i=1:grid.nedge
            
            cl = grid.cell_left(i);
            cr = grid.cell_right(i);
                
            if cl > 0
                grid.cell_nedge(cl) = grid.cell_nedge(cl) + 1;
            end %if

            if cr > 0
                grid.cell_nedge(cr) = grid.cell_nedge(cr) + 1;
            end %if
                
            if pass == 2
                
                if cl > 0
                    grid.cell_edges(cl,grid.cell_nedge(cl)) = i;
                end %if
                
                if cr > 0
                    grid.cell_edges(cr,grid.cell_nedge(cr)) = i;
                end %if
                
            end %if
            
        end %for
        
        if pass == 1
            
            grid.cell_edges = NaN(grid.ncell,max(grid.cell_nedge));
            
        end %if
        
    end %for
    
    grid.cell_verts = NaN(grid.ncell,max(grid.cell_nedge));
    
    vert_verts = zeros(grid.nvert,2);
    vert_visited = zeros(grid.nvert,1);
    
    for i=1:grid.ncell
         
        edges = grid.edges(grid.cell_edges(i,1:grid.cell_nedge(i)),:);
        
        cell_verts = unique(edges);
        
        grid.cell_verts(i,1:size(cell_verts,1)) = cell_verts';
        
        vert_verts(:) = 0;
        vert_visited(:) = 0;
        
        % Per-loop vertex connectivity
        for j=1:grid.cell_nedge(i)
            
            v1 = edges(j,1);
            v2 = edges(j,2);
            
            if vert_verts(v1,1) > 0
                vert_verts(v1,2) = v2;
            else
                vert_verts(v1,1) = v2;
            end %if
            
            if vert_verts(v2,1) > 0
                vert_verts(v2,2) = v1;
            else
                vert_verts(v2,1) = v1;
            end %if
            
        end %for
        
        % Build-up loop in order
        ii = 1;
        j = edges(1,1);
        while 1==1
            
            vert_visited(j) = true;
            
            grid.cell_verts(i,ii) = j;
            
            next = vert_verts(j,1);
            if vert_visited(next)
                next = vert_verts(j,2);
            end %if
            if vert_visited(next)
                break;
            end %if
            j = next;
            
            ii = ii + 1;
        end %while

    end %for
    
%     figure;patch('Vertices',grid.vertices,'Faces',grid.cell_verts,'FaceColor','white');
    
end %function