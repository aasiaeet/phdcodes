function [Z, W, y] = generateData(n, p, betaStar, distX, paramX, distEps, paramEps, distW, paramW)
    if distX == 'g'
        X = normrnd(0, paramX, n, p);
    end
    if distEps == 'g'
        epsilon = normrnd(0, paramEps, n, 1);
    end
    if distW == 'g'
        W = normrnd(0, paramW, n, p);
    end    
    y = X * betaStar + epsilon;
    Z = X + W;        
end