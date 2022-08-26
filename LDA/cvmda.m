function [conf, gamma] = cvmda(classes, config)
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
%       config.cv_repetitions: number of repetitions
%       config.cv_fold: number of folds
%
%   [conf, gamma] = CVMDA(classes, R, K) also returns the shrinkage
%       parameters. gamma is a K-by-C-by-R matrix.

    if nargin < 2
        config = struct();
    end
    if ~isfield(config, 'cv_repetitions')
        config.cv_repetitions = 10;
    end
    if ~isfield(config, 'cv_fold')
        config.cv_fold = 5;
    end

    C = length(classes);  % number of classes

    % shrinkage parameter for each fold, class and repetition
    gamma = zeros(config.cv_fold, C, config.cv_repetitions);
    % confusion matrix for each repetition and fold
    confs = zeros(C, C, config.cv_repetitions, config.cv_fold);
    
    partitions = cell(1,C);
    for c=1:C
        partitions{c} = cvpartition(size(classes{c},1),'KFold',config.cv_fold);
    end

    for r=1:config.cv_repetitions
        for c=1:C
            partitions{c} = repartition(partitions{c});
        end
        for k=1:config.cv_fold
            train_classes = cell(1, C);
            test_classes = cell(1, C);
            for c=1:C
                train_classes{c} = classes{c}(training(partitions{c}, k),:);
                test_classes{c} = classes{c}(test(partitions{c}, k),:);
            end
            [classify, gamma(k, :, r)] = train_mda(train_classes, config);
            for c=1:C
                confs(c, :, r, k) = sum(classify(test_classes{c}) == (1:C), 1);
            end
        end
    end
    conf = sum(confs, [3 4]);
end

