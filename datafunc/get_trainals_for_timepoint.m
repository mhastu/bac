function [trainals] = get_trainals_for_timepoint(trials, t_indices, t, config)
%GET_TRAINALS_FOR_TIMEPOINT Get training data for given timepoint.
%
%   trainals = GET_TRAINALS_FOR_TIMEPOINT(trials, t_indices, t) returns the
%       data used for training or classification (N-by-T*R matrix).
%           T...number of ampvals to use = length(t_indices)
%       trials: R x L x N matrix
%           R...number of channels
%           L...number of ampvals per trial
%           N...number of trials
%       t_indices: zero-based indices to use w.r.t. the timepoint
%       t: timepoint (count-based ampval index)

    if nargin < 4
        config = struct();
    end
    if ~isfield(config, 'dtype')
        config.dtype = 'single';
    end

    n_channels = size(trials,1); % R
    n_trials = size(trials, 3);  % N

    trainals = zeros(n_trials, length(t_indices)*n_channels, config.dtype);
    for i=1:n_trials
        % store all EEG channels of this event reshaped to one array
        indices = t_indices + t;
        trainals(i,:) = reshape(trials(:, indices, i).', 1, []);
    end
end
