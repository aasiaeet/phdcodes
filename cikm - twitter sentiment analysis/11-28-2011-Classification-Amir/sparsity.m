function sp = sparsity(data, m)
    spvector = zeros(m,1);
    for i = 1:m
       spvector(i) = length(find(data(i,:) > 0));
    end
    sp = max(spvector);
end