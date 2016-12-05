conf.matrixfile = 'matrix2.txt';
conf.labelfile = 'label2.txt';
conf.wordfile = 'words.txt';

conf.onlyimportantfeatures = 1;
    conf.discardlow = 3; 
    conf.lowfreqthreshold = 0.8;
    conf.highfreqthreshold = 0.2;

conf.numoffolds = 10; %at least must be 2.
conf.runkmean = 0;

conf.methods = {'dlclassifier'};%,'svmclassifier','knnclassifier'};%'nbclassifier'};% 'svmclassifier', 'knnclassifier'};
conf.svmkernel = 'linear';
conf.knnk = 10;

conf.compressedsensingmode = 1;
    conf.projectionmatrixtype = 1; 
    conf.numofensemble = 10;
    conf.dim = 0;

conf.balancedb = 0;
conf.drawhist = 0;

conf.class1 = [-1 -5]; %not related to weather
conf.class2 = [-2 -3 -4]; %related to weather
conf.elimclass = [];