% runs the classification cross-participant
% workspace then contains the confusion matrices and scores per timepoint
%
% steps:
% 1. configure
% 2. run

% imports
% reuse functions from single-participant classification
addpath classification_reproduction
addpath datafunc
addpath plot

warning("off","parallel:gpu:device:DeviceDeprecated");

load('config.mat', 'dir_training_datasets');
load('config.mat', 'dir_results');

% =========================================================================
% CONFIG
% -------------------------------------------------------------------------
filename = '_preprocessed.mat';
filename_save = '_G_allnorm_noreg.mat';
electrode_normalization = true;  % whether to normalize the electrodes by average Power
participant_normalization = true;  % whether to normalize participants by GFP
device_i = 1;  % device index to use, 1..3 for {'G', 'V', 'H'}

config = struct();
config.cv_repetitions = 1;  % we should have enough data for accurate results without repeating cv
config.regularize = 0;  % amount of regularization (0-1, 0 for no regularization, -1 to automatically calculate)
config.n_workers = 4;  % number of workers for parallel computing (1 for single-trheaded)
config.dtype = 'single';
config.gpu = false;

notify = false;  % play sound when finished
% =========================================================================

% ============================= load all data =============================
devices = {'G', 'V', 'H'};
classes = cell(15, 3);  % 15 participants, 3 classes
for p=1:15
    classes(p,:) = load_classes(filename, devices{device_i}, p).';
end
if electrode_normalization
    % normalize electrode-specific potentials by average Power during rest
    classes = normalize_electrodes(classes, 1);
end
if participant_normalization
    % schwarz 2020, section G
    % normalize participant-specific potentials by average GFP during rest
    classes = normalize_participants(classes, 1);
end
% =========================================================================

description = "3-by-15 cells: 3 systems, 15 test participants (trained on the other 14)";
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
        run_classification_for(calib_classes, test_classes, config);

    run_times(device_i, p) = toc;
end

save(fullfile(dir_results, ['CP_classification' filename_save]), 'calib_conf', 'calib_gamma', 'test_conf', 'test_gamma', 'timepoint', 'run_times', 'description', 'devices', 'config');
plot_results([], ['CP_classification' filename_save], 'CP', device_i, filename, 14/15);

if notify
    % play success sound
    load handel.mat;
    sound(y,Fs);
end
