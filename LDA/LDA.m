function [a, gamma] = LDA(classes, regularize, gpu, dtype)
%LDA train shrinkage-based linear discriminant model and return weights.
%   a = LDA(classes, r) returns the weights incl. bias.
%       classes: { trainals_1, ..., trainals_C }
%           C...number of classes
%           trainals_i: n_i-by-D matrix (training data)
%               D...number of features
%               n_i...number of trainals in class i
%       regularize: (optional) amount of regularization, if < 0: calculate parameter (default: -1)
%       gpu: (optional) logical, whether to run on GPU (default: true)
%       a: C-by-D+1 matrix ([w_0 w])
%   [a, gamma] = LDA(classes) also returns the shrinkage
%       parameter used for each class (C-by-1 column vector) (0 if
%       regularization is not enabled).
%
%   Based on [Duda et al., 2001]
%
%   References:
%   [Duda et al., 2001] Duda, R.O., Hart, P.E., Stork, D.G., 2001. Pattern Classification, 2nd Edition. Wiley & Sons.

    if nargin < 2
        regularize = -1;
    end
    if nargin < 3
        gpu = true;
    end
    if nargin < 4
        dtype = 'single';
    end

    C = length(classes);      % number of classes
    D = size(classes{1}, 2);  % number of features (assumend equal for all classes)

    Ni = zeros(1,1,C);  % number of trainals for each class (in third dim)

    dmean = zeros(C, D, dtype);
    gamma = zeros(C,1);   % shrinkage parameter for each class
    covs = zeros(D, D, C, dtype);
    for c = 1:C
        Ni(1,1,c) = size(classes{c}, 1);

        dmean(c, :) = mean(classes{c}, 1);  % mean over class i

        % shrink each covariance before summing up (significant difference
        % to 'first sum, then shrink')
        [covs(:,:,c), gamma(c)] = scov(classes{c}, dmean(c,:), regularize, gpu);
    end
    N = sum(Ni, 3);      % number of trainals overall

    % pooled covariance = sum of weighted covariances using n-1 as weights
    % (bessel's correction)
    covmat = sum( (Ni-1)/(N-C) .* covs, 3);

    a = zeros(C,D+1);  % weights incl. bias a = [w_0 w]
    for c = 1:C
        % eq (59), section 2.6.2 in [Duda et al., 2001]
        a(c,2:end) = dmean(c,:) / covmat;  % w

        % eq (60), section 2.6.2 in [Duda et al., 2001]
        % (prior is assumed to be uniform)
        a(c,1) = -0.5 * a(c,2:end) * dmean(c,:)';  % w_0
    end
end
