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
numOfEnsembles = 3;
% numOfWEnsemble = 2;

expNumber = 0;
numberOfSamplesVector = 20:20:200;
noiseLevelVector = [0, 0.1, .3, 0.5, 1];
cnt = 0;
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
%                     scatterXTmp = n;
%                     scatterYTmp = i;
%                     scatterZTmp = FitInfo.Lambda(m);
                end
            end 
%             cnt = cnt + 1;
%             sX(cnt) = scatterXTmp;sY(cnt) = scatterYTmp;sZ(cnt) = scatterZTmp;
            sumSmallestErrorForEnsembles = sumSmallestErrorForEnsembles + smallestError;
        end
        plotData(expNumber, noiseLevelNum) = sumSmallestErrorForEnsembles / numOfEnsembles;
    end
end
    
% scatter3(sX, sY, sZ);
% surface(reshape(mean(reshape(sZ, 5, 4, 3), 1), 4, 3))
col = hsv(length(noiseLevelVector));
hold on;
for i = 1:length(noiseLevelVector)
    plot(numberOfSamplesVector, plotData(:, i)', 'color', col(i,:));    
end
hold off;
%fix samples, inc lambda



