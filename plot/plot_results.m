function fig_results = plot_results(fig_results, filename_result, method, Devs, filename_train, calib_cut)

% use only test_conf and calib_conf
% grand average = over all participants
%
% using calib_conf: calculate the grand average confusion matrix for each
% timepoint and their corresponding accuracies (figure5/topleft). Find the
% best accuracy (corresponding conf mat = figure5/topright).
%
% using test_conf: Plot the accuracy for each participant (gray lines in
% figure5/bottomleft). Figure5/bottomright = Average of the confusion
% matrices corresponding to the peak accuracy of each participant.
% Calculate grand average confusion matrix for each timepoint
% (accuracy=black line in figure5/bottomleft).
%
% TODO: also calculate the standard deviation of the accuracies in the WOI
% for calib and test for each participant. (80 percentage values --> peak
% (best timepoint) is the highest, STD can be calculated). For Table 1.

% imports
addpath datafunc
addpath util

%% config
load('config.mat', 'dir_training_datasets');
load('config.mat', 'dir_results');

if nargin < 6
    calib_cut = 0.66;
    %calib_cut = 14/15;
end
if nargin < 5
    filename_train = '_preprocessed.mat';
end
if nargin < 4
    Devs = 2;  % device indices to use (gel G, water V, dry H)
end
if nargin < 3
    method = 'rep';  % one of ['rep', 'CP']
end
if nargin < 2
    filename_result = 'classification_V_randcalib.mat';
end
% use same figures if possible
if nargin < 1 || ~iscell(fig_results) || ~(length(fig_results) == 3)
    fig_results = cell(1, 3);
end


alpha = 0.05;  % statistical significance level

% timepoint config
WOI = [-2 3];        % window of interest in seconds (open on left side)
fs = 16;
t = WOI(1)+1/fs:1/fs:WOI(2);
T = length(t);

systems = {'G', 'V', 'H'};

%% style config
device_color = {[0.9290 0.6940 0.1220], [0.133 0.471 0.698], [0.38 0.137 0.424]};  % accent color of each device

%% load results
load(fullfile(dir_results, filename_result), ...
     'calib_conf', 'test_conf');
C = 3;  % number of classes
np = size(calib_conf,2);  % number of participants

%% convert cells
calib_conf_mat = zeros(C, C, T, size(calib_conf,1), size(calib_conf,2));
for dev=Devs
    for p=1:size(calib_conf,2)
        calib_conf_mat(:,:,:,dev,p) = calib_conf{dev,p};
    end
end
test_conf_mat = zeros(C, C, T, size(test_conf,1), size(test_conf,2));
for dev=Devs
    for p=1:size(test_conf,2)
        test_conf_mat(:,:,:,dev,p) = test_conf{dev,p};
    end
end

%%
for dev=Devs
    if isempty(fig_results{dev}) || ~isvalid(fig_results{dev}) || ~strcmp(fig_results{dev}.Name, filename_result)
        fig_results{dev} = figure();
    else
        fig_results{dev} = figure(fig_results{dev});
    end
    fig_results{dev}.Name = filename_result;
    clf;
    tiledlayout(2, 2, 'TileSpacing', 'tight');
    % ------------------ CALIB (TOP ROW) ----------------------
    %% calc
    % accuracy for each participant (dim5) over whole WOI (dim3)
    calib_pspec_accuracy = sum(calib_conf_mat(:,:,:,dev,:) .* eye(C), [1,2]) ./ sum(calib_conf_mat(:,:,:,dev,:), [1,2]);
    % training size is the same for all participants, so we can take the
    % unweighted mean over all participants.
    calib_pmean_accuracy = mean(calib_pspec_accuracy, 5);  % grand average mean accuracy
    calib_pmean_accuracy = permute(calib_pmean_accuracy, [1 3 2]);  % convert to row vector
    [calib_pmean_peak_accuracy, best_timepoint_i] = max(calib_pmean_accuracy);

    calib_std = std(calib_pspec_accuracy, 1, 5);
    calib_std = permute(calib_std, [1 3 2]);  % convert to row vector

    % calib_significance = 0.458;
    switch(method)
        case 'rep'
            calib_significance = adjust_chance_level(1/C, calib_cut*num_trials_in_sys(systems{dev}, dir_training_datasets, filename_train)/np,alpha,T);
        case 'CP'
            calib_significance = adjust_chance_level(1/C, calib_cut*num_trials_in_sys(systems{dev}, dir_training_datasets, filename_train),alpha,T);
        otherwise
            error('unknown method');
    end

    calib_pmean_confmat = sum(calib_conf_mat(:,:,:,dev,:), 5);  % confmat over all participants
    calib_pmean_confmat_normalized = calib_pmean_confmat ./ sum(calib_pmean_confmat, 2);

    %% plot grand average calib accuracy
    nexttile(1);
    cla;
    xline(0, 'HandleVisibility', 'off');
    hold on;
    box off;
    ylim([0 100])
    xlim(WOI)

    plot_calib_mean = plot(t, calib_pmean_accuracy .* 100, 'x', 'MarkerEdgeColor', [0.4, 0.4, 0.4], 'MarkerSize', 7, 'LineWidth', 1.5);
    yline(100/3);
    yline(calib_significance*100, 'g--', 'LineWidth', 3)
    plot_std(t, calib_pmean_accuracy * 100, calib_std * 100)
    plot_calib_peak = stem(t(best_timepoint_i), calib_pmean_peak_accuracy * 100, 'filled', 'Color', device_color{dev}, 'LineWidth', 3);

    legend('mean', 'cue', ['significance: ' num2str(calib_significance*100, '%.1f') '%'], 'Standard deviation', ['max acc: ' num2str(calib_pmean_peak_accuracy*100, '%.1f') '%'])
    uistack(plot_calib_mean', 'top')
    uistack(plot_calib_peak', 'top')

    xlabel('time (s)')
    ylabel('Accuracy (%)')
    title({'Grand average Calibration Dataset:', 'Best performing Classification model in WOI (%)'})

    %% plot conf mat corresponding to peak of grand average calib accuraccy
    nexttile(2);
    cla;
    plotConfMat(calib_pmean_confmat_normalized(:,:,best_timepoint_i), {'rest', 'pal', 'lat'}, 'Grand average peak performance (%)', device_color{dev})
    % ---------------------------------------------------------
    % ------------------ TEST (BOTTOM ROW) ---------------------
    %% calc
    % accuracy for each participant (dim5) over whole WOI (dim3)
    test_pspec_accuracy = sum(test_conf_mat(:,:,:,dev,:) .* eye(C), [1,2]) ./ sum(test_conf_mat(:,:,:,dev,:), [1,2]);
    test_pmean_accuracy = mean(test_pspec_accuracy, 5);
    [test_pspec_peak_accuracy, test_pspec_best_timepoint_i] = max(test_pspec_accuracy, [], 3);

    test_pspecmean_confmat = zeros(C, C, size(test_conf,2));
    for p=1:size(test_conf,2)
        % best timepoint index for each participant
        best_timepoint_indices = permute(test_pspec_best_timepoint_i, [5 1 2 3 4]);
        % assign the participant-specific performance peaks to the confmat
        test_pspecmean_confmat(:,:,p) = test_conf_mat(:,:,best_timepoint_indices(p),dev,p);
    end
    test_pspecmean_confmat = sum(test_pspecmean_confmat, 3);
    test_pspecmean_confmat_normalized = test_pspecmean_confmat ./ sum(test_pspecmean_confmat, 2);

    % test_significance = 0.428;
    switch(method)
        case 'rep'
            test_significance = adjust_chance_level(1/C, (1-calib_cut)*num_trials_in_sys(systems{dev}, dir_training_datasets, filename_train)/np,alpha,T);
        case 'CP'
            test_significance = adjust_chance_level(1/C, (1-calib_cut)*num_trials_in_sys(systems{dev}, dir_training_datasets, filename_train),alpha,T);
        otherwise
            error('unknown method');
    end

    %% plot participant specific test accuracy over whole WOI
    nexttile(3);
    cla;
    xline(0, 'HandleVisibility', 'off');
    hold on
    box off;
    ylim([0 100])
    xlim(WOI)

    for p=1:(size(test_conf_mat, 5)-1)
        plot(t, permute(test_pspec_accuracy(:,:,:,:,p), [1 3 2]) .* 100, '-', 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.7, 'HandleVisibility', 'off');
        stem(t(test_pspec_best_timepoint_i(:,:,:,:,p)), test_pspec_peak_accuracy(:,:,:,:,p) * 100, 'filled', 'Color', device_color{dev}, 'LineStyle', 'none', 'HandleVisibility', 'off');
    end
    % make last participant test plot visible for legend
    p = size(test_conf_mat, 5);
    plot(t, permute(test_pspec_accuracy(:,:,:,:,p), [1 3 2]) .* 100, '-', 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.7);
    stem(t(test_pspec_best_timepoint_i(:,:,:,:,p)), test_pspec_peak_accuracy(:,:,:,:,p) * 100, 'filled', 'Color', device_color{dev}, 'LineStyle', 'none');

    plot(t, permute(test_pmean_accuracy, [1 3 2]) .* 100, '-', 'Color', 'black', 'LineWidth', 2);
    yline(test_significance*100, 'g--', 'LineWidth', 3)

    legend('participant accuracy', 'participant peak', 'grand average participant accuracy', ['significance: ' num2str(test_significance*100, '%.1f') '%'])

    xlabel('time (s)')
    ylabel('Accuracy (%)')
    title({'Best performing Classification model', 'applied on unseen Testdata'})

    %% plot conf mat corresponding to peak of grand average calib accuraccy
    nexttile(4);
    cla;
    plotConfMat(test_pspecmean_confmat_normalized, {'rest', 'pal', 'lat'}, 'Grand average participant peaks (%)', device_color{dev})
    % ---------------------------------------------------------
end

end





















