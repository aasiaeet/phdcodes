% Go inside the given directory and create the inner directory.
% [] = prepareFolder(directory, innerDir)
%
% Inputs:
% directory :  Given directory that sould exist
% innerDir  :  Inner directory that should be created inside the directory.
%
% Outputs:
% Nothing. 
% 

function prepareFolder(directory, innerDir)
    cd(directory);
    if exist(innerDir, 'dir') == 7
        rmdir(innerDir, 's');
    end
    mkdir(innerDir);  
    if strcmp(directory, '.') == 0
        cd('..');
    end
end