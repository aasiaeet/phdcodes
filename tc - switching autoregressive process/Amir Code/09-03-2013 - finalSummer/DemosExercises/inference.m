function [states] = inference(directory, sarObj, data, observedStates)
    L = sarObj.histLength;
    S = sarObj.numState;        
    a = sarObj.a; % set the AR coefficients
    stran = sarObj.stran; % switch transition
    sprior=condp(ones(S,1)); % switch prior
    sigma2= sarObj.sigma2; %0.01*ones(1,S);
    [m, ~] = size(data);    
    
    states = cell(m,1);        
    for i = 1:m
        v = data{i};
        % Inference using HMM structure:
        logalpha = HMMforwardSARMultSemi(v,stran,sprior,a,sigma2, observedStates{m});
        logbeta = HMMbackwardSARMultSemi(v,stran,a,sigma2, observedStates{m});
        [phtgV1T,~]=HMMsmoothSARMultSemi(logalpha,logbeta,a,sigma2,stran,v, observedStates{m});
        filtered = condexp(logalpha);
        subplot(2,1,1); 
            plot(filtered(1,:), 'LineWidth',2); hold on; 
            plot(1:length(v), 0.5, '-r', 'LineWidth',2);
            xlim([1,length(v)]);         
        subplot(2,1,2); plot(v', 'LineWidth', 2); xlim([1,length(v)]);        
        
        set( gcf, 'Name', ['Person' num2str(i)]);
        dirName = [directory '/' 'Person' num2str(i) '_' num2str(L) '_' num2str(sarObj.maxIt) '_' num2str(clock)];
        saveas( gcf,  [dirName '.fig']);    
        print('-dpdf', '-r2400', [dirName '.pdf']);
        close(gcf);
        
        
        subplot(2,1,1); 
            plot(filtered(2,:), 'LineWidth',2); hold on; 
            plot(1:length(v), 0.5, '-r', 'LineWidth',2);
            xlim([1,length(v)]);         
        subplot(2,1,2); plot(v', 'LineWidth', 2); xlim([1,length(v)]);        
        
        set( gcf, 'Name', ['Person' num2str(i)]);
        dirName = [directory '/' 'Person' num2str(i) '_' num2str(L) '_' num2str(sarObj.maxIt) '_' num2str(clock)];
        saveas( gcf,  [dirName '.fig']);    
        print('-dpdf', '-r2400', [dirName '.pdf']);
        close(gcf);
        states{i} = phtgV1T;
    end
end