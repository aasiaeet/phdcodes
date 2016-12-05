%it assumes that we have positive tweets first and then negative (in
%labels)
function importantfeatures = computestat(conf,data, label, words)       
    n = size(data,2);    
%     numwordsintweet = sum(data,2);
    npositive = length(find(label == 1));
    
    frequency = sum(data);
    freqpos = sum(data(1:npositive,:));
    freqneg = sum(data(npositive + 1:end,:));
	freqabs = abs(freqpos - freqneg);
    [~, indexsaf] = sort(freqabs,'descend'); 
    
%     uniqueid = [num2str(conf.discardlow) '_' num2str(conf.highfreqthreshold) '_' num2str(conf.lowfreqthreshold)];
%     name = ['stat_' uniqueid '.txt'];
    cd(conf.resdir);cd(conf.conffile);
%     fid = fopen(name,'w');       
%     printstat(fid, 'whole', numwordsintweet, 1, length(numwordsintweet));    
%     printstat(fid, '+', numwordsintweet, 1, npositive);    
%     printstat(fid, '-', numwordsintweet, npositive + 1, length(numwordsintweet));  
    
    importantfeatures = (frequency ~= 0); %index of important words.
    %If you want to train using only important features (words).
    %Set this to one will remove words with up to specified frequency and
    %high frequent words with no discrimination.
    if conf.onlyimportantfeatures        
        for i = 1:conf.discardlow
            importantfeatures = importantfeatures & (frequency ~= i);        
%             fprintf(fid, '# of words after removing %d-frequent: %d\n', i, full(sum(frequency > i)));
        end        
        [~, indexspf] = sort(freqpos,'descend'); 
        [~, indexsnf] = sort(freqneg,'descend'); 

        tenth = floor(conf.highfreqthreshold * n);
        half = floor(conf.lowfreqthreshold * n);
        indexunimportant = [];
        for i = 1:tenth
            if(~isempty(find(indexsnf(1:tenth) == indexspf(i), 1))) %check if the word is high freq. in both +/-
                if(~isempty(find(indexsaf(half:end) == indexspf(i),1))) %check if the word is unimportant in abs.
                    indexunimportant = [indexunimportant indexspf(i)];
                end
            end            
        end

        importantfeatures(indexunimportant) = 0;        
%         fprintf(fid, '# of words after removing high-frequent: %d\n', full(sum(importantfeatures)));
%         fprintf(fid, 'high-frequent words that removed:\n');
%         for i = 1:length(indexunimportant)
%             fprintf(fid, '\t%s\n', words{indexunimportant(i),1});
%         end
    end    
    
%     diff = freqpos - freqneg;
%     fprintf(fid, 'top 50 high-frequent words in absolute sense:\n');
%     for i = 1:50
%         if diff(indexsaf(i)) >= 0 
%             dominantsentiment = '+';
%         else
%             dominantsentiment = '-';
%         end
%         fprintf(fid, '\t%s:\t%s\n', words{indexsaf(i),1}, dominantsentiment);
%     end
        
%     fclose(fid);
    cd('..');cd('..');
end

function printstat(fid, type, array, s, e)
    a = array(s:e);
    fprintf(fid, [type ' tweets: \n']);
    fprintf(fid, '\tAverage # of words in a tweet: %d\n', full(mean(a)));
    fprintf(fid, '\tMode # of words in a tweet: %d\n', full(mode(a)));
    fprintf(fid, '\tMedian # of words in a tweet: %d\n', full(median(a)));
    fprintf(fid, '\tSTD # of words in a tweet: %d\n', full(std(a)));
end