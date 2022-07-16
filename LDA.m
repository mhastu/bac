function [a, gamma] = LDA(classes)
%LDA train shrinkage-based linear discriminant model and return weights.
%   a = LDA(trainals, trainal_labels) returns the weights incl. bias.
%       trainals: N-by-D matrix (training data)
%           N...number of samples
%           D...number of features
%       labels: N-by-1 matrix defining the class of each trainal (row in
%           trainals).
%   [a, gamma] = LDA(trainals, trainal_labels) also returns the shrinkage
%       parameter used for each class.
%
%   based on duda et al., 2001: pattern classification

    C = length(classes);      % number of classes
    D = size(classes{1}, 2);  % number of features (assumend equal for all classes)

    Ni = zeros(1,1,C);  % number of trainals for each class (in third dim)

    dmean = zeros(C, D, 'single');
    gamma = zeros(C,1);   % shrinkage parameter for each class
    shrunk_covs = zeros(D, D, C);
    for c = 1:C
        Ni(1,1,c) = size(classes{c}, 1);

        dmean(c, :) = mean(classes{c}, 1);  % mean over class i

        % shrink each covariance before summing up (significant difference
        % to 'first sum, then shrink')
        [shrunk_covs(:,:,c), gamma(c)] = scov(classes{c}, dmean(c,:));
    end
    N = sum(Ni, 3);      % number of trainals overall

    % pooled covariance = weighted covariances using n-1 as weights
    % (bessel's correction)
    covmat = sum( (Ni-1)/(N-C) .* shrunk_covs, 3);

    a = zeros(C,D+1);  % weights incl. bias a = [w_0 w]
    for c = 1:C
        %  eq (59), section 2.6.2 in duda
        a(c,2:end) = dmean(c,:) / covmat;  % w

        %  eq (60), section 2.6.2 in duda (prior is assumed uniform)
        a(c,1) = -0.5 * a(c,2:end) * dmean(c,:)';  % w_0
    end
end
