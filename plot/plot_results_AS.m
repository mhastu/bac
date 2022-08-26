function fig_results = plot_results_AS(filename_result, filename_train)

% imports
addpath datafunc
addpath util

%% config
load('config.mat', 'dir_training_datasets');
load('config.mat', 'dir_results');

if nargin < 2
    filename_train = '_preprocessed.mat';
end
if nargin < 1
    filename_result = 'AS_classification.mat';
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
calib_conf_mat = zeros(C, C, T, size(calib_conf,2));
for p=1:size(calib_conf,2)
    calib_conf_mat(:,:,:,p) = calib_conf{p};
end
test_conf_mat = zeros(C, C, T, size(test_conf,1), size(test_conf,2));
for dev=1:size(test_conf,1)
    for p=1:size(test_conf,2)
        test_conf_mat(:,:,:,dev,p) = test_conf{dev,p};
    end
end

%%
% caching:
num_trials_per_sys = zeros(3,1);
for dev=1:3
    num_trials_per_sys(dev) = num_trials_in_sys(systems{dev}, dir_training_datasets, filename_train);
end

calib_and_gel = figure();
tiledlayout(2, 2, 'TileSpacing', 'tight');
% ------------------ CALIB (TOP ROW) ----------------------
%% calc
% accuracy for each participant (dim4) over whole WOI (dim3)
calib_pspec_accuracy = sum(calib_conf_mat(:,:,:,:) .* eye(C), [1,2]) ./ sum(calib_conf_mat(:,:,:,:), [1,2]);
% unweighted mean over all participants
calib_pmean_accuracy = mean(calib_pspec_accuracy, 4);  % grand average mean accuracy
calib_pmean_accuracy = permute(calib_pmean_accuracy, [1 3 2]);  % convert to row vector
[calib_pmean_peak_accuracy, best_timepoint_i] = max(calib_pmean_accuracy);

calib_std = std(calib_pspec_accuracy, 1, 4);
calib_std = permute(calib_std, [1 3 2]);  % convert to row vector

calib_significance = adjust_chance_level(1/C, sum(num_trials_per_sys)*14/15,alpha,T);

calib_pmean_confmat = sum(calib_conf_mat(:,:,:,:), 4);  % confmat over all participants
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
calib_legend_entries = {'mean', 'cue', ['significance: ' num2str(calib_significance*100, '%.1f') '%'], 'Standard deviation', ['max acc: ' num2str(calib_pmean_peak_accuracy*100, '%.1f') '%']};

plot_calib_peak = stem(t(best_timepoint_i), calib_pmean_peak_accuracy * 100, 'filled', 'Color', device_color{dev}, 'LineWidth', 3);

legend(calib_legend_entries{:})
uistack(plot_calib_mean', 'top')
uistack(plot_calib_peak', 'top')

xlabel('time (s)')
ylabel('Accuracy (%)')
title({'Grand average Calibration Dataset:', 'Best performing Classification model in WOI (%)'})

%% plot conf mat corresponding to peak of grand average calib accuraccy
nexttile(2);
cla;
plotConfMat(calib_pmean_confmat_normalized(:,:,best_timepoint_i), {'rest', 'pal', 'lat'}, 'Grand average peak performance (%)')
% ---------------------------------------------------------
% ------------------ TEST ---------------------------------
%% calc
% accuracy for each participant (dim5) over whole WOI (dim3)
for dev=1:3
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

    test_significance = adjust_chance_level(1/C, sum(num_trials_per_sys)/15,alpha,T);

    %% plot participant specific test accuracy over whole WOI
    switch dev
        case 1
            nexttile(3);
        case 2
            % device 2 and 3 in new figure
            versatile_and_hero = figure();
            tiledlayout(2, 2, 'TileSpacing', 'tight');
            nexttile(1);
        case 3
            nexttile(3);
    end
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
    switch dev
        case 1
            nexttile(4);
        case 2
            % device 2 and 3 in new figure
            nexttile(2);
        case 3
            nexttile(4);
    end
    cla;
    plotConfMat(test_pspecmean_confmat_normalized, {'rest', 'pal', 'lat'}, 'Grand average participant peaks (%)', device_color{dev})
    % ---------------------------------------------------------

end





















