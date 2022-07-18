function [classify, gamma] = train_mda(classes)
%TRAIN_MDA Train shrinkage-based multiple LDA bayes classifier.
%
%   classify = TRAIN_MDA(classes) returns the classify function of the
%       trained model which can be applied for evaluation.
%       classes: { trainals_1, ..., trainals_C }
%           C...number of classes
%           class i: n_i-by-D matrix.
%               D...number of features
%               n_i...number of trainals in class i
%
%   [classify, gamma] = TRAIN_MDA(classes) also returns the estimated
%       shrinkage parameters for each class (1-by-C matrix)

    C = length(classes);

    sizes = zeros(C, 2);
    for i=1:C
        sizes(i, :) = size(classes{i});
    end

    % check inputs
    if ~all(sizes(:,2) == sizes(1,2))
        error('all trainals must have same length');
    end

    [W, gamma] = LDA(classes);

    function [class_i] = classify_(z)
        % returns the estimated class indices of the given trainals
        %   z: n-by-m matrix.
        %       n...number of trainals
        %       m...number of features

        probs = zeros(size(z, 1), C);
        for c=1:C
            % discriminant function for class c (chapter 5.2.2 in duda)
            probs(:,c) = [ones(size(z, 1), 1) z] * W(c,:).';
        end

        % report indices of maximum probability
        [~, class_i] = max(probs, [], 2);
    end
    classify = @(z) classify_(z);
end
