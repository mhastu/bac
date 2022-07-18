% runs the classification cross-participant
% workspace then contains the confusion matrices and scores per timepoint
%
% steps:
% 1. configure
% 2. run

% imports
% reuse functions for single-participant classification
addpath classification_reproduction
addpath datafunc
addpath plot

warning("off","parallel:gpu:device:DeviceDeprecated");

load('config.mat', 'dir_training_datasets');
load('config.mat', 'dir_results');

% =========================================================================
% CONFIG
% -------------------------------------------------------------------------
filename = '_preprocessed_without_ica.mat';
filename_save = '_G_without_ica_norm.mat';
cv_repetitions = 1;  % we should have enough data for accurate results without repeating cv
amplitude_normalization = true;  % whether to normlize participants by GFP
device_i = 1;  % device index to use
% =========================================================================

% ============================= load all data =============================
devices = {'G', 'V', 'H'};
classes = cell(15, 3);  % 15 participants, 3 classes
for p=1:15
    id = [devices{device_i} num2str(p, '%02d')];
    classes_ = load( ...
        [dir_training_datasets id filename], ...
        'rest', 'palmar', 'lateral');
    classes{p,1} = classes_.rest;
    classes{p,2} = classes_.palmar;
    classes{p,3} = classes_.lateral;
    clearvars classes_;
end
if amplitude_normalization
    % schwarz 2020, section G
    % normalize participant-specific potentials by average GFP during rest
    classes = normalize_participants(classes, 1);
end
% =========================================================================

calib_conf = cell(3, 15);
calib_gamma = cell(3, 15);
test_conf = cell(3, 15);
test_gamma = cell(3, 15);
timepoint = cell(3, 15);
run_times = zeros(3, 15);
for p=1:15
    tic;
    fprintf('CP-classification: test participant %d.\n', p);
    calib_p_indices = [1:p-1 p+1:15];

    calib_classes = {cat(3, classes{calib_p_indices,1}),...
        cat(3, classes{calib_p_indices,2}),...
        cat(3, classes{calib_p_indices,3})};
    test_classes = {classes{p,1}, classes{p,2}, classes{p,3}};

    [test_conf{device_i, p}, timepoint{device_i, p}, calib_conf{device_i, p}, ...
    calib_gamma{device_i, p}, test_gamma{device_i, p}] = ...
        run_classification_for(calib_classes, test_classes, cv_repetitions);

    run_times(device_i, p) = toc;
end

save([dir_results 'CP_classification' filename_save], 'calib_conf', 'calib_gamma', 'test_conf', 'test_gamma', 'timepoint', 'run_times');
plot_results([], ['CP_classification' filename_save], 'CP', device_i, filename, 14/15);
