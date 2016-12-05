function [expConf] = getConfig(configFile)
    expConf = struct( ...
          'directory', [] ...  % name of output directory
        , 'dataDir', [] ...    % directory where input exists
        , 'dataFile', [] ...   % name of data file in dataDir directory 
        , 'avgRate', [] ...    % window size for aggregation
        , 'isSemiSup', [] ...  % do we want semi-supervision
        , 'numState', [] ...   % number of states, usually 2. 
        , 'maxIt', [] ...      % maximum number of iteration for EM.
        , 'histLength', [] ... % history length of auto-regressive process
        , 'numOfPoints', [] ...% number of semi-supervision point per user
        , 'start', [] ...      % using [start, stop] part of data for learning. 
        , 'stop', [] );        % note that [start, stop] is after aggregation.
    eval(configFile);
    configFile;
end