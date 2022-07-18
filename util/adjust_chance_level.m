function acl = adjust_chance_level(naive, n, alpha, multcomp)
% ADJUST_CHANCE_LEVEL Adjust naive chance level using binomial CDF.
%   naive: Chance level for infinite samples (1/n_classes)
%   n: number of samples
%   alpha: statistical significance level 
%   multcomp: multiple comparisons to correct for
%
%   According to section 3.2 in [Combrisson et al., 2015], number of folds
%   and repetitions don't make a difference in the adjusted chance level.
%
%   References:
%   [Combrisson et al., 2015]: [Combrisson et al., 2015] Combrisson, E., Jerbi, K. (2015). "Exceeding chance level by chance: The caveat of theoretical chance levels in brain signal classification and statistical assessment of decoding accuracy". Journal of Neuroscience Methods, Volume 250, 2015, Pages 126-136. https://dx.doi.org/10.1016/j.jneumeth.2015.01.010

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
    % section 2.2 in [Combrisson et al., 2015]
    acl = binoinv(1-alpha_corr, n, naive) / n;
end
