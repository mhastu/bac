function [out_trials] = normalize_trials(trials, method)
%NORMALIZE_TRIALS Normalize trials by min/max and remove baseline.
%
%   out_trials = NORMALIZE_TRIALS(trials, method) normalizes given trials
%       by method (default: minmax).
%       if method=='minmax':
%           (max - min) --> 100;
%           mean --> 0;
%       if method=='quantile':
%           (q.95 - q.05) --> 100;
%           q.50 --> 0;
%       (out_)trials: R-by-L-by-N matrix
%           R...number of channels
%           L...number of ampvals in trial
%           N...number of trials

    if nargin < 2
        method = 'minmax';
    end

    switch method
        case 'minmax'
            mins = min(trials, [], [1 2]);
            maxs = max(trials, [], [1 2]);
            out_trials = trials * 100 ./ (maxs - mins);
        
            means = mean(trials, [1 2]);
            out_trials = out_trials - means;
        case 'quantile'
            q = quantile(trials, [0.05, 0.5, 0.95], [1 2]);
            q05 = q(1,:,:);
            med = q(2,:,:);
            q95 = q(3,:,:);
            out_trials = trials * 100 ./ (q95 - q05);
            out_trials = out_trials - med;
        otherwise
            error('invalid method.');
    end
end

