function [returnCoef, returnTimeCoef, returnCoefSemi, returnTimeCoefSemi] = generateReturnValue(data, allUserStates, flag, numOfTop)    
%     load('aggData.mat');    
%     load('sar.mat');    
%     load('allUserStates.mat');

    [m, ~] = size(data);
    returnCoef = cell(1,m);
    returnTimeCoef = cell(1,m);        
    
    returnCoefSemi = cell(1,m);
    returnTimeCoefSemi = cell(1,m);

    for i = 1:length(allUserStates)
        v = data{i};
        v = max(v, [], 1); %if we have multi channel take the max of them in each t.
        states = allUserStates{i};            
        [~, ind] = max(states);
        if(flag == 0)
            % Find spike and calm state: spikes are less frequent
            a = sum(ind == 2);
            b = sum(ind == 1);
            if min(a,b) == a
                spikeState = 2;
            else        
                spikeState = 1;
            end
        else
            spikeState = 1; %semi supervized case
        end
        [returnCoef{i}, returnTimeCoef{i}] = computeCoef(v, ind, spikeState, numOfTop);        
    end        
end


function [returnCoef, returnTimeCoef] = computeCoef(v, ind, spikeState, numOfTop)
    temp = v(ind == spikeState);
    tempIndex = find(ind == spikeState);        
    [temp, sortInd] = sort(temp, 'descend');        
    numOfSpikes = length(sortInd);       
    numOfSpikes = min(numOfSpikes, numOfTop);
    returnCoef = temp(1:numOfSpikes)'; 
    returnTimeCoef = tempIndex(sortInd(1:numOfSpikes));    
end