% imports
addpath datafunc

R = 12;
frame = [-3 3];
eeg = struct('event', struct());
eeg.srate = 16;
eeg.event.latency = [5 200 301 480];
eeg.event.code = [1 2 1 2];
eeg.data = rand(R, 500, 'single');
header = struct();
header.channels_eeg = 1:10;
header.event_codes = [1 2];
header.event_names = {'resting onset', 'resting offset'};
space_s = 1;

[trials, latencies, len] = extract_rest_trials(eeg, header, frame, space_s);
N = length(latencies);  % latencies are not checked here

ok_len = (len == (frame(2) - frame(1))*eeg.srate) + 1;

ok_data = zeros(1,N);
for i=1:N
    ok_data(i) = all(trials(:,:,i) == eeg.data(header.channels_eeg,latencies(i):latencies(i)+len-1), 'all');
end

fprintf(['test_extract_rest_trials: '...
    'len: ' get_ok_str(ok_len)...
    ', data: ' get_ok_str(all(ok_data))...
    '\n']);
