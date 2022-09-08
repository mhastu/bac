% runs the classification cross-system
% (all-systems) 14 participants of each system as training data, one
% participant of each system as test
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
config.n_workers = 4;  % number of workers for parallel computing (1 for single-trheaded)
config.dtype = 'single';  % datatype to use. usually 'single' is sufficient and faster
config.gpu = false;  % whether to use gpu

notify = false;  % play sound when finished
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

description = "calib: 1-by-15 (calibrated using all systems, for each leave-out participant index), test: 3-by-15 (tested on all 3 systems, for each calibration)";
calib_conf = cell(1, 15);
calib_gamma = cell(1, 15);
timepoint = cell(1, 15);
win_gamma = cell(1, 15);
run_times = cell(1, 15);
test_conf = cell(3, 15);

for p=1:15
    fprintf(['AS-classification: Test participant index: ' num2str(p) '\n']);
    tic;
    calib_p_indices = [1:p-1 p+1:3];

    % 14 participants of all systems
    calib_classes = {...
        cat(3, classes{calib_p_indices,1,:}),...
        cat(3, classes{calib_p_indices,2,:}),...
        cat(3, classes{calib_p_indices,3,:})};
    % 1 test participant of all systems
    test_classes = classes(p,:,:); % 1-by-3-by-3

    [test_conf(:, p), timepoint{p}, calib_conf{p}, calib_gamma{p}, win_gamma{p}] = ...
        run_AS_classification_for(calib_classes, test_classes, config);

    run_times{p} = toc;
end

save(fullfile(dir_results, ['AS_classification' filename_save]), 'calib_conf', 'calib_gamma', 'test_conf', 'win_gamma', 'timepoint', 'run_times', 'description', 'devices', 'config', 'electrode_normalization', 'participant_normalization');

plot_results_AS(['AS_classification' filename_save], filename);

if notify
    % play success sound
    load handel.mat;
    sound(y,Fs);
end
