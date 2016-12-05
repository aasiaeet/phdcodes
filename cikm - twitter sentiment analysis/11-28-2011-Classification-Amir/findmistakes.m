function mistakes = findmistakes(resultlabel,label)
    mistakes = zeros(length(label),1);
    catalyst = ~((resultlabel == 1)==(label == 1));
    mistakes((catalyst + resultlabel) == 2) = 1;
    mistakes((catalyst + label) == 2) = -1;
    % example  resultlabel = [1    -1    -1     1]
    % label = [1    -1     1    -1]
    % catalyst = [0     0     1     1] where labels are different.    
end