clear;
clc;
n = 200;
p = 100;
s = 2 * floor(sqrt(p) / 2);
betaStar = zeros(p, 1);
betaStar(1:s) = -2;
betaStar(51:50 + s) = 1;
betaStar = betaStar / norm(betaStar);
lassoStableFeatures = betaStar;
lassoChosenFeatures = betaStar;
robustChosenFeatures = betaStar;

rng(1);
noiseLevelVector = [0, 0.1, .3, 0.5, 1];
cnt = 0;
noiseLevelNum = 0;
X = normrnd(0, 1, n, p);
epsilon = normrnd(0, 0.5, n, 1);
y = X * betaStar + epsilon;        
y = y - mean(y);    
for i = noiseLevelVector
    noiseLevelNum = noiseLevelNum + 1;        
    W = normrnd(0, i, n, p);
    Z = X + W;
    betaHatLasso = lasso(Z, y, 'Lambda', .1);               
    betaHatLasso = betaHatLasso/norm(betaHatLasso);
    lassoChosenFeatures = [betaHatLasso lassoChosenFeatures];
    
%     betaHatRobustLasso = robustLasso(Z, y, i * eye(p), [.01, 0.1, 0.5, 1, 10], [.01, 0.1, 0.5, 1, 10], betaStar);   %\Sigma_w, lambda, eta            
    betaHatRobustLasso = robustLasso(Z, y, i * eye(p), .01, 10, betaStar);   %\Sigma_w, lambda, eta            
    betaHatRobustLasso = betaHatRobustLasso/norm(betaHatRobustLasso);
    robustChosenFeatures = [betaHatRobustLasso robustChosenFeatures];
    
    v = 100;
    for iter = 1:v
        iter, 
        yPerm= y(randperm(length(y)));    
        betaHatPerm(:, iter) = lasso(Z, yPerm, 'Lambda', .1);        
%         betaHatRobustLassoPerm(:, iter) = robustLasso(Z, yPerm, i * eye(p), .01, 10, betaStar);   %\Sigma_w, lambda, eta            
    end
    %p-values
    pval=zeros(p,1);
    for dim =1:p
        betaHatLasso_i = betaHatLasso(dim);
        if(betaHatLasso_i > 0)	% if positive value, then p-val = fraction of times the positive value was exceeded
            pval(dim)=(nnz(betaHatPerm(dim,:) > betaHatLasso(dim))+1) / (v+1);
        elseif(betaHatLasso_i < 0)
                pval(dim)=(nnz(betaHatPerm(dim,:)<betaHatLasso(dim))+1)/(v+1);
        else
            pval(dim)=1;
        end
    end       
    
    tmpRelFeatures = zeros(p, 1);
    tmpRelFeatures(pval <= 0.05) = 1; 
    lassoStableFeatures = [tmpRelFeatures/norm(tmpRelFeatures) lassoStableFeatures];
end
figure


subplot(2,2,1);
spy(lassoChosenFeatures', 5);
set(gca,'DataAspectRatio',[1 .1 1])

subplot(2,2,2);
spy(lassoStableFeatures', 5);
set(gca,'DataAspectRatio',[1 .1 1])


subplot(2,2,3);
spy(robustChosenFeatures', 5);
set(gca,'DataAspectRatio',[1 .1 1])

% support = zeros(size(betaStar));
% support(betaStar ~= 0) = 1;
% tpr = [];
% fpr = [];
% for i = 5:-1:1
%     tmp = zeros(size(betaStar));
%     currentEstimate = lassoChosenFeatures(:, i);
%     tmp(currentEstimate ~= 0) = 1;
%     cmat = confusionmat(tmp, support);
% %     acc = sum(diag(cmat)) / sum(sum(cmat)),
%     tpr = [tpr cmat(2,2) / sum(cmat(:, 2))];
%     fpr = [fpr cmat(1,1) / sum(cmat(:, 1))];
% end
% plot(1 - fpr, tpr)
% 

%plot roc
% figure
% hold on
% sortedFx = sort(lassoChosenFeatures(:, 4));
% confusionmat(betaStar, sortedFx);
% hold off


% figure
% hold on
% plotroc(betaStar ~= 0,lassoChosenFeatures(:, 4) ~= 0)
% plotroc(betaStar ~= 0,lassoStableFeatures(:, 4) ~= 0)
% plotroc(betaStar ~= 0,robustChosenFeatures(:, 4)~= 0)
% hold off



% Train with dominant features
n = 100;
X = normrnd(0, 1, n, p);
epsilon = normrnd(0, 0.5, n, 1);
y = X * betaStar + epsilon;        
y = y - mean(y);    
W = normrnd(0, 0.5, n, p);
Z = X + W;
impFeatures = (lassoChosenFeatures(:, 4) ~= 0);
ZImp = Z(:, impFeatures);
beta = pinv(ZImp'*ZImp)*ZImp'*y;
betaAll = pinv(Z'*Z)*Z'*y;



% Test 
n = 100;
X = normrnd(0, 1, n, p);
epsilon = normrnd(0, 0.5, n, 1);
y = X * betaStar + epsilon;        
y = y - mean(y);    
W = normrnd(0, 0.5, n, p);
Z = X + W;
ZImp = Z(:, impFeatures);
errImpFeatures = mean((y - ZImp*beta).^2);
errAllFeatures = mean((y - Z*betaAll).^2);




% coeff_vec_stacked = zeros(num_test-1,length(dominant_features));
% for cross_valid = 1:num_test
%     % find indices of test year samples
%     test = (sample_year_indices== unique_year_indices(cross_valid));
%     train = ~test;
% 
%     xTr = XTest(train,dominant_features); 
%     xTr_all = XTest(train,:); 
%     yTr = YTest(train); 
% 
%     xTe = XTest(test,dominant_features); 
%     xTe_all = XTest(test,:); 
%     yTe = YTest(test);
% 
%     % OLS 
%     theta = pinv(xTr'*xTr)*xTr'*yTr;
%     theta_all = pinv(xTr_all'*xTr_all)*xTr_all'*yTr;
% 
%     % prediction errors
%     coeff_vec_stacked(cross_valid,:) = theta';
% 
%     sq_error_dominant_features(cross_valid) = mean((yTe - xTe*theta).^2);
%     sq_error_all(cross_valid) = mean((yTe - xTe_all*theta_all).^2);
%     sq_error_climatological(cross_valid) = mean((yTe + YTest_mean - YTrain_mean).^2);
% 
%     error_dominant_features = [error_dominant_features;(yTe - xTe*theta)];
%     error_dominant_features_years = [error_dominant_features_years, sample_year_indices(test)];
%     error_climatological = [error_climatological; yTe + YTest_mean - YTrain_mean];
%     observed_precip = [observed_precip; yTe + YTest_mean];
%     fprintf('Clim. Mean = %f,\tError from Clim. Mean = %f,\tDominant Fac. = %f\n',YTrain_mean,sq_error_climatological(cross_valid),sq_error_dominant_features(cross_valid));
% end
% 



