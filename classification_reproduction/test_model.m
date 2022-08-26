function [test_conf] = test_model(test_classes, classify, T, t_indices, config)
    C = length(test_classes);
    test_sizes = zeros(C, 3);
    for c=1:C
        test_sizes(c, :) = size(test_classes{c});
    end
    L = test_sizes(1,2);  % length of each trial
    if ~all(test_sizes(:,2) == L)
        error('all trials must have same length');
    end

    test_conf = zeros(C, C, T);
    for t=1:T
        for c=1:C
            test_data = get_trainals_for_timepoint(test_classes{c}, t_indices, int32(t), config);
            test_conf(c, :, t) = sum(classify(test_data) == (1:3), 1);
        end
    end
end
