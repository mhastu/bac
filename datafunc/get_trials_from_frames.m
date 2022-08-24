function [trials] = get_trials_from_frames(signal, latencies, len, dtype)
%GET_TRIALS_FROM_FRAMES Get signal data from given frame.
%
%   [trials] = GET_TRIALS_FROM_FRAMES(signal, latencies, len) returns the
%       trials (R-by-len-by-N matrix).
%           R...number of channels
%           len...length of each trial (in ampvals)
%           N...number of trials
%       signal: the eeg signal (C-by-X matrix).
%       latencies: vector containing the begin index of each trial.
%       len: length of each trial (in ampvals)

    if nargin < 4
        dtype = 'single';
    end

    n_channels = size(signal, 1);
    n_trials = length(latencies);

    trials = zeros(n_channels, len, n_trials, dtype);
    for i=1:n_trials
        indices = latencies(i):latencies(i)+len-1;
        trials(:,:,i) = signal(:,indices);
    end
end
