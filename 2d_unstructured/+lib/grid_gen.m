function grid_gen(run_dir,boundaries,varargin)

defaults.imax = 3;
defaults.jmax = 3;
defaults.wallbot = 0;
defaults.walltop = 0;
defaults.botleft = [-24.5 -25.0];
defaults.topright = [25.5 25.0];
defaults.offset = 1;
defaults.nlev = 12;

config = lib.parseOptions(defaults,varargin{:});

if iscell(boundaries)
else
    boundaries = {boundaries};
end %if

boundaries = lib.reorientate_boundaries(boundaries);

spool_boundaries(boundaries,[run_dir,filesep,'boundary.dat']);

spool_settings([run_dir,filesep,'cutsettings'],config);

spool_memalloc([run_dir,filesep,'memalloc']);

run_mesher(run_dir);

end  %function

function run_mesher(workDir)

    [stat,out] = lib.run_binary('cartcell',workDir,true);

    if stat ~= 0
        disp(out);
        error('unstructured2d:grid_gen:run_mesher',['Error while calling cartcell']);
    end %if
    
end %function

function spool_memalloc(file)

    fh = fopen(file,'w');
    if fh < 0
        error('unstructured2d:grid_gen:spool_memalloc',['Unable to open memalloc file for writing: ',file]);
    end %if

    fprintf(fh,'%d\n',200000); % Max total edges
    fprintf(fh,'%d\n',200000); % Max total points
    fprintf(fh,'%d\n',100); % Max edges per cell
    fprintf(fh,'%d\n',5000); % Max total intersects
    fprintf(fh,'%d\n',100); % Max background edge cuts
    fprintf(fh,'%d\n',1000); % Max surface cuts
    fprintf(fh,'%d\n',50000); % Max cells
    fprintf(fh,'%d\n',20); % Max edges meeting at a point
    
    fclose(fh);

end %function

function spool_settings(file,s)
% imax jmax wallbot walltop
% botleft(1) botleft(2)
% topright(1) topright(2)
% offset   (add small random offset)
% nlevel
% level, nbuf(j)


    fh = fopen(file,'w');
    if fh < 0
        error('unstructured2d:grid_gen:spool_settings',['Unable to open config file for writing: ',file]);
    end %if

    fprintf(fh,'%d %d %d %d\n',s.imax,s.jmax,s.wallbot,s.walltop);
    fprintf(fh,'%20.15f %20.15f\n',s.botleft);
    fprintf(fh,'%20.15f %20.15f\n',s.topright);
    fprintf(fh,'%d\n',s.offset);
    fprintf(fh,'%d\n',s.nlev);

    for i=1:s.nlev

        if (i == (s.nlev-2))
            ref = 7;
        elseif (i == (s.nlev-1))
            ref = 10;
        else
            ref = 5;
        end %if

        fprintf(fh,'%d %d\n',i,ref);

    end %for

    fclose(fh);

end %function


function spool_boundaries(boundaries,file)
% nsurf
% total_edge, total_pt
% npt_surf_i
% x y
% ... (x npt_surf_i)
% boundaries are closed by mesher

    nsurf = length(boundaries);

    npt = 0;
    for i=1:nsurf

        npt = npt + size(boundaries{i},1);

    end %for


    fh = fopen(file,'w');
    if fh < 0
        error('unstructured2d:grid_gen:spool_boundaries',['Unable to open config file for writing: ',file]);
    end %if

    fprintf(fh,'%d\n',nsurf);
    fprintf(fh,'%d %d\n',npt,npt);

    for i=1:nsurf

        fprintf(fh,'%d\n',size(boundaries{i},1));

        fprintf(fh,'%20.15f %20.15f\n',boundaries{i}');

    end %for
    
    fclose(fh);

end %function