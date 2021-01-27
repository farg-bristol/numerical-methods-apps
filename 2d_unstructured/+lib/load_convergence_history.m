function history = load_convergence_history(history_file)

fh = fopen(history_file,'r');
if fh < 0
    error('unstructured2d:load_convergence_history',['Unable to open history file for reading: ',history_file]);
end %if

C = textscan(fh,'%u %f %f %f %f %f %f %f','HeaderLines',2);

fclose(fh);

history.iterations = C{1};
history.residual = C{2};
history.CL = C{3};
history.CM = C{4};
history.CD = C{5};
history.time = C{8};

end %function