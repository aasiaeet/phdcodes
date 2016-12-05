function plotReport(scoreNeg, scorePos, windowSize, winNonStim, winStim, userNS, userS, dirName)
    [scoreNeg indNeg] = sort(scoreNeg, 'descend');
    [scorePos indPos] = sort(scorePos, 'descend');    
    ignoreN = find(scoreNeg == 0, 1, 'first');
    ignoreP = find(scorePos == 0, 1, 'first');
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    negss = 1:length(scoreNeg);
    plot(negss, scoreNeg, 'r', 'LineWidth', 2); 
    annotNS = generateLabels(winNonStim(indNeg), userNS(indNeg), ignoreN);
    text(negss, scoreNeg, annotNS, 'FontSize', 2);    
    hold on;
    
    poss = 1:length(scorePos);
    plot(poss, scorePos, 'g', 'LineWidth', 2);
    annotS = generateLabels(winStim(indPos), userS(indPos), ignoreP);
    text(poss, scorePos, annotS, 'FontSize', 2);
    hold off;    

    title(['Comparison for window of size: ', num2str(windowSize)]);
    legend({'Negative','Positive'},'Location', 'NorthEast');
    saveas(gcf, [dirName '/comparisonBoth.fig']);
    print('-dpdf', '-r2400', [dirName '/comparisonBoth.pdf']);
    close(gcf);
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    negss = 1:length(scoreNeg);
    plot(negss, scoreNeg, 'r', 'LineWidth', 2); 
    annotNS = generateLabels2(userNS(indNeg), ignoreN);
    text(negss, scoreNeg, annotNS, 'FontSize', 4);    
    hold on;
    
    poss = 1:length(scorePos);
    plot(poss, scorePos, 'g', 'LineWidth', 2);
    annotS = generateLabels2(userS(indPos), ignoreP);
    text(poss, scorePos, annotS, 'FontSize', 4);
    hold off;    

    title(['Comparison for window of size: ', num2str(windowSize)]);
    legend({'Negative','Positive'},'Location', 'NorthEast');
    saveas(gcf, [dirName '/comparisonOnce.fig']);
    print('-dpdf', '-r2400', [dirName '/comparisonOnce.pdf']);
    close(gcf);
end


function annotations = generateLabels(win, user, ignorePoint)
    annotations = cell(length(win), 1);    
    for i = 1:length(win)
        if i > ignorePoint 
            annotations{i} = '';
        else           
            annotations{i} = ['(' num2str(win(i)) ',' num2str(user(i)) ')'];                 
        end
    end
end

function annotations = generateLabels2(user, ignorePoint)
    annotations = cell(length(user), 1);
    for i = 1:length(user)
        if i > ignorePoint 
            annotations{i} = '';
        else           
            annotations{i} = num2str(user(i));                 
        end
    end
end



function plotWindows(nonStim, stim, rangesStimu, windowSize, data_start)
    for i = 1:length(rangesStimu)        
        X = rangesStimu{i};
        plot(X, zeros(size(X)), 'b', 'LineWidth', 2);
        hold on;
        Y = stim(i):(stim(i) + windowSize);
        plot(Y, ones(size(Y)) ./ 2, 'r', 'LineWidth', 2);
        hold on;
        Z = nonStim(i):(nonStim(i) + windowSize);
        plot(Z, ones(size(Z)), 'g', 'LineWidth', 2);        
    end
    ylim([-.5, 1.5]);
    xlim([data_start, 219]);
    legend({'Tru Stim', 'Selected Stim', 'Selected Non-Stim'}, 'Location', 'NorthWest');
end