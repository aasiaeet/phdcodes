% run the whole experiment 
% [sarObj, smoothed] = learn(sarObj, data, observedStates)
%
% Inputs:
% data  :  File name of audiance. It loads array of cells named 'users'. 
% sarObj:  All general parameters are stored in it. a, sigma2, and stran
% to be learned here. 
% observedStates   :  Array of cells. It has a cell for each audiance. 
% In each cell a list of the time points that we know the hidden state. 
%
% Outputs:
% sarObj:  All general parameters are stored in it. a, sigma2, and stran
% filled in. 
% smoothed: Smoothing result artifact of EM just passing it for plotting.

function [sarObj,smoothed]=learn(sarObj, data, observedStates)
    [G, T] = size(data{1});
    L = sarObj.histLength;
    S = sarObj.numState;    
    [a sigma2 sprior, stran, N, logAlpha, ... 
	logBeta, smoothed, smoothedJoint] = initializeParams(data, G, L, T, S);

    for emloop=1:sarObj.maxIt
        %% Computing state transition probabilites.
        emloop,
        for n = 1:N
            v = data{n}; %v is a matrix of G * T.
            logAlpha{n} = HMMforwardSARMultSemi(v,stran,sprior,a,sigma2,observedStates{n});
            logBeta{n} = HMMbackwardSARMultSemi(v,stran,a,sigma2,observedStates{n});
            [smoothed{n}, tempJoint] = HMMsmoothSARMultSemi(logAlpha{n},logBeta{n},a,sigma2,stran,v,observedStates{n});
            if(~isempty(observedStates{n}))                
                temp = observedStates{n} - 1;
                for i = 1:length(temp)
                    tempJoint(:,:,temp(i)) = zeros(S,S);
                end                
            end
            smoothedJoint = smoothedJoint + tempJoint;            
        end        
        stran=condp(sum(smoothedJoint(:,:,:),3)');   
        %% Computing autoregressive parameters.
        for g = 1:G
            for s=1:S
                vvhat_sum=zeros(L,1); vhatvhat_sum=zeros(L,L); sigma_sum=0; sigma_num=0;
                for n = 1:N                   
                    v = data{n}(g,:);
                    smoothedTemp = smoothed{n};            
                    for t=1:T
                        Lt = min(t-1,L); % to handle the start when not enough timepoints
                        vhat=zeros(L,1);
                        if Lt ~= 0
                            vhat(end-Lt+1:end) = v(t-Lt:t-1)';
                        end                        
                        m = a{g}(:,s)'*vhat; % means
                        vvhat_sum = vvhat_sum + smoothedTemp(s,t)*v(t)*vhat./sigma2{g}(s);
                        vhatvhat_sum = vhatvhat_sum + smoothedTemp(s,t)*(vhat*vhat')./sigma2{g}(s);
                        sigma_sum = sigma_sum+smoothedTemp(s,t)*(v(t)-m).^2;
                        sigma_num = sigma_num + smoothedTemp(s,t);
                    end
                end
                a{g}(:,s)=vhatvhat_sum\vvhat_sum;
                sigma2{g}(s)=sigma_sum/sigma_num;
            end
        end        
    end
    sarObj.a = a; sarObj.sigma2 = sigma2; sarObj.stran = stran;
end

%% Initialization
function [a sigma2 sprior, stran, N, logAlpha, ...
          logBeta, smoothed, smoothedJoint] = initializeParams(data, G, L, T, S)
    a = cell(G, 1); sigma2 = cell(G, 1);
    for g = 1:G %G is number of GSR signals or number of sensors
        a{g} = condp(randn(L,S)); % set the AR coefficients    
        sigma2{g} = var(meanCell(data, g))*ones(1,S);        
    end
    sprior = condp(ones(S,1)); % switch prior
    stran=condp(ones(S,S)); % switch transition    
    N = length(data);

    logAlpha = cell(1,N);
    logBeta = cell(1,N);
    smoothed = cell(1,N);
    smoothedJoint = zeros(S,S,T - 1);
end

%% Mean of channel g for all users.
function meanC = meanCell(data, g)    
    sumUp = 0;
    for j = 1:length(data)            
        sumUp = sumUp + data{j}(g,:);
    end
    meanC = sumUp / length(data);
end
