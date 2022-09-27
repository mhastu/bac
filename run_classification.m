% runs the classification as in [Müller-Putz et al., 2020]
% workspace then contains the confusion matrices and accuracies per timepoint
%
% steps:
% 1. configure
% 2. run

% imports
addpath classification_reproduction
addpath plot
addpath datafunc

warning("off","parallel:gpu:device:DeviceDeprecated");

load('config.mat', 'dir_training_datasets');
load('config.mat', 'dir_results');

% =========================================================================
% CONFIG
% -------------------------------------------------------------------------
filename = '_preprocessed.mat';
filename_save = '_V_randcalib.mat';
randcalib = true;  % if calibration data should be randomly selected among trials
device_indices = 2;  % device type indices to use
notify = true;  % play sound when finished
participant_indices = 1:15;

calibration_cut = 0.66;
% =========================================================================

description = "3-by-15 cells: 3 systems, 15 participants (trained on 66% of each participant)";
calib_conf = cell(3, 15);
calib_gamma = cell(3, 15);
test_conf = cell(3, 15);
test_gamma = cell(3, 15);
timepoint = cell(3, 15);
devices = {'G', 'V', 'H'};

run_times = zeros(1,5);
for device_i=device_indices
    for p=participant_indices
        tic;
        fprintf('Running classification for participant %d.\n', p);
        classes = load_classes(filename, devices{device_i}, p);

        calib_classes = cell(1, 3);
        test_classes = cell(1, 3);
        for c=1:3
            if randcalib
                indices = randperm(size(classes{c}, 3));
            else
                indices = 1:size(classes{c},3);
            end
            % number of calibration trials in this class
            n = round(size(classes{c}, 3) * calibration_cut);
            calib_classes{c} = classes{c}(:,:,indices(1:n));
            test_classes{c} = classes{c}(:,:,indices(n+1:end));
        end

        [test_conf{device_i, p}, timepoint{device_i, p}, calib_conf{device_i, p}, ...
        calib_gamma{device_i, p}, test_gamma{device_i, p}] = ...
            run_classification_for(calib_classes, test_classes);

        run_times(p) = toc;
    end
end

save(fullfile(dir_results, ['classification' filename_save]), 'calib_conf', 'calib_gamma', 'test_conf', 'test_gamma', 'timepoint', 'run_times', 'description', 'devices');
plot_results([], ['classification' filename_save], 'rep', device_indices, filename, calibration_cut);

if notify
    % play success sound
    load handel.mat;
    sound(y,Fs);
end
