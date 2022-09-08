function [timepoint_i, conf, gamma] = best_timepoint(classes, t_indices, config)
%BEST_TIMEPOINT Find best time point in WOI.
%
%   timepoint_i = BEST_TIMEPOINT(classes, t_indices, cv_repetitions,
%                 n_workers) returns the timepoint index (in t_indices) of
%                 the best performing model.
%       classes: { trials_1, ..., trials_C }
%           C...number of classes
%           trials_i: R-by-L-by-N matrix
%               R...number of channels
%               L...number of ampvals per trial
%               N...number of trials
%       t_indices: indices of the amplitude values used as features w.r.t.
%           the timepoint.
%       config.cv_repetitions: (optional) how often to repeat cross-validation
%           (default: 10)
%       config.n_workers: (optional) number of workers for parallel computing
%           (default: 4)
%
%   [timepoint_i, conf] = BEST_TIMEPOINT(classes, t_indices)
%       also returns the confusion matrix for each timepoint in the WOI
%       (C-by-C-by-T matrix).
%
%   [timepoint_i, conf, gamma] = BEST_TIMEPOINT(classes, t_indices)
%       also returns the gamma values for each fold, class, repetition and
%       timepoint.

    % imports
    addpath datafunc
    addpath LDA

    %config
    if nargin < 3
        config = struct();
    end
    if ~isfield(config, 'cv_repetitions')
        config.cv_repetitions = 10;
    end
    if ~isfield(config, 'cv_fold')
        config.cv_fold = 5;
    end
    if ~isfield(config, 'n_workers')
        config.n_workers = 4;
    end

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
    gamma = zeros(config.cv_fold, C, config.cv_repetitions, T);

    confs = zeros(C, C, T);    % confusion matrix for each timepoint
    accuracies = zeros(1, T);  % accuracy for each timepoint
    trainclasses = cell(T, C); % trainals for each timepoint and class
    for t=1:T
        for c=1:C
            trainclasses{t, c} = get_trainals_for_timepoint(classes{c}, t_indices, t, config);
        end
    end
    if config.n_workers > 1  % parallel computing
        p = gcp('nocreate'); % If no pool, do not create new one.
        if isempty(p)
            poolsize = 0;
        else
            poolsize = p.NumWorkers;
        end
        if poolsize ~= config.n_workers
            delete(p);
            parpool(config.n_workers);
        end
        fprintf('Finding best timepoint:');
        parfor t=1:T
            warning("off","parallel:gpu:device:DeviceDeprecated");
            [confs(:,:,t), gamma(:,:,:,t)] = cvmda(trainclasses(t, :), config);
            accuracies(t) = sum(diag(confs(:,:,t))) / sum(confs(:,:,t), 'all') / C;
            %confs(:,:,t) = confs(:,:,t) ./ sum(confs(:,:,t), 2);  % row-wise normalize
            fprintf('\b|\n');
        end
    else  % single-threaded
        fprintf('Finding best timepoint:');
        for t=1:T
            [confs(:,:,t), gamma(:,:,:,t)] = cvmda(trainclasses(t, :), config);
            accuracies(t) = sum(diag(confs(:,:,t))) / sum(confs(:,:,t), 'all') / C;
            %confs(:,:,t) = confs(:,:,t) ./ sum(confs(:,:,t), 2);  % row-wise normalize
            fprintf('\b|\n');
        end
    end
    [~, timepoint_i] = max(accuracies);
    conf = confs;  % report the un-normalized confusion-matrices for all timepoints
end

