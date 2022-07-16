function acl = adjust_chance_level(naive, n, alpha, multcomp)
% ADJUST_CHANCE_LEVEL Adjust naive chance level using binomial CDF.
%   naive: Chance level for infinite samples (1/n_classes)
%   n: number of samples
%   alpha: statistical significance level 
%   multcomp: multiple comparisons to correct for
%   
%   according to section 3.2 2015_Combrisson, number of folds and
%   repetitions don't make a difference in the adjusted chance level.

    % config
    if nargin < 4
        multcomp = 1;  % number of comparisons to correct with bonferroni
    end
    if nargin < 3
        alpha = 0.05;  % un-corrected significance level
    end

    % calc
    n = round(n);  % must be integer
    alpha_corr = alpha / multcomp;
    acl = binoinv(1-alpha_corr, n, naive) / n;
end
