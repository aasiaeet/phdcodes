function testlabel = knnclassifier(conf,test,train,label)
     testlabel = knnclassify(test, train, label, conf.knnk);
end