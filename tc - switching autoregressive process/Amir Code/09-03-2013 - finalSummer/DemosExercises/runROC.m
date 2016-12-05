function runROC()
    prepareFolders();
    %%
%     load('1calibData.mat');    
%     data = users;
%     slot = 32; %4 * 6; %6 sec bins
%     data = aggregate(data, slot);            
%     save('1aggCalib.mat','data');
    load('1aggCalib.mat');
    %%    
    SARObj.S = 2; % number of Hidden states
    SARObj.Maxit = 10;
    SARObj.L = 10; % order of each AR model
    SARObj.Tskip = 1;   
    numOfTop = 65;
    observedStates = cell(size(data,1), 1);
    SARObjReg = learning(SARObj, data, observedStates, 'GeneralDiagrams/learned/reg');
    allUserStatesReg = inference(SARObjReg, data, observedStates, 'GeneralDiagrams/inf/reg');            
    [returnCoefReg, returnTimeCoefReg] = generateReturnValue(data, allUserStatesReg, 0, numOfTop);  
    %%
%     observedStates = semiSupervision(data);    
%     save('pickedObservedStates.mat', 'observedStates');
%     save('beforeObservedStatesCalib.mat', 'observedStates');
%     save('afterObservedStatesCalib.mat', 'observedStates');
% 	load('pickedObservedStates.mat');
    load('afterObservedStates.mat');
    SARObjSemi = learning(SARObj, data, observedStates, 'GeneralDiagrams/learned/semi');
    allUserStatesSemi = inference(SARObjSemi, data, observedStates, 'GeneralDiagrams/inf/semi');            
    [returnCoefSemi, returnTimeCoefSemi] = generateReturnValue(data, allUserStatesSemi, 1, numOfTop);  
    save('GeneralDiagrams/allPick65.mat');
    %% Generate ROCs
%     load('all1.mat');
    startT  = 1;
    windows = [3, 5, 8, 10];% 15]; %iterate over window sizes
    lookAheads = 0:2;    
    forPlot = cell(length(windows * length(lookAheads) * 2));
    count = 0;
    for i = 1:length(windows) %for each data start
        window = windows(i);            
        for j = 1:length(lookAheads)
            lookAhead = lookAheads(j);
            for k = 1
                count = count + 1;
                countUp = k;
                dirName = ['W' num2str(window) 'L' num2str(lookAhead) 'C' num2str(countUp)];
%                 mkdir(dirName);
                forPlot{count} = cell(5,1);
                [forPlot{count}{1},forPlot{count}{2}] = roc2(returnCoefReg, returnTimeCoefReg, window, startT, lookAhead, countUp, dirName);
                [forPlot{count}{3},forPlot{count}{4}] = roc2(returnCoefSemi, returnTimeCoefSemi, window, startT, lookAhead, countUp, dirName);
                forPlot{count}{5} = dirName;
            end
        end
    end
    plotAll(forPlot);
end


function plotAll(forPlot)
    figure;
    col = hsv(2 * length(forPlot) + 1);
    legendText = cell(2 * length(forPlot) + 1, 1);
    for count = 1:length(forPlot)         
        plot(forPlot{count}{1}, forPlot{count}{2}, 'LineWidth',2,'color',col(count,:)); hold on;        
        legendText(count) = forPlot{count}(5);                
    end    
    for count = length(forPlot)+1:2*length(forPlot)
        cnt = count - length(forPlot);
        plot(forPlot{cnt}{3}, forPlot{cnt}{4}, 'LineWidth',2,'color',col(count,:)); hold on;
        legendText(count) = {[forPlot{cnt}{5} 'Semi']};
    end
    
    legendText(2 * length(forPlot) + 1) = {'y=x'};
    plot([0,1], [0,1],  'LineWidth',2, 'color',col(2 * length(forPlot) + 1,:));         
    legend(legendText{:}, 'Location', 'SouthEast');
    xlabel('False positive rate'); ylabel('True positive rate')
    title('ROC: Event (TP) vs. Non-Event (FP)');        
    saveas(gcf, ['GeneralDiagrams/roc.fig']);
    print('-dpdf', '-r2400', ['GeneralDiagrams/roc.pdf']);        
    close(gcf);
end

% To Do
% % Make the pdf automatic
% Why do I have duplicate on the comparison diagram?
% Is it because trend or what?
% What is DTC detrending?
% Just show the user number not the begining of the window. (have both)


function prepareFolders()
    addpath('../');
    if exist('GeneralDiagrams', 'dir') == 7
        rmdir('GeneralDiagrams', 's');
    end
    mkdir('GeneralDiagrams');
    mkdir('GeneralDiagrams/learned');
    mkdir('GeneralDiagrams/learned/semi');
    mkdir('GeneralDiagrams/learned/reg');
    mkdir('GeneralDiagrams/semi');
    mkdir('GeneralDiagrams/inf');    
    mkdir('GeneralDiagrams/inf/reg');
    mkdir('GeneralDiagrams/inf/reg/filt1');
    mkdir('GeneralDiagrams/inf/reg/filt2');
    mkdir('GeneralDiagrams/inf/semi');
    mkdir('GeneralDiagrams/inf/semi/filt1');
    mkdir('GeneralDiagrams/inf/semi/filt2');
end