function [X,Y,T,AUC] = roc2(coefs, inds, windowSize, data_start, lookAhead, countUp, dirName)
    load('aggAmirLabel5.mat');    
    
    rangesBlank = cell(6, 1); 
    rangesStimu = cell(6, 1);
    j = 0; k = 0;
    for i = 1:length(time_start)
        if(strcmp(text{i}, 'Silence') || strcmp(text{i}, 'Blank') )
            j = j + 1;
            rangesBlank{j} = time_start(i):time_stop(i);
        else
            k = k + 1;
            rangesStimu{k} = time_start(i):time_stop(i);
        end
    end

    
%     plotWindows(nonStim, stim, rangesStimu, windowSize, data_start);
    
    scores = []; labels = [];
    scoreNeg = []; scorePos = [];
    winNonStim = []; winStim = [];
    usersS = []; usersNS = [];
    totalWinB = 0; totalWinS = 0;
%     plotWindows(nonStim, stim, rangesStimu, windowSize, data_start);
    
    for i = 1:size(inds, 2)        
        [nonStim numWindowsB] = randSelectNonOverlap(rangesBlank, data_start, time_stop(length(time_stop)) - windowSize, 10, windowSize);
        [stim numWindowsS] = randSelectNonOverlap(rangesStimu, data_start, time_stop(length(time_stop)) - windowSize, 10, windowSize);   
        % lookAhead changes the place of window to consider by lookAhead
        % amount it could have been in the randSelectNonOverlap function.
        scoreNonStim = sumUpCoeffs(nonStim + lookAhead, windowSize, inds{i}, coefs{i}, countUp);
        scoreStim = sumUpCoeffs(stim + lookAhead, windowSize, inds{i}, coefs{i}, countUp); 
        %just for drawing  
        user = zeros(length(nonStim),1) + i;
        usersNS = [usersNS; user];
        winNonStim = [winNonStim nonStim];
        user = zeros(length(stim),1) + i;
        usersS = [usersS; user];        
        winStim = [winStim stim];
        
        scoreNeg = [scoreNeg scoreNonStim];
        scorePos = [scorePos scoreStim];
        %just for report
        totalWinS = totalWinS + numWindowsS;
        totalWinB = totalWinB + numWindowsB;
        
        scores = [scores, scoreNonStim, scoreStim];
        labels = [labels, zeros(size(scoreNonStim)), ones(size(scoreStim))]; 
    end   
%     plotReport(scoreNeg, scorePos, windowSize, winNonStim, winStim, usersNS, usersS, dirName)
%     totalWinB,
%     totalWinS,
    [X,Y,T,AUC] = perfcurve(labels, scores,1); 
end


function score = sumUpCoeffs(startVector, windowSize, inds, coefs, countUp)    
    [inds, index] = sort(inds);
    score = zeros(size(startVector));
    for i = 1:length(startVector)
        j = 1;
        sumUp = 0;
        %ignore while
        %jumpping to the beginning of the window.
        while (startVector(i) > inds(j) && j < length(index)) 
            j = j + 1;                
        end
        %select while
        %counting the coefficient inside of the window.
        while (startVector(i) + windowSize > inds(j) && j < length(index))
            if countUp
                sumUp = sumUp + 1;
            else %sumUp
                sumUp = sumUp + coefs(index(j));
            end
            j = j + 1;
        end
        score(i) = sumUp;
    end    
end


function sample = randSelect(ranges, start, stop, numSamples)
    allRanges = [];
    for i = 1:length(ranges)
        allRanges = [allRanges, ranges{i}];
    end
    allRanges = allRanges(allRanges >= start & allRanges <= stop);
    n = length(allRanges);
    assert(n >= numSamples);
    index = ceil(rand(numSamples, 1) * n);
    sample = allRanges(index);
end

function [sample numWindows] = randSelectNonOverlap(ranges, start, stop, upperNumSamples, windowSize)
    allRanges = [];
    for i = 1:length(ranges)
        tempRange = ranges{i};
        tempRange  = tempRange(1:end - windowSize);
        allRanges = [allRanges, tempRange];
    end
    allRanges = allRanges(allRanges >= start & allRanges <= stop);
    n = length(allRanges);
    numWindows = min(n, upperNumSamples);    
%     assert(n >= numSamples);    
    sample = allRanges(randsample(length(allRanges), numWindows));
end


