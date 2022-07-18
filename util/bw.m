function filtered = bw(signal, sample_rate, Wn, ftype)
% BW 4th order zero-phase butterworth filtering.

    if nargin < 4
        if max(size(Wn)) < 2
            ftype = 'low';
        else
            ftype = 'bandpass';
        end
    end

    [n_channels, ~] = size(signal);
    filtered = signal;

    order = 4;
    [b, a] = butter(order, Wn ./ (sample_rate / 2), ftype);

    for channel_index = 1:n_channels
        filtered(channel_index, :) = filtfilt(b, a, signal(channel_index, :));
    end
end
