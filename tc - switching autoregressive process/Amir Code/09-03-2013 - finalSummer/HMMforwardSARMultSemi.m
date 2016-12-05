% Compute the forward message alpha using only one of the sample series.
% [logAlpha] = HMMforwardSARMultSemi(v,stran,sprior,a,sigma2,observedStates)
%
% Inputs:
% v:      A matrix of G * T. G GSR channel for user v. 
% stran : Transition probability matrix, column stochastic p(s(t)|s(t-1)). 
% sprior: Prior probability of being in different states p(s(0)).
% a     : Cell array of vector of SAR coefficients for each state. 
%         Column a(:,i) are the AR coeffs for switch state i.
% sigma2: Cell array of noise variance for each SAR state. 
% observedStates   :  A list of the time points that we know the hidden
% state for user v.
%
% Outputs:
% logAlpha: S * T log forward message for different time. 

function [logAlpha]=HMMforwardSARMultSemi(v,stran,sprior,a,sigma2,observedStates)
    %% logAlpha initialization:
    [G T] = size(v); [L S] = size(a{1});    
    logAlpha(:,1) = zeros(S,1) + log(sprior);
    for g = 1:G
        logAlpha(:,1) = logAlpha(:,1) + -0.5*repmat(v(g,1).^2,S,1)./sigma2{g}(:)- 0.5*log(2*pi*sigma2{g}(:));
    end

    for t=2:T
        %% Preparing emission probabilities.
        Lt = min(t-1,L); % to handle the start when not enough timepoints	
        logProbEmission = 0 + eps;
        for g = 1:G
            vhat = v(g, t-Lt:t-1)';
            m = a{g}(L-Lt+1:L,:)'*vhat; % means
            d = repmat(v(g,t),S,1)-m;
            % logAlpha recursion:
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
            stranTemp = stran;
        end		
        %% Computing forward message
        logAlpha(:,t) = logsumexp(repmat(logAlpha(:,t-1),1,S), repmat(probEmission',S,1) .* stranTemp');
        %if this is the observation state zero out all the other states. 
        if ~isempty(observedStates(observedStates == t))
            temp = logAlpha(1,t);
            logAlpha(:,t) = zeros(S, 1);
            logAlpha(1,t) = temp;            
        end
    end
end




