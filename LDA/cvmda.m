function [conf, gamma] = cvmda(classes, R, K)
%CVMDA Repeated K-fold cross-validate multiple shrinkage-based LDA.
%   Splits each class into k folds and uses k-1 for training and 1 for
%   evaluation. This step is repeated r times and the overall mean of the
%   evaluation scores is reported.
%
%   conf = CVMDA(classes, R, K) returns the (un-normalized) confusion
%       matrix of the model.
%       classes: { trainals_1, ..., trainals_C }
%           C...number of classes
%           trainals_i: n_i-by-D matrix.
%               D...number of features
%               n_i...number of trainals in class i
%       R: number of repetitions
%       K: number of folds
%
%   [conf, gamma] = CVMDA(classes, R, K) also returns the shrinkage
%       parameters. gamma is a K-by-C-by-R matrix.

    C = length(classes);  % number of classes

    % shrinkage parameter for each fold, class and repetition
    gamma = zeros(K, C, R);
    % confusion matrix for each repetition and fold
    confs = zeros(C, C, R, K);
    
    partitions = cell(1,C);
    for c=1:C
        partitions{c} = cvpartition(size(classes{c},1),'KFold',K);
    end

    for r=1:R
        for c=1:C
            partitions{c} = repartition(partitions{c});
        end
        for k=1:K
            train_classes = cell(1, C);
            test_classes = cell(1, C);
            for c=1:C
                train_classes{c} = classes{c}(training(partitions{c}, k),:);
                test_classes{c} = classes{c}(test(partitions{c}, k),:);
            end
            [classify, gamma(k, :, r)] = train_mda(train_classes);
            for c=1:C
                confs(c, :, r, k) = sum(classify(test_classes{c}) == (1:C), 1);
            end
        end
    end
    conf = sum(confs, [3 4]);
end

