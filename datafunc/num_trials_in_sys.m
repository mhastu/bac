function n = num_trials_in_sys(sys, dir, filename_end)
%NUM_TRIALS_IN_SYS Number of trials in system after preprocessing.

    np = 15;  % number of participants
    vars = {'rest', 'palmar', 'lateral'};  % variable names containing samples
    sample_dim = 3;  % dimension in which the samples are stored in above vars

    n = 0;
    for p=1:np
        id = [sys num2str(p, '%02d')];  % e.g. 'G01'
        matObj = matfile([dir id filename_end]);
        for i=1:length(vars)  % add number of samples of all classes to n
            nadd = size(matObj,vars{i},sample_dim);
            n = n + nadd;
        end
    end
end
