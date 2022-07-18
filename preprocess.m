% preprocessing described in [Müller-Putz et al., 2020]
% to use gui, issue:
% [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, max(size(ALLEEG)),'gui','off');
% Open preferences and 'cancel' to reload GUI.
%
% steps:
% 1. configure (set participant index, etc.) and run first section
% 2. make sure preprocess_ica(p, sys) is run (preprocessed eeglab set file
%    must exist!). If not, run second section (preprocessing) or run
%    preprocess_ica_par.m
% 3. (only if GEL or VERSATILE) run third section (remove artifacts) and
%    remove eye components by visual inspection
% 4. (only if GEL or VERSATILE) run fourth section (check)
% 4. (only if GEL or VERSATILE) run fifth section (post-ICA)

% imports
addpath preprocess

%% config
% =========================================================================
% CONFIG
% -------------------------------------------------------------------------
participant_index = 15;  % between 1 and 15
eeg_system = 'H';       % 'G', 'V' or 'H'
filename_ica = '_preprocessed_ica.set';  % eeglab dataset name for caching the data before manually removing ICA components
filename = '_preprocessed.mat';  % training dataset name (saved as)
% =========================================================================

id = [eeg_system num2str(participant_index, '%02d')];
load('config.mat', 'dir_eeglab');
if ~exist('pop_importdata', 'file') || ...
            ~exist('eeg_checkset', 'file') || ...
            ~exist('pop_chanedit', 'file') || ...
            ~exist('pop_importevent', 'file') || ...
            ~exist('pop_resample', 'file') || ...
            ~exist('pop_runica', 'file') || ...
            ~exist('pop_saveset', 'file') % check for eeglab functions
    if exist(dir_eeglab, 'dir')
        addpath(dir_eeglab)
    end
    if ~exist('eeglab', 'file')
        error('eeglab not found');
    end
    
    eeglab;  % start eeglab (no EEG variables needed for script)
end  % assuming eeglab has been started

%% preprocessing (run ICA)
preprocess_ica(participant_index, eeg_system, filename_ica);

%% remove artifacts by removing ICA components
% File -> Load existing Dataset
load('config.mat', 'dir_eeglab_datasets');
EEG = pop_loadset('filename',[id filename_ica],'filepath',dir_eeglab_datasets);

latencies = [EEG.event.latency];
fprintf(['Eye blinking: ' num2str(latencies(strcmp({EEG.event.type}, 'EBon'))/EEG.srate) ' seconds\n']);
fprintf(['Vertical eye: ' num2str(latencies(strcmp({EEG.event.type}, 'VEon'))/EEG.srate) ' seconds\n']);
fprintf(['Horizon. eye: ' num2str(latencies(strcmp({EEG.event.type}, 'HEon'))/EEG.srate) ' seconds\n']);

% Plot -> Component activations
pop_eegplot( EEG, 0, 1, 1);
% Plot -> Channel Data (Scroll)
pop_eegplot( EEG, 1, 1, 1);
% now find components which correspond to EOG channels (1)

% Tools -> Reject data using ICA -> reject components by map:
% find components which correspond to forehead/eyes (2)
% (component power spectrum is left out due to low frequency range
% (0.3-3Hz)
pop_selectcomps(EEG, EEG.icachansind);

% write down components matching criteria (1) and (2)

% Tools -> Remove components from data: enter written down components
EEG = pop_subcomp(EEG);

%% check
% check if eye artifacts are removed
pop_eegplot( EEG, 1, 1, 1);

%% post-ICA
load('config.mat', 'dir_eeg_data');
load(fullfile(dir_eeg_data, [id '.mat']), 'header');

load('config.mat', 'dir_training_datasets');
preprocess_finish(EEG, header, fullfile(dir_training_datasets, [id filename]));
