function testlabel = svmclassifier(conf,test,train,label)
    svmStruct = svmtrain(train,label, 'kernel_function', conf.svmkernel, 'method','LS'); %not in linux:'kktviolationlevel', 0.05,
    testlabel = svmclassify(svmStruct,test);    
end