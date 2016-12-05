function bestBetaHatRobustLasso = robustLasso(Z, y, SigmaW, lambdaList, etaList, betaStar)
    b = norm(betaStar, 1);
    [n, p] = size(Z);
    smallestError = Inf;
    for lambda = lambdaList
        for eta = etaList
            betaHatRobustLasso = ones(p, 1);
%             betaHatRobustLasso = betaHatRobustLasso / norm(betaHatRobustLasso);
            for t = 1:1000
                gradient = (1/n * (Z' * Z) - SigmaW) * betaHatRobustLasso - 1/n * Z' * y;
                betaHatRobustLasso = wthresh(betaHatRobustLasso - (1 / eta) * gradient,'s',lambda);
                betaHatRobustLasso = projectOntoL1Ball(betaHatRobustLasso, b);
            end
            error = norm(betaStar - betaHatRobustLasso);
            if  error < smallestError 
                smallestError  = error; 
                bestBetaHatRobustLasso = betaHatRobustLasso;
                bestLambda = lambda;
                bestEta = eta;
            end
        end
    end
%     bestLambda,
%     bestEta,
end
