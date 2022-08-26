function [test_conf, timepoint, calib_conf, calib_gamma, test_gamma] = run_classification_for(calib_classes, test_classes, config)
%RUN_CLASSIFICATION_FOR Run classification for given calibration and test classes.

    % check inputs    
    if nargin < 3
        config = struct();
    end

    C = length(calib_classes);
    if (length(test_classes) ~= C)
        error('different number of calibration and test classes');
    end
    calib_sizes = zeros(C, 3);
    for c=1:C
        calib_sizes(c, :) = size(calib_classes{c});
    end
    L = calib_sizes(1,2);  % length of each trial
    if ~all(calib_sizes(:,2) == L)
        error('all trials must have same length');
    end
    test_sizes = zeros(C, 3);
    for c=1:C
        test_sizes(c, :) = size(test_classes{c});
    end
    L = test_sizes(1,2);  % length of each trial
    if ~all(test_sizes(:,2) == L)
        error('all trials must have same length');
    end

    [classify, T, timepoint, calib_conf, calib_gamma, test_gamma] = calibrate_model(calib_classes, config);

    % test winning model for each timepoint
    fprintf('Testing winning model.\n');
    test_conf = test_model(test_classes, classify, T, t_indices, config);
end
