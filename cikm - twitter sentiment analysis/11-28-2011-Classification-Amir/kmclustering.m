function [cm1 cm2] = kmclustering(train, label)
    [index c] = kmeans(train, 2);
    index(index == 1) = -1;
    index(index == 2) = 1;
            
    cm1 = confusionmat(label,index);
    cm2 = confusionmat(label,-index);
        
end