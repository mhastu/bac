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

    P = size(classes,1);  % number of participants
    C = size(classes,2);  % number of classes
    S = size(classes,3);  % number of systems

    gfp = NaN(P, S);
    for p=1:P
        for s=1:S
            gfp(p,s) = mean(GFP(classes{p, class_i, s}), 'all');
        end
    end
    gfp = gfp / mean(gfp,'all');  % keep grand average GFP the same

    for p=1:P
        for c=1:C
            for s=1:S
                classes{p,c,s} = classes{p,c,s} / gfp(p,s);
            end
        end
    end
end
