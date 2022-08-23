% runs the classification as in [Müller-Putz et al., 2020]
% workspace then contains the confusion matrices and scores per timepoint
%
% steps:
% 1. configure
% 2. run

% imports
addpath classification_reproduction
addpath plot

warning("off","parallel:gpu:device:DeviceDeprecated");

load('config.mat', 'dir_training_datasets');
load('config.mat', 'dir_results');

% =========================================================================
% CONFIG
% -------------------------------------------------------------------------
filename = '_preprocessed.mat';
filename_save = '_V_randcalib.mat';
randcalib = true;  % if calibration data should be randomly selected among trials
types_i = 2;  % type indices to use
notify = true;  % play sound when finished
participant_indices = 1:15;

calibration_cut = 0.66;
% =========================================================================

calib_conf = cell(3, 15);
calib_gamma = cell(3, 15);
test_conf = cell(3, 15);
test_gamma = cell(3, 15);
timepoint = cell(3, 15);
types = {'G', 'V', 'H'};

run_times = zeros(1,5);
for type_i=types_i
    for p=participant_indices
        tic;
        fprintf('Running classification for participant %d.\n', p);

        id = [types{type_i} num2str(p, '%02d')];
        classes_ = load( ...
            fullfile(dir_training_datasets, [id filename]), ...
            'rest', 'palmar', 'lateral');
        classes = {classes_.rest,...
            classes_.palmar,...
            classes_.lateral};
        clearvars classes_;

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

        [test_conf{type_i, p}, timepoint{type_i, p}, calib_conf{type_i, p}, ...
        calib_gamma{type_i, p}, test_gamma{type_i, p}] = ...
            run_classification_for(calib_classes, test_classes);

        run_times(p) = toc;
    end
end

save(fullfile(dir_results, ['classification' filename_save]), 'calib_conf', 'calib_gamma', 'test_conf', 'test_gamma', 'timepoint', 'run_times');
plot_results([], ['classification' filename_save], 'rep', types_i, filename, calibration_cut);

if notify
    % play success sound
    load handel.mat;
    sound(y,Fs);
end
