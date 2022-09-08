function [test_conf, timepoint, calib_conf, calib_gamma, test_gamma] = run_LS_classification_for(calib_classes, test_classes, config)
%RUN_LS_CLASSIFICATION_FOR Run Leaveout-System-classification for given calibration and test classes.

    % check inputs    
    if nargin < 3
        config = struct();
    end

    C = size(calib_classes, 2);
    if (size(test_classes, 2) ~= C)
        error('different number of calibration and test classes');
    end

    [classify, T, t_indices, timepoint, calib_conf, calib_gamma, test_gamma] = calibrate_model(calib_classes, config);

    % test winning model for each timepoint and each participant
    fprintf('Testing winning model on each participant.\n');
    P = size(test_classes,1);  % number of test participants
    test_conf = cell(1, P);
    for p=1:P
        test_conf{p} = test_model(test_classes(p,:), classify, T, t_indices, config);
    end
end
