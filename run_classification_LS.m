% runs the classification cross-system
% (leaveout-system) 2 systems as training data, one as test
% workspace then contains the confusion matrices and scores per timepoint
%
% steps:
% 1. configure
% 2. run

% imports
% reuse functions from single-participant classification
addpath classification_reproduction
addpath classification_CS
addpath datafunc
addpath plot

warning("off","parallel:gpu:device:DeviceDeprecated");

load('config.mat', 'dir_training_datasets');
load('config.mat', 'dir_results');

% =========================================================================
% CONFIG
% -------------------------------------------------------------------------
filename = '_preprocessed.mat';
filename_save = '_allnorm_noreg.mat';
participant_normalization = true;  % whether to normalize participants by GFP
electrode_normalization = true;  % whether to normalize the electrodes by average Power

config = struct();
config.cv_repetitions = 1;  % we should have enough data for accurate results without repeating cv
config.regularize = 0;  % amount of regularization (0-1, 0 for no regularization, -1 to automatically calculate)
config.n_workers = 4;  % number of workers for parallel computing (1 for single-threaded)
config.dtype = 'single';
config.gpu = false;

notify = true;  % play sound when finished
% =========================================================================

% ============================= load all data =============================
common_electrodes = {'C1', 'C2', 'C3', 'C4', 'CP3', 'CP4', 'CPz', 'Cz', 'FC3', 'FC4', 'FCz'};
devices = {'G', 'V', 'H'};
classes = cell(15, 3, 3);  % 15 participants, 3 classes, 3 systems
for device_i=1:3
    for p=1:15
        classes(p,:,device_i) = load_classes(filename,devices{device_i},p,common_electrodes).';
    end
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

description = "calib: 3-by-1 (calibrated using all participants), test: 3-by-15 (tested on each participant)";
calib_conf = cell(3, 1);
calib_gamma = cell(3, 1);
timepoint = cell(3, 1);
win_gamma = cell(3, 1);
run_times = cell(3, 1);
test_conf = cell(3, 15);

for test_device_i=1:3
    fprintf(['test device: ' devices{test_device_i} '\n']);
    tic;
    calib_s_indices = [1:test_device_i-1 test_device_i+1:3];

    % all participants of all systems except test_device_i
    calib_classes = {...
        cat(3, classes{:,1,calib_s_indices}),...
        cat(3, classes{:,2,calib_s_indices}),...
        cat(3, classes{:,3,calib_s_indices})};
    % all participants of only system test_device_i
    test_classes = classes(:,:,test_device_i); % 15-by-3

    [test_conf(test_device_i, :), timepoint{test_device_i}, calib_conf{test_device_i}, calib_gamma{test_device_i}, win_gamma{test_device_i}] = ...
        run_LS_classification_for(calib_classes, test_classes, config);

    run_times{test_device_i} = toc;
end

save(fullfile(dir_results, ['LS_classification' filename_save]), 'calib_conf', 'calib_gamma', 'test_conf', 'win_gamma', 'timepoint', 'run_times', 'description', 'devices', 'participant_normalization', 'electrode_normalization', 'config');

for test_device_i=1:3
    plot_results([], ['LS_classification' filename_save], 'LS', test_device_i, filename, 1);
end

if notify
    % play success sound
    load handel.mat;
    sound(y,Fs);
end
