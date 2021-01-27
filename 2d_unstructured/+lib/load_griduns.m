function grid = load_griduns(grid_file)

    fh = fopen(grid_file,'r');
    if fh < 0
        error('unstructured2d:load_griduns',['Unable to open grid file for reading: ',grid_file]);
    end %if
    
    grid.ncell = fscanf(fh,'%d',1);
    grid.nedge = fscanf(fh,'%d',1);
    grid.nvert = fscanf(fh,'%d',1);
    
    grid.edges = zeros(grid.nedge,2);
    grid.cell_left = zeros(grid.nedge,1);
    grid.cell_right = zeros(grid.nedge,1);
    
    for i=1:grid.nedge
        
        grid.edges(i,:) = fscanf(fh,'%d',2);
        
        grid.cell_left(i) = fscanf(fh,'%d',1);
        grid.cell_right(i) = fscanf(fh,'%d',1);
        
    end %for
    
    grid.vertices = zeros(grid.nvert,2);
    
    for i=1:grid.nvert
        
        a = fscanf(fh,'%d',1);
        grid.vertices(i,:) = fscanf(fh,'%f',2);
        
    end %for
    
    fclose(fh);

end %function