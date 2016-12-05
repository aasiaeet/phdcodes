function testlabel = nbclassifier(conf,test,train,label)
%     if(conf.compressedsensingmode)
%         O = NaiveBayes.fit(train,label);
%     else
        O = NaiveBayes.fit(train,label,'Distribution','mn');
%     end    
    testlabel = O.predict(test);        
end