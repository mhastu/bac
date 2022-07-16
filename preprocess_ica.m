function [] = preprocess_ica(p, sys, filename, rm12, run_ica)
%PREPROCESS_ICA Preprocessing until (incl.) the ICA step.
%   After that, components must be manually removed (can't run in a
%   function).
%   The loaded dataset is not added to the EEGLAB GUI! If you want to add
%   it, issue:
%   [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, max(size(ALLEEG)),'gui','off');
%   Open preferences and 'cancel' to reload GUI.
%
%   PREPROCESS_ICA(p, sys) preprocesses the dataset of the given
%       participant p (1:15) and and system type sys ('G', 'V', 'H') and
%       saves the dataset, which can then be used for removing ICA
%       components and finishing the preprocessing.

    if nargin < 5
        run_ica = true;
    end
    if nargin < 4
        rm12 = true;
    end

    id = [sys num2str(p, '%02d')];

    if ~exist('pop_importdata', 'file') || ...
            ~exist('eeg_checkset', 'file') || ...
            ~exist('pop_chanedit', 'file') || ...
            ~exist('pop_importevent', 'file') || ...
            ~exist('pop_resample', 'file') || ...
            ~exist('pop_runica', 'file') || ...
            ~exist('pop_saveset', 'file')
        error('missing EEGLAB functions');
    end

    % =====================================================================
    % load data
    % ---------------------------------------------------------------------
    load(['/home/michi/bac/data/' id '.mat'], 'signal', 'header', 'events');
    % =====================================================================

    channels = [header.channels_eeg header.channels_eog];
    if strcmp(header.device_type, 'hero') && rm12
        % remove channel 'A2' (left out in datensatz_studie)
        % achieved best results when removing this channel
        channels = header.channels_eeg(~strcmp(header.channels_labels(header.channels_eeg), 'A2'));
        signal = signal(channels,:);
    end

    % =====================================================================
    % import EEG data from signal
    % ---------------------------------------------------------------------
    % File->import data->using EEGLAB functions and plugins->From ASCII/Float
    % file or matlab variable
    % array: signal
    % Dataset name: <id>
    % Data sampling rate: <header.sample_rate>
    EEG = pop_importdata('dataformat','array','nbchan',0,'data',signal,'setname',id,'srate',header.sample_rate,'pnts',0,'xmin',0);
    EEG = eeg_checkset( EEG );
    % =====================================================================

    % =====================================================================
    % import channel locations from header
    % ---------------------------------------------------------------------
    LC = length(channels);
    instruction_list = cell(1, 4*LC+1);
    instruction_list{1} = EEG;
    for c_i=1:LC
        instruction_list{(c_i-1)*4+2} = 'append';
        instruction_list{(c_i-1)*4+3} = channels(c_i);
        instruction_list{(c_i-1)*4+4} = 'changefield';
        instruction_list{(c_i-1)*4+5} = {channels(c_i), 'labels',...
            convert_channel_label(header.channels_labels{channels(c_i)}),'datachan',1};
    end
    EEG = pop_chanedit(instruction_list{:});
    EEG = pop_chanedit(EEG, 'lookup', ...
        '/home/michi/OneDrive/TU/Bac/matlab/eeglab2021.1/plugins/dipfit/standard_BEM/elec/standard_1005.elc');
    % =====================================================================

    % =====================================================================
    % import events
    % ---------------------------------------------------------------------
    eeglab_events = cell(max(size(events.codes)), 3);
    for i=1:max(size(events.codes))
        code = events.codes(i);
        eeglab_events(i, :) = {
            events.positions(i),...
            convert_event_name( ...
                char(header.event_names(header.event_codes == code))),...
            code
        };
    end
    % File->Import event info->From matlab array:
    % - array=eeglab_events
    % - field names=latency type code
    % - time unit=NaN
    % - OK
     EEG = pop_importevent( EEG, 'event',   eeglab_events, ...
                                 'fields',  {'latency','type','code'}, ...
                                 'timeunit', NaN);
     EEG = eeg_checkset( EEG );
    % =====================================================================
    
    % =====================================================================
    % zero-phase butterworth filtering between 0.3 and 60 Hz
    % ---------------------------------------------------------------------
    EEG.data = single(bw(double(EEG.data), EEG.srate, [0.3, 60]));
    EEG = eeg_checkset(EEG);
    % =====================================================================

    if any(['G', 'V'] == sys) && run_ica
        % =================================================================
        % ICA (only for G and V)
        % -----------------------------------------------------------------
        % in EEGLAB Tools->ICA
        % select binica (C compiled version)
        % options: 'extended', 1
        EEG = pop_runica(EEG, 'icatype', 'binica', 'extended',1);
        EEG = eeg_checkset( EEG );
        % =================================================================
    end
    % =================================================================
    % save dataset
    % -----------------------------------------------------------------
    pop_saveset(EEG, ...
        'filename', [id filename], ...
        'filepath', '/home/michi/OneDrive/TU/Bac/matlab/eeglab_datasets/');
    fprintf(['File ' id filename ' saved in eeglab_datasets\n']);
    % =================================================================
end

