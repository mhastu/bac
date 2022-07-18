function [trials, latencies, len] = extract_rest_trials(eeg, header, frame, space_s)
%EXTRACT_REST_TRIALS Extract rest trials.
%
%   trials = EXTRACT_REST_TRIALS(eeg, header, frame, space_s) returns the
%       trials as a R x L x N matrix.
%           R...number of channels
%           L...number of ampvals per trial
%           N...number of trials
%       eeg: EEGLAB data structure
%       header: loaded from dataset
%       frame: time frame to extract: [begin end]
%       space_s: time to omit after rest onset and before rest offset in s

    fs = eeg.srate;

    onset_code = header.event_codes(strcmp(header.event_names, 'resting onset'));
    offset_code = header.event_codes(strcmp(header.event_names, 'resting offset'));

    % convert start times of all events to array (for indexing)
    event_latencies = [eeg.event.latency];
    on_lat = int32(event_latencies([eeg.event.code] == onset_code));
    on_lat = on_lat + space_s*fs;
    off_lat = int32(event_latencies([eeg.event.code] == offset_code));
    off_lat = off_lat - space_s*fs;

    if length(on_lat) ~= length(off_lat)
        error('indices do not match');
    end

    len = int32((frame(2)-frame(1))*fs + 1);

    num_trials = max(0, floor(double(off_lat - on_lat) / double(len)));
    latencies = zeros(1, sum(num_trials, 'all'));
    idx = 1;
    for i=1:length(on_lat)
        for k=1:num_trials(i)
            lat = int32((k-1)*len);
            latencies(idx) = on_lat(i) + lat;
            idx = idx + 1;
        end
    end
    train_channels = header.channels_eeg;
    if strcmp(header.device_type, 'hero')
        % remove channel 'A2'
        train_channels = header.channels_eeg(~strcmp(header.channels_labels(header.channels_eeg), 'A2'));
    end
    trials = get_trials_from_frames(eeg.data(train_channels,:),latencies,len);
end
