% imports
addpath datafunc

R = 12;
frame = [-3 3];
eeg = struct('event', struct());
eeg.srate = 16;
start = frame(1)*eeg.srate;
eeg.event.latency = (1:5:21) - start;
eeg.event.code = [1 2 1 2 1];
eeg.data = rand(R, 200, 'single');
header = struct();
header.channels_eeg = 1:10;
header.event_codes = [1 2];
header.event_names = {'palmar grasp, movement onset', 'lateral grasp, movement onset'};
types = {'palmar', 'lateral'};


ok_data = cell(1, 2);
ok_len = false(1, 2);
ok_latency = false(1, 2);
for type_i=1:2
    latencies = eeg.event.latency(eeg.event.code == header.event_codes(type_i)) + start;
    N = length(latencies);

    ok_data_ = false(1, N);

    type = types{type_i};
    [trials, latencies_, len] = extract_movement_trials(eeg, header, type, frame);

    ok_latency(type_i) = all(latencies_ == latencies);
    ok_len(type_i) = (len == (frame(2) - frame(1))*eeg.srate) + 1;

    for i=1:N
        ok_data_(i) = all(trials(:,:,i) == eeg.data(header.channels_eeg,latencies(i):latencies(i)+len-1), 'all');
    end

    ok_data{type_i} = ok_data_;
end

fprintf(['extract_movement_trials: ' ...
    'len: ' get_ok_str(all(ok_len)) ...
    ', latency: ' get_ok_str(all(ok_latency)) ...
    ', data: ' get_ok_str(all(ok_data{1}, 'all') & all(ok_data{2}, 'all')) '\n']);
