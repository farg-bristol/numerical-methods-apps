function volume = load_volume_results(dat_file,grid,machinf)

gam = 1.4;
Runiv = 287.0;
Tinf = 0.0029;
rhoinf = 1.20;
sos = sqrt(gam*Runiv*Tinf);
pinf = rhoinf*Runiv*Tinf;

fh = fopen(dat_file,'r');
if fh < 0
    error('unstructured2d:load_volume_results',['Unable to open results file for reading: ',dat_file]);
end %if
    
volume.u = zeros(grid.ncell,1);
volume.v = volume.u;
volume.rho = volume.u;
volume.p = volume.u;
volume.cp = volume.u;
volume.mach = volume.u;

for i=1:grid.ncell

    volume.rho(i) = fscanf(fh,'%f',1);
    volume.u(i) = fscanf(fh,'%f',1);
    volume.v(i) = fscanf(fh,'%f',1);
    E = fscanf(fh,'%f',1);
    volume.p(i) = fscanf(fh,'%f',1);
    
    volume.cp(i) = (2/(gam*machinf^2))*(volume.p(i)/pinf - 1);
    volume.mach(i) = sqrt(volume.u(i)^2 + volume.v(i)^2)/sos;
    
end %for

fclose(fh);

end %function