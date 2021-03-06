function conf = loadconfiguration(confdir, conffile)
    conf = struct( ...
          'resdir', [] ...
          , 'databasedir', [] ...
          , 'conffile', [] ...
          , 'matrixfile', [] ...
          , 'labelfile', [] ...
          , 'wordfile', [] ...
          , 'onlyimportantfeatures', [] ...    
          , 'discardlow', [] ... %onlyimportantfeatures should be 1 to take efect: 0 = no cut, 1 = cut 1-freq, ...
          ...
          ... %onlyimportantfeatures should be 1 to take efect:
          ... %for discarding words with high frequency in both +/- but low frequency in their difference. 
          ... %this means that words are usual verbs and they are like stop words and should be removed. 
          ... %for ignoring this set highfreqthreshold = 0.
          , 'lowfreqthreshold', [] ... %0<x<1: searching x percent of tail of diff frequency.
          , 'highfreqthreshold', [] ... %0<x<1: searching x percent of high frequent +/- for match.
          ...
          , 'numoffolds', [] ...%at least should be 2.
          , 'methods', [] ...   %should be cell, currently support: 'dlclassifier', 'nbclassifier', 'svmclassifier', 'knnclassifier'
          , 'runkmean', [] ...          
          , 'svmkernel', [] ... %it works when runsvm is on: 'linear', 'quadratic', 'polynomial', 'rbf', 'mlp' %, 
          , 'knnk', [] ... %k parameter for knn classifier. it should be at least 1. 
          , 'dim', [] ... %destination dimension for compressing. it not set automatically computed. 
          , 'compressedsensingmode', [] ... 
          , 'projectionmatrixtype', [] ... %it works when compressedsensingmode is 1: Gaussian = 1, Bernoulli = 2, Hadamard = 3 %           
          , 'numofensemble', [] ... %number of ensembles of projection matrix. (even in the none compressed mode it should be 1 at least!!!
          ...
          , 'balancedb', [] ... %TO DO
          , 'drawhist', [] ... %if you have word with this database once and you have histograms saved you can set it to 0.
          , 'class1', [] ... %list of class1 (e.g. all non-sentiment: I can't tell, Neutral, Not related: [-1 -3 -5]) for labeling to 0.
          , 'class2', [] ... %list of class2 (e.g. all sentiments: - and +: [-2 -4]) for labeling to 1.
          , 'elimclass', [] ... %list of labels to be deleted (e.g. eliminate all non-sentiments for classification of sentiments only: elimclass=[-1 -3 -5], class1=-2, class2=-4)
      );
    %assumption: confdirectory is in current folder. 
    cd(confdir);
    eval(conffile); 
    cd('..');
end