% run the whole experiment 
% []=run(dataFile,avgRate)
%
% Inputs:
% dataFile  :  File name of audiance. It loads array of cells named 'users'. 
% 'users' has a cell for each audiance. Each cell is a matrix. Each row of the 
% matrix is a channel of GSR, e.g., left or right hand. 
% dataDir   :  Directory that stores data files. 
% avgRate   :  Window size for aggeragating (averaging) GSR. For capturing
% one second in each window put avgRate = sample rate. 
% isSemiSup :  Set one if we want to do semisupervision.
%
% Outputs:
% Nothing it just perform the learning and inference. 
% 

function run()
    configFile = 'config';
    display(configFile);
    conf = getConfig([configFile '']);    
    addpath('../'); 
    prepareFolder('.', conf.directory);
    %% Time Series Aggregation
    cd(conf.dataDir);     load(conf.dataFile);        cd('..');
    data = aggregate(users, conf.avgRate, conf.start, conf.stop);            
    prepareFolder(conf.directory, 'agg');
    save([conf.directory '/agg/agg' conf.dataFile],'data');    
%     load([directory '/agg' dataFile]);    
    %% Semi-supervision
    observedStates = cell(size(data,1), 1);
    if(conf.isSemiSup)    
%         prepareFolder(conf.directory, 'semi');
%         observedStates = semiSupervision([conf.directory, '/semi'], data, conf.numOfPoints);
%         save([conf.directory '/semi/observed' conf.dataFile],'observedStates');  
        load('observedcalibData.mat');  
    end        
    %% EM Learning   
    sarObj.numState = conf.numState; % number of Hidden states
    sarObj.maxIt = conf.maxIt;
    sarObj.histLength = conf.histLength; % order of each AR model
	prepareFolder(conf.directory, 'switches');
    sarObj = learning([conf.directory '/switches'], sarObj, data, observedStates);
	prepareFolder(conf.directory, 'inf');
    %% Inference
    allUserStatesReg = inference([conf.directory, '/inf'], sarObj, data, observedStates);                
    save([conf.directory '/all.mat']);    
end
