function [compresseddata] = compressdata(conf, data)
    [m n] = size(data);
    sp = sparsity(data, m); %compute the min sparsity of each row of data
    if isempty(conf.dim) || conf.dim == 0
        destinationdim = computedimension(conf, sp, n);  %computing dimension of the destination space
    else
        destinationdim = conf.dim;
    end
    A = buildprojectionmatrix(conf, destinationdim, n); 
    compresseddata = data * A'; %(A * data')';
end


function A = buildprojectionmatrix(conf, destinationdim, n)
    switch conf.projectionmatrixtype
        case 1,
            A = normrnd(0,1/destinationdim,destinationdim,n);
        case 2,
            
        case 3,
    end
end

function destinationdim = computedimension(conf, sp, n)
    switch conf.projectionmatrixtype
        case {1, 2}
            destinationdim = ceil(sp * log2(n / sp));        
        case 3, 
            destinationdim = ceil(sp * (log2(n) .^ 5));
    end
end
