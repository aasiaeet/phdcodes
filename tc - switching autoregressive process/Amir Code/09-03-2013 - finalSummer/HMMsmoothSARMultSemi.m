% Computes the smoothed posterior p(s(t)|v(1:T)) and pairwise smoothed posterior p(s(t),h(t+1)|v(1:T)). 
% [smoothed,smoothedJoint] = HMMsmoothSARMultSemi(logAlpha,logBeta,a,sigma2,stran,v,observedStates)     
%
% Inputs:
% logAlpha :  S * T log forward message for different time.
% logBeta  :  S * T log backward message for different time.
% a        :  Cell array of vector of SAR coefficients for each of G state. 
%             Column a(:,i) are the AR coeffs for switch state i.
% sigma2   :  Cell array of noise variance for each of G of SAR state. 
% stran    :  Transition probability matrix, column stochastic p(s(t)|s(t-1)). 
% v        :  A matrix of G * T. G GSR channel for user v. 
% observedStates   :  A list of the time points that we know the hidden
% state for user v.
%
% Outputs:
% smoothed : smoothed posterior p(s(t)|v(1:T))
% smoothedJoint  : smoothed posterior p(s(t),s(t+1)|v(1:T))
function [smoothed,smoothedJoint] = HMMsmoothSARMultSemi(logAlpha,logBeta,a,sigma2,stran,v,observedStates)    
    %% Smoothed posteriors: pointwise marginals p(s(t)|v(1:T)):
    [G T] = size(v); [L S]=size(a{1});
    for t=1:T
        logSmoothed(:,t)=logAlpha(:,t)+logBeta(:,t);
        smoothed(:,t)=condexp(logSmoothed(:,t));
    end
    %% Smoothed posteriors: pairwise marginals p(s(t),s(t+1)|v(1:T)):
    for t=2:T
        %% Preparing emission probabilities.
        Lt = min(t-1,L); % to handle the start when not enough timepoints
        logProbEmission = 0;
        for g = 1:G
            vhat = v(g, t-Lt:t-1)';
            m = a{g}(L-Lt+1:L,:)'*vhat; % means
            d = repmat(v(g, t),S,1) - m;
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
        %% Computing joint smoothing. 
        atmp=condexp(logAlpha(:,t-1));
        btmp=condexp(logBeta(:,t));
        %ctmp row:s(t-1) col:s(t)
        ctmp = repmat(atmp,1,S).*stranTemp'.*repmat(probEmission'.*btmp',S,1)+eps; % two timestep potential
        smoothedJoint(:,:,t - 1) = ctmp./sum(sum(ctmp));
        if sum(observedStates == t - 1) ~= 0                        
            temp = zeros(S,S); 
            %1 is spike state            
            temp(1,:) = smoothedJoint(1,:,t-1);
            temp(1,:) = condp(temp(1,:));
            smoothedJoint(:,:,t-1) = temp;            
        end        
    end
end