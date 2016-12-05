function [ data label words ] = loaddata(conf)
    %input data format:
    %lines of matrixfile: row#(tweet#) col#(word) datavalue(# occurance)
    %labelfile: at first positive tweets then negative tweets.

    cd(conf.databasedir);
    matrix = load(conf.matrixfile);
    label = load(conf.labelfile);   
    words = importdata(conf.wordfile);
    cd('..');

    m = max(matrix(:,1)); %number of tweets
    n = max(matrix(:,2)); %number of words
    data = sparse(matrix(:,1), matrix(:,2), matrix(:,3), m, n);
    
    
    data((m - floor(mod(m, conf.numoffolds) / 2) + 1):m, :) = [];
    data(1:ceil(mod(m, conf.numoffolds) / 2), :) = [];
    
    label((m - floor(mod(m, conf.numoffolds) / 2) + 1):m, :) = [];
    label(1:ceil(mod(m, conf.numoffolds) / 2), :) = [];
    
    [label data] = clip(conf, label, data);
end


function [label data] = clip(conf, label, data)
%     icanttell = (label == -1);
%     negative = (label == -2);
%     neutral = (label == -3);
%     positive = (label == -4);
%     notrelated = (label == -5);  
    
    for i = conf.elimclass
        index = (label == i);
        label(index) = [];
        data(index, :) = [];
    end

    for i = conf.class1
        label(label == i) = -6;
    end    
    
    for i = conf.class2
        label(label == i) = 6;
    end         
	label = label ./ 6;
    cd(conf.resdir);
    save([conf.conffile '_' 'inputlabel' eval('date') '_' num2str(eval('clock')) '.mat'],'label');
    cd('..');
%size(label)
%size(data)
end
