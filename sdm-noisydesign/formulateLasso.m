function [C, d] = formulateLasso(A, b)
    C = chol(A);
    d = C' \ (b / 2);
end