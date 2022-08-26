function [classify, T, t_indices, timepoint, calib_conf, calib_gamma, test_gamma] = calibrate_model(calib_classes, config)
%CALIBRATE_MODEL Calibrate model by finding best timepoint.

    if nargin < 2
        config = struct();
    end

    C = size(calib_classes, 2);
    calib_sizes = zeros(C, 3);
    for c=1:C
        calib_sizes(c, :) = size(calib_classes{c});
    end
    L = calib_sizes(1,2);  % length of each trial
    if ~all(calib_sizes(:,2) == L)
        error('all trials must have same length');
    end

    % imports
    addpath datafunc
    addpath LDA

    % config
    WOI = [-2 3];        % window of interest in seconds (open on left side)
    feature_length = 9;  % number of ampvals before the point of interest
    feature_gap = 2;     % #ampvals between two features
    fs = 16;             % for calculation of timepoint in seconds

    % feature indices w.r.t. the timepoint
    t_indices = int32(0:feature_gap:(feature_length-1)*feature_gap);
    T = L - t_indices(end);  % number of timepoints

    [timepoint_i, calib_conf, calib_gamma] = best_timepoint(calib_classes, t_indices, config);
    timepoint = WOI(1) + timepoint_i/fs; % count-based timepoint index omits left limit of WOI

    % train winning model (best timepoint) again with all calibration data
    fprintf('Training winning model.\n');
    calib_data = cell(1, C);
    for c=1:C
        calib_data{c} = get_trainals_for_timepoint(calib_classes{c}, t_indices, timepoint_i, config);
    end
    [classify, test_gamma] = train_mda(calib_data, config);
end
