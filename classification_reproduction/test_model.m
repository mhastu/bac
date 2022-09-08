function [test_conf] = test_model(test_classes, classify, T, t_indices, config)
    C = length(test_classes);
    test_sizes = zeros(C, 3);
    for c=1:C
        test_size = size(test_classes{c});
        if length(test_size) ~= 3
            error('test_classes must be 3-dimensional')
        end
        test_sizes(c, :) = test_size;
    end
    L = test_sizes(1,2);  % length of each trial
    if ~all(test_sizes(:,2) == L)
        error('all trials must have same length');
    end

    test_conf = zeros(C, C, T);
    for t=1:T
        for c=1:C
            test_data = get_trainals_for_timepoint(test_classes{c}, t_indices, int32(t), config);
            test_conf(c, :, t) = sum(classify(test_data) == (1:C), 1);
        end
    end
end
