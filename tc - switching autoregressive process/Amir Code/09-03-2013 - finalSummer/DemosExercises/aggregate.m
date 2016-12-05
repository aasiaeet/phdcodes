% Aggregates the GSR sample into bins. Each bin has winSize number of samples.
% We use the average of samples per bin as the aggregated result.
% Any kind of detrending should be added here. I just do normalization.
% dataOut = aggregate(data, winSize, start, stop)
%
% Inputs:
% data    :  Array of cells, each contain a matrix for a user. Each row of
% the matrix is a GSR channel for the user. 
% winSize :  Size of aggregation window.
% start   :  The beginning part of data to look at. (e.g., 1)
% stop    :  The end part of data to look at. (e.g., length(data{1}))
%
% Outputs:
% dataOut :  Array of cells of aggregated and detrended data.  
% 
% Note: For calibration data we have start=450 stop=669 (considering winSize 
% = 32 which makes the bins representing one second) since major stimuli
% is in this range.

function dataOut = aggregate(data, winSize, start, stop)
    N = length(data);
    [~, t] = size(data{1});
    dataOut = cell(size(data));
    for n = 1:N
        temp = [];
        for k = 1:t/winSize 
            last = min(t, k * winSize);
            window = data{n}(:,(k - 1) * winSize + 1: last);
            temp = [temp sum(window,2) ./ length(window)]; 
        end
        dataOut{n} = temp(start:stop);
    end    
    
    [G, ~] = size(dataOut{1}); %number of sensors time. 
    for n = 1:N        
        for g = 1:G
%             dataOut{i}(j,:) = detrend(dataOut{i}(j,:));
            dataOut{n}(g,:) = dataOut{n}(g,:) ./ norm(dataOut{n}(g,:));
%             plot(dataOut{i}(j,:)); hold on;
        end
%         hold off
    end
    
end


function x = detrend(x)
    y = dct(x);                  
    [~, index] = sort(y, 'descend');        
    y(index(1:2)) = zeros(2, 1);      
    x = idct(y);                 
end