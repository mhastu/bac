function [rest, palmar, lateral, ...
    rest_start, rest_len, ...
    palm_start, palm_len, ...
    lat_start, lat_len, ...
    palm_latency, lat_latency] = extract_trials(eeg, header, rest_wait, dtype)
%EXTRACT_TRIALS

    if nargin < 3
        rest_wait = 8;
    end
    if nargin < 4
        dtype = 'single';
    end

    % config
    WOI = [-2 3];        % window of interest in seconds (open on left side)
    feature_length = 9;  % number of ampvals before the point of interest
    feature_gap = 2;     % #ampvals between two features
    fs = 16; % fixed sampling rate of 16 Hz, because extracted trials are
    % used for classification, and the sampling rate there is always 16Hz.
    % do not use eeg.srate, because for rejection, trials must be extracted
    % at a previous step with higher sampling rate, but the time window
    % must match the trials used for classification.

    % trial_frame(1) must be less than WOI(1), because we need trial data
    % from the preceding second of each timepoint in WOI.
    trial_frame = [WOI(1)-(feature_gap*(feature_length-1)-1)/fs, WOI(2)];

    [rest, rest_start, rest_len] = extract_rest_trials(eeg, header, trial_frame, rest_wait, dtype);
    [palmar, palm_start, palm_len, palm_latency] = extract_movement_trials(eeg, header, 'palmar', trial_frame, dtype);
    [lateral, lat_start, lat_len, lat_latency] = extract_movement_trials(eeg, header, 'lateral', trial_frame, dtype);
end
