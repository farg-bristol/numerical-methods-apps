function [stat,out] = run_binary(cmd,workDir,echo)

if isunix
    
    cmd = ['unset LD_LIBRARY_PATH;',cd,filesep,'bin',filesep,'linux_x86-64',filesep,cmd];
    
elseif ispc
    
    cmd = [cd,filesep,'bin',filesep,'windows_x86-64',filesep,cmd];
    
else
    
    error('unstructured2d:run_binary','Unsupported system. Only supports 64bit linux and windows.');
    
end %if

origDir = cd(workDir);
cleanupObj = onCleanup(@() cd(origDir)); % Change back always

if nargin > 2
    if echo
        [stat,out] = system(cmd,'-echo');
    end %if
else
    [stat,out] = system(cmd);
end %if


end %function