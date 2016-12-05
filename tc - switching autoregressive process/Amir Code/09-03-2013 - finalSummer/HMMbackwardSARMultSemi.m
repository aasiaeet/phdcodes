% Computes the backward message beta using only one of the sample series.
% [ logBeta ] = HMMbackwardSARMultSemi(v,stran,a,sigma2,observedStates) 
%
% Inputs:
% v:      A matrix of G * T. G GSR channel for user v. 
% stran : Transition probability matrix, column stochastic p(s(t)|s(t-1)). 
% a     : Cell array of vector of SAR coefficients for each state. 
%         Column a(:,i) are the AR coeffs for switch state i.
% sigma2: Cell array of noise variance for each SAR state. 
% observedStates   :  A list of the time points that we know the hidden
% state for user v.
%
% Outputs:
% logBeta: S * T log backward message for different time. 

function [ logBeta ] = HMMbackwardSARMultSemi(v,stran,a,sigma2,observedStates)    
    [G T] = size(v); [L S]=size(a{1});
    % logBeta initialization
    logBeta(:,T) = zeros(S,1);
    for t=T:-1:2
         %% Preparing emission probabilities.
        Lt = min(t-1,L); % to handle the start when not enough timepoints
        logProbEmission = 0 + eps;
        for g = 1:G
            vhat = v(g, t-Lt:t-1)';
            m = a{g}(L-Lt+1:L,:)'*vhat; % means
            d = repmat(v(g,t),S,1)-m;
            % logBeta recursion
            logProbEmission = logProbEmission + -0.5*d.^2./sigma2{g}(:)-0.5*log(2*pi*sigma2{g}(:));
        end
        probEmission=condexp(logProbEmission);
        %% Preparing state transition probabilities. 
        if ~isempty(observedStates(observedStates > t))
            nextObserevedState = observedStates(find(observedStates >= t, 1, 'first'));
            kStepTrans = stran ^ (nextObserevedState - t); 
            %assuming the first state is representing spike.
            stranTemp = condp(stran .* repmat(kStepTrans(1,:)', 1, S));                
        else
            stranTemp=stran;
        end		            
         %% Computing backward message
        logBeta (:,t-1)=logsumexp(repmat(logBeta (:,t),1,S),repmat(probEmission,1,S) .* stranTemp);
        %if this is the observation state zero out all the other states. 
        if ~isempty(observedStates(observedStates == t-1))
            temp = logBeta (1,t-1);
            logBeta (:,t-1) = zeros(S, 1);
            logBeta (1,t-1) = temp;            
        end
    end
end