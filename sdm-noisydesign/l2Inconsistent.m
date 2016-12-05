clear;
clc;
% n = 20;
p = 100;
s = floor(sqrt(p) / 2);
betaStar = zeros(p, 1);
betaStar(1:s) = -2;
betaStar(s+1:2*s) = 1;
% betaStar = betaStar / norm(betaStar);

rng(1);
numOfEnsembles = 10;
% numOfWEnsemble = 2;

expNumber = 0;
numberOfSamplesVector = 20:20:200;
noiseLevelVector = [0, 0.1, 0.3, 0.5, 1];
for n = numberOfSamplesVector
    expNumber = expNumber + 1,
    noiseLevelNum = 0;
    for i = noiseLevelVector
        noiseLevelNum = noiseLevelNum + 1;
        sumSmallestErrorForEnsembles = 0;
        for j = 1:numOfEnsembles
            X = normrnd(0, 1, n, p);
            W = normrnd(0, i, n, p);
            epsilon = normrnd(0, 0.1, n, 1);
            y = X * betaStar + epsilon;    
            Z = X + W;
            y = y - mean(y);
            [betaHat, FitInfo] = lasso(Z, y, 'NumLambda', 5);            
            l = length(FitInfo.Lambda);
            smallestError = Inf;
            for m = 1:l
                error = norm(betaHat(:, m) - betaStar);
                if  error < smallestError
                    smallestError = error;  
                end
            end 
            sumSmallestErrorForEnsembles = sumSmallestErrorForEnsembles + smallestError;
        end
        plotData(expNumber, noiseLevelNum) = sumSmallestErrorForEnsembles / numOfEnsembles;
    end
end
    
col = hsv(length(noiseLevelVector));
hold on;
for i = 1:length(noiseLevelVector)
    plot(numberOfSamplesVector, plotData(:, i)', 'color', col(i,:));    
end
hold off;



