function [result] = traintest(conf, data, label)
    % cm = confusion matrix.
    % ccr = correct classification rate. 
    m = size(data,1);
    indices = crossvalind('Kfold',m,conf.numoffolds);      
    cm = zeros(2,2);    
    
    for i = 1:length(conf.methods)
        fprintf('\tmethod = %s\n', conf.methods{i});            
        fhandler = str2func(conf.methods{i});
        mistakes = zeros(m,1);
        lastlabel = zeros(m,1);
        for j = 1:conf.numoffolds        
            fprintf('\t\tfold = %d\n', j);
            test = (indices == j);    train = ~test;        
            resultlabel = zeros(sum(test), conf.numofensemble);                        
            for k = 1:conf.numofensemble
                fprintf('\t\t\tensemble = %d\n', k);
                %if we are not in compressed mode we have only one ensemble.
                if conf.compressedsensingmode 
                    newdata = zscore(compressdata(conf, data));
                    %newdata = compressdata(conf, data);
                    resultlabel(:,k) = fhandler(conf, newdata(test,:), newdata(train,:),label(train,:));
                else
                    %newdata = zscore(data);
                    newdata = data;
                    resultlabel(:,k) = fhandler(conf, newdata(test,:), newdata(train,:),label(train,:));                    
                    break;
                end                    
            end            
            %majority voting between ensembles & mean of cm
            finallabel = sign(sum(resultlabel, 2));
            finallabel(finallabel == 0) = -1; %tie break in favor of negative.            
            mistakes(test) = mistakes(test) + findmistakes(finallabel,label(test,:));
            lastlabel(test) = finallabel;
            cm = cm + confusionmat(label(test,:),finallabel); 
        end        
        cm = cm ./ conf.numoffolds;
        result.(conf.methods{i}).ccr = trace(cm) / sum(sum(cm));
        result.(conf.methods{i}).cm = cm;    
        result.datadim = size(newdata,2);
        result.(conf.methods{i}).mistakes = mistakes;
        result.(conf.methods{i}).label = lastlabel;
    end      
end
