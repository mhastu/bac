function [trials, framestarts, len, event_latencies] = extract_movement_trials(eeg, header, type, frame, dtype)
%EXTRACT_MOVEMENT_TRIALS Extract trials of movement events.
%
%   trials = EXTRACT_MOVEMENT_TRIALS(eeg, header, type, frame) returns
%       the trials as a R x L x N matrix.
%           R...number of channels
%           L...number of ampvals per trial
%           N...number of trials
%       eeg: EEGLAB data structure
%       header:
%       type: 'palmar' or 'lateral'
%       frame: time frame to extract: [begin end]

    if nargin < 5
        dtype = 'single';
    end

    fs = eeg.srate;
    start = int32(frame(1)*fs);  % start (ampval index) w.r.t. the event
    len = int32((frame(2) - frame(1))*fs + 1);
    
    if strcmp(type, 'palmar')
        code = header.event_codes(strcmp(header.event_names, 'palmar grasp, movement onset'));
    elseif strcmp(type, 'lateral')
        code = header.event_codes(strcmp(header.event_names, 'lateral grasp, movement onset'));
    else
        error('type must be palmar or lateral');
    end
    % convert start times of all events to array (for indexing)
    event_latencies = [eeg.event.latency];
    % latencies are stored as indices in EEG, but as doubles (to remain
    % accurate after downsampling)
    event_latencies = int32(event_latencies([eeg.event.code] == code));
    framestarts = event_latencies + start;
    
    % filter invalid latencies
    too_early = framestarts < 1;
    too_late = (framestarts + len - 1 > size(eeg.data, 2));
    num_too_early = sum(too_early);
    num_too_late = sum(too_late);
    if num_too_early > 0
        warning(['filtered out ' num2str(num_too_early) ' events, because they start too early for the given time frame.']);
    end
    if num_too_late > 0
        warning(['filtered out ' num2str(num_too_late) ' events, because they start too late for the given time frame.']);
    end

    framestarts = framestarts(~too_early & ~too_late);
    event_latencies = event_latencies(~too_early & ~too_late);

    train_channels = header.channels_eeg;
    if strcmp(header.device_type, 'hero')
        % remove channel 'A2'
        train_channels = header.channels_eeg(~strcmp(header.channels_labels(header.channels_eeg), 'A2'));
    end
    trials = get_trials_from_frames(eeg.data(train_channels, :), framestarts, len, dtype);
end
