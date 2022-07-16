R = 12;
signal = rand(R, 100, 'single');
latencies = 1:5:21;
len = 10;

N = length(latencies);

% (R-by-len-by-N matrix)
trials = get_trials_from_frames(signal, latencies, len);

ok = false(1, N);
for i=1:N
    ok(i) = all(trials(:,:,i) == signal(:,latencies(i):latencies(i)+len-1), 'all');
end
fprintf(['get_trials_from_frames: ' get_ok_str(all(ok)) '\n']);
