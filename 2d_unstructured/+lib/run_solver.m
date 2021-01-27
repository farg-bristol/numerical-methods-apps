function [stat,out] = run_solver(run_dir,varargin)

defaults.restart = true;
defaults.aoa = 1.0;
defaults.mach = 0.5;
defaults.maxiter = 4000;
defaults.minres = -6;
defaults.refpoint = [0.25 0.00];
defaults.cfl = 2.0;
defaults.k1 = 1.0;
defaults.k2 = 0.05;
defaults.dsf = [1 0 0 0];
defaults.mg_level = 0;
defaults.mg_prolong_damp = 0.7;

config = lib.parseOptions(defaults,varargin{:});

spool_solver_config(run_dir,config);

if config.restart
    [stat,out] = lib.run_binary('edge2d -rp',run_dir,true);
else
    [stat,out] = lib.run_binary('edge2d -p',run_dir,true);
end %if

if nargout == 0 && stat ~= 0
    disp(out);
    error('unstructured2d:run_solver','Error while calling edge2d');
end %if

end  %function

function spool_solver_config(run_dir,config)


    fh = fopen([run_dir,filesep,'settings'],'w');
    if fh < 0
        error('unstructured2d:run_solver:spool_solver_config','Unable to open solver config file ("settings") for writing: ');
    end %if

    fprintf(fh,'aoa = %20.15g\n',config.aoa);
    fprintf(fh,'mach = %20.15g\n',config.mach);
    fprintf(fh,'maxiter = %d\n',config.maxiter);
    fprintf(fh,'minres = %d\n',config.minres);
    fprintf(fh,'refpoint = %20.15g %20.15g\n',config.refpoint);
    fprintf(fh,'cfl = %10.15g\n',config.cfl);
    fprintf(fh,'k1 = %20.15g\n',config.k1);
    fprintf(fh,'k2 = %20.15g\n',config.k2);
    %fprintf(fh,'dsf = %d %d %d %d\n',config.dsf);
    fprintf(fh,'mg_level = %d\n',config.mg_level);
    fprintf(fh,'mg_prolong_damp = %20.15g\n',config.mg_prolong_damp);
    
    fclose(fh);


end %function