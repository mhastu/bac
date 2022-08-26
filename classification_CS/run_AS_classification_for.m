function [test_conf, timepoint, calib_conf, calib_gamma, test_gamma] = run_AS_classification_for(calib_classes, test_classes, config)
%RUN_AS_CLASSIFICATION_FOR Run All-System-classification for given calibration and test classes.

    % check inputs    
    if nargin < 3
        config = struct();
    end

    C = size(calib_classes, 2);
    if (size(test_classes, 2) ~= C)
        error('different number of calibration and test classes');
    end

    [classify, T, t_indices, timepoint, calib_conf, calib_gamma, test_gamma] = calibrate_model(calib_classes, config);

    % test winning model for each timepoint and each system
    fprintf('Testing winning model on each system.\n');
    test_conf = cell(size(test_classes,3), 1);
    for s=1:size(test_classes,3)
        test_conf{s} = test_model(test_classes(1,s,:), classify, T, t_indices, config);
    end
end
