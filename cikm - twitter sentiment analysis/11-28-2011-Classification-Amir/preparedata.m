function [ data label ] = preparedata(conf)
    [ data label words ] = loaddata(conf); 
    if(conf.drawhist == 1)     
        drawhist(conf, data, label); 
    end
    %print some stat in a file and return index of important
    %features(words)       
    importantfeatures = computestat(conf,data, label, words);       
	data = data(:,importantfeatures);                        
end