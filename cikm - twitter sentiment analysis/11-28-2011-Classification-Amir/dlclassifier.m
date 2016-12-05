function reslabel = dlclassifier(conf,test,train,label)
    Xneg = train(label == -1,:); %negative train data;
    Xpos = train(label == 1,:); %positive train data;
    
    param.K=50;  % learns a dictionary with 100 elements
    param.lambda=0.15;
    param.numThreads=4; % number of threads
    param.batchsize=512;

    param.iter=100;  % let us see what happens after 100 iterations.

    %tic
    Dpos = mexTrainDL(Xpos',param);
    Dneg = mexTrainDL(Xneg',param);
    %t=toc;
    %fprintf('time of computation for Dictionary Learning: %f\n',t);

    param.approx=0;
    %fprintf('Evaluating cost function...\n');
    X = test;
    alphapos = mexLasso(X',Dpos,param);
    alphaneg = mexLasso(X',Dneg,param);
    
    poserr = 0.5*sum((X'-Dpos*alphapos).^2)+param.lambda*sum(abs(alphapos));
    negerr = 0.5*sum((X'-Dneg*alphaneg).^2)+param.lambda*sum(abs(alphaneg));
    reslabel = zeros(size(poserr));
	%lower error determine the class.
    reslabel(poserr <= negerr) = 1; %result is positive
    reslabel(poserr > negerr) = -1; %result is negative
end
