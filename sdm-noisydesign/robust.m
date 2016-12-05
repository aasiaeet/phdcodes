clear;
clc;
% n = 20;
p = 100;
s = floor(sqrt(p) / 2);
betaStar = zeros(p, 1);
betaStar(1:s) = -2;
betaStar(s+1:2*s) = 1;

sigmaX = .5;
sigmaEps = .1;
sigmaW = 0;

rng(1);
numOfXEnsemble = 2;
numOfWEnsemble = 2;

numberOfExp = 0;
numberOfSamplesVector = 20:20:100;
noiseLevelVector = 0:0.1:0.5;
for n = numberOfSamplesVector
    numberOfExp = numberOfExp + 1,
%     [Z, W, y] = generateData(i, p, betaStar, 'g', sigmaX, 'g', sigmaEps, 'g', sigmaW);
    for i = 1:numOfXEnsemble
        X = normrnd(0, 0.5, n, p);
        epsilon = normrnd(0, 0.1, n, 1);
        y = X * betaStar + epsilon;
        noiseLevel = 0;
        for j = noiseLevelVector
            noiseLevel = noiseLevel + 1;
            sumSmallesErrorForFixedNoiseLevel = 0;
            for k = 1:numOfWEnsemble
                W = normrnd(0, j, n, p);
                Z = X + W;
                [betaHat, FitInfo] = lasso(Z, y);
                l = length(FitInfo.Lambda);
                smallestError = Inf;
                for m = 1:l
                    error = norm(betaHat(:, m) - betaStar);
                    if  error < smallestError
                        smallestError = error;  
                    end
                end    
                sumSmallesErrorForFixedNoiseLevel = sumSmallesErrorForFixedNoiseLevel + smallestError;
            end
            plotData(numberOfExp, i, noiseLevel) = sumSmallesErrorForFixedNoiseLevel / numOfWEnsemble;
        end
    end
end
% hold off;
%fix lambda, inc samples
pData = mean(plotData, 2);
hold on;
for i = 1:noiseLevel
    plot(numberOfSamplesVector, pData(:, i)');
end
hold off;
%fix samples, inc lambda



