% run preprocessing and ICA in parallel and save as dataset for each
% participant.

% imports
addpath preprocess

% =========================================================================
% CONFIG
% -------------------------------------------------------------------------
participants = 1:15;  % max 1:15
systems = ['V'];      % max ['G', 'V', 'H']
filename = '_preprocessed_ica.set';  % saved as
run_ica = true;
rm12 = true;  % if 'Hero', remove channel 'A2' (12) before preprocessing
notify = true;  % play sound when finished
% =========================================================================

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

parfor p=participants
    for sys=systems
        preprocess_ica(p, sys, filename, rm12, run_ica);
    end
end

if notify
    % play success sound
    load handel.mat;
    sound(y,Fs);
end
