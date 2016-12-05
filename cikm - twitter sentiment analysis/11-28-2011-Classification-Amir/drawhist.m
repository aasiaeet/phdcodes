function drawhist(conf, data, label)   
    n = size(data,2);    
    numwordsintweet = sum(data,2);
    npositive = length(find(label == 1));

    frequency = sum(data);
    freqpos = sum(data(1:npositive,:));
    freqneg = sum(data(npositive + 1:end,:));
	freqabs = abs(freqpos - freqneg);
    
    cd(conf.resdir);cd(conf.conffile);
    %just draw hist once for each db. 
       
    %drawing hist of length frequency for +/-/whole data.
    hold on 
        x = 1:max(numwordsintweet);
        p1 = plot(x, hist(numwordsintweet, x));
        set(p1, 'Color', 'blue', 'LineWidth',3);
        p2 = plot(x, hist(numwordsintweet(1:npositive), x));
        set(p2, 'Color', 'red', 'LineWidth',3);
        p3 = plot(x, hist(numwordsintweet(npositive+1:end), x));
        set(p3, 'Color', 'green', 'LineWidth',3);
        legend('All tweets','Positive tweets', 'Negative tweets');
    hold off 
    saveplot([conf.matrixfile '_lengthist']);

    hist(frequency, 1:n);            
    saveplot([conf.matrixfile '_freqwordfrequencydist']);      
    hist(freqpos, 1:n);
    saveplot([conf.matrixfile '_freqposwordfreqdist']);      
    hist(freqneg, 1:n);
    saveplot([conf.matrixfile '_freqnegwordfreqdist']);      

    plot(1:n,frequency);
    saveplot([conf.matrixfile '_wordfrequencydist']);      
    plot(1:n,freqpos);
    saveplot([conf.matrixfile '_poswordfreqdist']);      
    plot(1:n,freqneg);
    saveplot([conf.matrixfile '_negwordfreqdist']);      
    plot(1:n,freqabs);
    saveplot([conf.matrixfile '_diffwordfreqdist']);      
    
    cd('..'); cd('..');
end


function saveplot(name)
    set( gcf, 'Name', name );    
    saveas( gcf, [ name '.fig' ] );    
    close(gcf);
end

