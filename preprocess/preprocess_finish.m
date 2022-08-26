function [ntrials_rej, ntrials_total] = preprocess_finish(eeg, header, filename, rest_wait)
%PREPROCESS_FINISH Finishes the preprocessing (post-ICA).
%   steps:
%   - Butterworth (4.o.) 0.3-35 Hz
%   - reject trials by
%       1) amplitude > 125uV
%       2) abnormal joint probability (4*std)
%       3) abnormal kurtosis
%   - downsample to 16 Hz.
%   - Butterworth (4.o) Low-Pass 3 Hz
%   - apply CAR filter
%   - save as .mat file.

    % imports
    addpath datafunc
    addpath util

    load('config.mat', 'dir_training_datasets');
    load('config.mat', 'dir_eeglab_datasets');

    if nargin < 4
        rest_wait = 8;
    end

    % =====================================================================
    % zero-phase butterworth filtering between 0.3 and 35 Hz
    % ---------------------------------------------------------------------
    eeg.data = single(bw(double(eeg.data), eeg.srate, [0.3, 35]));
    eeg = eeg_checkset(eeg);
    % =====================================================================


    % =====================================================================
    % reject trials
    % ---------------------------------------------------------------------
    [rest,palmar,lateral,...
        rest_start,rest_len,...
        palm_start,palm_len,...
        lat_start,lat_len,...
        palm_latencies, lat_latencies] = extract_trials(eeg, header, rest_wait);
    ntotal_rest = length(rest_start);
    ntotal_palm = length(palm_start);
    ntotal_lat = length(lat_start);
    ntrials_total = ntotal_rest + ntotal_palm + ntotal_lat;

    % ampval > 125uV (threshold)
    rej_threshold_rest = any(rest    > 125, [1 2]);
    rej_threshold_palm = any(palmar  > 125, [1 2]);
    rej_threshold_lat  = any(lateral > 125, [1 2]);
    % convert to row vectors
    rej_threshold_rest = rej_threshold_rest(:).';
    rej_threshold_palm = rej_threshold_palm(:).';
    rej_threshold_lat  = rej_threshold_lat(:).';

    % joint probability > 4*std
    [~, rej_jp_rest] = jointprob(rest,    4, [], 1);
    [~, rej_jp_palm] = jointprob(palmar,  4, [], 1);
    [~, rej_jp_lat]  = jointprob(lateral, 4, [], 1);
    % reject trial if any of the channels is rejected
    rej_jp_rest = any(rej_jp_rest, 1);
    rej_jp_palm = any(rej_jp_palm, 1);
    rej_jp_lat = any(rej_jp_lat, 1);

    % kurtosis > 4*std
    [~, rej_kurt_rest] = rejkurt(rest,    4, [], 1);
    [~, rej_kurt_palm] = rejkurt(palmar,  4, [], 1);
    [~, rej_kurt_lat]  = rejkurt(lateral, 4, [], 1);
    % reject trial if any of the channels is rejected
    rej_kurt_rest = any(rej_kurt_rest, 1);
    rej_kurt_palm = any(rej_kurt_palm, 1);
    rej_kurt_lat = any(rej_kurt_lat, 1);

    rej_rest = rej_threshold_rest | rej_jp_rest | rej_kurt_rest;
    rej_palm = rej_threshold_palm | rej_jp_palm | rej_kurt_palm;
    rej_lat  = rej_threshold_lat  | rej_jp_lat  | rej_kurt_lat;
    rest_start = rest_start(~rej_rest);
    palm_start = palm_start(~rej_palm);
    lat_start  =  lat_start(~rej_lat);

    nrej_rest = sum(rej_rest);
    nrej_palm = sum(rej_palm);
    nrej_lat  = sum(rej_lat);
    ntrials_rej = nrej_rest + nrej_palm + nrej_lat;
    fprintf(['rejected trials: ' num2str(ntrials_rej) '/' num2str(ntrials_total)...
        ' (' num2str(nrej_rest) '/' num2str(ntotal_rest) ' rest, '...
        num2str(nrej_palm) '/' num2str(ntotal_palm) ' palm, '...
        num2str(nrej_lat) '/' num2str(ntotal_lat) ' lat)'...
        '\n']);

    % remove rejected events from eeglab dataset
    PMon_code = header.event_codes(strcmp(header.event_names, 'palmar grasp, movement onset'));
    LMon_code = header.event_codes(strcmp(header.event_names, 'lateral grasp, movement onset'));
    rej_indices = find(((any([eeg.event.latency] == palm_latencies(rej_palm).', 1)) & ([eeg.event.code] == PMon_code)) | ...
        ((any([eeg.event.latency] == lat_latencies(rej_lat).', 1)) & ([eeg.event.code] == LMon_code)));  % indices of rejected EEG.events
    eeg = pop_editeventvals(eeg,'delete',rej_indices);
    % =====================================================================

    % =====================================================================
    % resample
    % ---------------------------------------------------------------------
    % Tools->Change sampling rate
    fs_pre = eeg.srate;
    fs_post = 16;
    fs_ratio = (fs_pre / fs_post);
    eeg = pop_resample( eeg, fs_post);
    eeg = eeg_checkset( eeg );

    rest_start = int32(rest_start / fs_ratio);
    palm_start = int32(palm_start / fs_ratio);
    lat_start  = int32(lat_start  / fs_ratio);
    rest_len = int32(ceil(double(rest_len) / fs_ratio));
    palm_len = int32(ceil(double(palm_len) / fs_ratio));
    lat_len  = int32(ceil(double(lat_len)  / fs_ratio));
    % =====================================================================

    % =====================================================================
    % Tools -> Re-Reference the data (pop_reref()): common average reference
    % ---------------------------------------------------------------------
    eeg = pop_reref( eeg, []);
    eeg = eeg_checkset( eeg );
    % =====================================================================

    % =====================================================================
    % zero-phase butterworth low-pass filtering (3 Hz)
    % ---------------------------------------------------------------------
    eeg.data = single(bw(double(eeg.data), eeg.srate, 3, 'low'));
    eeg = eeg_checkset(eeg);
    % =====================================================================

    % =====================================================================
    % save dataset for training
    % ---------------------------------------------------------------------
    train_channels = header.channels_eeg;
    if strcmp(header.device_type, 'hero')
        % remove channel 'A2' (left out in [Müller-Putz et al., 2020])
        train_channels = header.channels_eeg(~strcmp(header.channels_labels(header.channels_eeg), 'A2'));
    end
    rest = get_trials_from_frames(eeg.data(train_channels, :), rest_start, rest_len);
    palmar = get_trials_from_frames(eeg.data(train_channels, :), palm_start, palm_len);
    lateral = get_trials_from_frames(eeg.data(train_channels, :), lat_start, lat_len);
    save(fullfile(dir_training_datasets, filename), ...
        'rest', 'palmar', 'lateral', 'rest_start', 'rest_len', 'palm_start', 'palm_len', 'lat_start', 'lat_len', 'train_channels');
    fprintf(['File ' filename ' saved in ' dir_training_datasets '\n']);

    % also save EEGLAB dataset
    pop_saveset(eeg, ...
        'filename', [filename '.set'], ...
        'filepath', dir_eeglab_datasets);
    fprintf(['File ' filename '.set saved in ' dir_eeglab_datasets '\n']);
    % =====================================================================
end

