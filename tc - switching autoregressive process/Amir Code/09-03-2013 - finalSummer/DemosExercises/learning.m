% learn the SAR parameters and draw the smoothing results
% sarObj = learning(sarObj, data, observedStates, directory)
%
% Inputs:
% sarObj    :  All general parameters are stored in it. 
% data      :  Array of cells. It has a cell for each audiance. 
% Each cell is a matrix. Each row of the matrix is a channel of GSR, e.g., left or right hand. 
% observedStates   :  Array of cells. It has a cell for each audiance. 
% In each cell a list of the time points that we know the hidden state. 
% directory :  Name of the output directory.
%
% Outputs:
% sarObj    :  Contains all learned parameters

function sarObj = learning(directory, sarObj, data, observedStates)
    % EM training:    
    [sarObj,smoothed]=learn(sarObj,data,observedStates);
    % smoothed has a cell for each user which contains the possibility of 
    % each user being in a state per a time step    
    N = length(smoothed);
    c=hsv(sarObj.numState);    
    for n = 1:N
        [~, ind]=max(smoothed{n}); % find the most likely switches        
        v = data{n};
        [G, ~] = size(v);
        for g = 1:G
            vg = v(g,:); 
            plot(vg,'k'); hold on;             
        end
        for g = 1:G
            vg = v(g,:); 
            for s=1:sarObj.numState
                tt=find(ind==s);
                plot(tt,vg(tt),'.','color',c(s,:));                 
            end
        end
        xlim([1, length(v)]);         
        savePlot(directory, 'switches', sarObj, n);        
    end    
end
