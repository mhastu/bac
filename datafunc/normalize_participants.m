function [classes] = normalize_participants(classes, class_i)
%NORMALIZE_PARTICIPANTS Normalize participant data by GFP.
%
%   classes_normalized = normalize_participants(classes, class_i) returns
%       for each participant the trials normalized by mean global field
%       power of given class index (class_i).
%       classes: P-by-C cell array
%           P...number of participants
%           C...number of classes
%       classes_normalized: P-by-C cell array
%
%   Grand average GFP should stay the same (minimizes floating point
%   errors).

    % imports
    addpath util

    gfp = NaN(15, 1);
    for p=1:size(classes,1)
        gfp(p) = mean(GFP(classes{p, class_i}), 'all');
    end
    gfp = gfp / mean(gfp);  % keep grand average GFP the same

    for p=1:size(classes,1)
        for c=1:size(classes,2)
            classes{p,c} = classes{p,c} / gfp(p);
        end
    end
end
