function [test_conf, timepoint, calib_conf, calib_gamma, test_gamma] = run_classification_for(calib_classes, test_classes, cv_repetitions, n_workers, regularize, dtype)
%RUN_CLASSIFICATION_FOR Run classification for given calibration and test classes.

    % imports
    addpath datafunc
    addpath LDA

    % check inputs
    C = length(calib_classes);
    if (length(test_classes) ~= C)
        error('different number of calibration and test classes');
    end
    calib_sizes = zeros(C, 3);
    test_sizes = zeros(C, 3);
    for c=1:C
        calib_sizes(c, :) = size(calib_classes{c});
    end
    for c=1:C
        test_sizes(c, :) = size(test_classes{c});
    end
    L = calib_sizes(1,2);  % length of each trial
    if ~all(calib_sizes(:,2) == L)
        error('all trials must have same length');
    end

    if nargin < 3
        cv_repetitions = 10;  % default
    end
    if nargin < 4
        n_workers = 4;  % default
    end
    if nargin < 5
        regularize = -1;  % default
    end
    if nargin < 6
        dtype = 'single';  % default
    end
    % config
    WOI = [-2 3];        % window of interest in seconds (open on left side)
    feature_length = 9;  % number of ampvals before the point of interest
    feature_gap = 2;     % #ampvals between two features
    fs = 16;             % for calculation of timepoint in seconds

    % feature indices w.r.t. the timepoint
    t_indices = int32(0:feature_gap:(feature_length-1)*feature_gap);

    [timepoint_i, calib_conf, calib_gamma] = best_timepoint(calib_classes, t_indices, cv_repetitions, n_workers, regularize, dtype);
    timepoint = WOI(1) + timepoint_i/fs; % count-based timepoint index omits left limit of WOI

    T = L - t_indices(end);  % number of timepoints

    % train winning model (best timepoint) again with all calibration data
    fprintf('Training winning model.\n');
    calib_data = cell(1, C);
    for c=1:C
        calib_data{c} = get_trainals_for_timepoint(calib_classes{c}, t_indices, timepoint_i, dtype);
    end
    [classify, test_gamma] = train_mda(calib_data, regularize, dtype);

    % test winning model for each timepoint
    fprintf('Testing winning model.\n');
    test_conf = zeros(C, C, T);
    for t=1:T
        for c=1:C
            test_data = get_trainals_for_timepoint(test_classes{c}, t_indices, int32(t), dtype);
            test_conf(c, :, t) = sum(classify(test_data) == (1:3), 1);
        end
    end
end
