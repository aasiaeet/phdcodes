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
            betaHat = robustLasso(Z, y, i * eye(p), [.01, 0.1, 1, 10], [.01, 0.1, 1, 10, 100], betaStar);
%             betaHat = robustLasso(Z, y, i * eye(p), .01, .01, betaStar);
            sumSmallestErrorForEnsembles = sumSmallestErrorForEnsembles + norm(betaHat - betaStar);
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



