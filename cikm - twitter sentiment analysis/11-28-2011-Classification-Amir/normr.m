function y = normr(x)
    [m n] = size(x);
    y = x;
    for i = 1:m
       normx = norm(x(i,:));
       if(normx ~= 0)
           y(i,:) = x(i,:) / normx; 
       else
           y(i,:) = 0;
       end
    end
end