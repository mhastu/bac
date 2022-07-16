function [timepoint_i, conf, gamma] = best_timepoint(classes, t_indices, cv_repetitions)
%BEST_TIMEPOINT Find best time point in WOI.
%
%   timepoint_i = BEST_TIMEPOINT(classes, t_indices) returns the timepoint
%       index (in t_indices) of the best performing model.
%       classes: {trials_1, trials_2, ...}
%           trials_i: R x L x N matrix
%               R...number of channels
%               L...number of ampvals per trial
%               N...number of trials
%       t_indices: indices of the amplitude values used as features w.r.t.
%           the timepoint.
%
%   [timepoint_i, conf] = BEST_TIMEPOINT(classes, t_indices)
%       also returns the confusion matrix for each timepoint in the WOI
%       (C x C x T matrix).
%
%   [timepoint_i, conf, gamma] = BEST_TIMEPOINT(classes, t_indices)
%       also returns the gamma values for each fold, class, repetition and
%       timepoint.

    %config
    if nargin < 3
        cv_repetitions = 10;
    end
    cv_fold = 5;

    fprintf('Finding best timepoint:');
    
    C = length(classes);
    sizes = zeros(C, 3);
    for i=1:C
        sizes(i, :) = size(classes{i});
    end
    % check inputs
    L = sizes(1,2);  % length of each trial
    if ~all(sizes(:,2) == L)
        error('all trials must have same length');
    end

    T = L - t_indices(end);  % number of timepoints
    gamma = zeros(cv_fold, C, cv_repetitions, T);

    confs = zeros(C, C, T);    % confusion matrix for each timepoint
    accuracies = zeros(1, T);  % accuracy for each timepoint
    trainclasses = cell(T, C); % trainals for each timepoint and class
    for t=1:T
        for c=1:C
            trainclasses{t, c} = get_trainals_for_timepoint(classes{c}, t_indices, t);
        end
    end
    % for parallel: parfor, for non-parallel: for
    parfor t=1:T
        [confs(:,:,t), gamma(:,:,:,t)] = cvmda(trainclasses(t, :), cv_repetitions, cv_fold);
        accuracies(t) = sum(diag(confs(:,:,t))) / sum(confs(:,:,t), 'all') / C;
        %confs(:,:,t) = confs(:,:,t) ./ sum(confs(:,:,t), 2);  % row-wise normalize
        fprintf('\b|\n');
    end
    [~, timepoint_i] = max(accuracies);
    %conf = confs(:,:,timepoint_i);
    conf = confs;  % report the un-normalized confusion-matrices for all timepoints
end

