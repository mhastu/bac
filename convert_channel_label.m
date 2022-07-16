function [converted_label] = convert_channel_label(label)
%CONVERT_CHANNEL_LABEL convert a channel label to standard MNI BEM
    label = strtrim(label);
    switch (label)
        case 'EOG-R-Top'
            converted_label = 'FP2';
        case 'EOG-R-Side'
            converted_label = 'AFp10h';
        case 'EOG-R-Bottom'
            converted_label = 'AFp9';
        case 'EOG-L-Top'
            converted_label = 'FP1';
        case 'EOG-L-Side'
            converted_label = 'AFp9h';
        case 'EOG-L-Bottom'
            converted_label = 'AFp10';
        otherwise
            converted_label = label;
    end
end
