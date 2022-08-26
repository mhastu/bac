function [classes] = load_classes(file_suffix, device, participant, channels_labels)
%LOAD_CLASSES Load Training data.
%   file_suffix: string to append to filename, e.g. '_preprocessed.mat'
%   device: one of {'G', 'V', 'H'}
%   participant: 1..15
%   channels_labels (optional): cell array of channel labels

    load('config.mat', 'dir_training_datasets', 'dir_eeg_data');

    id = [device num2str(participant, '%02d')];
    load(fullfile(dir_eeg_data, [id '.mat']), 'header');
    load(fullfile(dir_training_datasets, [id file_suffix]), ...
        'rest', 'palmar', 'lateral', 'train_channels');
    
    if nargin < 4
        classes = {rest, palmar, lateral};
    else
        % channel indices to use (in data file)
        channels = ismember(strtrim(header.channels_labels), strtrim(channels_labels));
        % channel indices to use (in training file)
        selected_train_channels = ismember(train_channels, header.channels_eeg(channels));
        classes = {rest(selected_train_channels,:,:), ...
                   palmar(selected_train_channels,:,:), ...
                   lateral(selected_train_channels,:,:)};
    end
end
