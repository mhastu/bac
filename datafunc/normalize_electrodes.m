function [classes] = normalize_electrodes(classes, class_i)
%NORMALIZE_PARTICIPANTS Normalize electrode data by average power (square).
%
%   classes_normalized = normalize_electrodes(classes, class_i) returns
%       for each electrode the trials normalized by mean power of given
%       class index (class_i).
%       classes: P-by-C cell array
%           P...number of participants
%           C...number of classes
%       classes_normalized: P-by-C cell array
%
%   Grand average power should stay the same (minimizes floating point
%   errors).

    P = size(classes,1);  % number of participants
    S = size(classes,3);  % number of systems
    C = size(classes,2);  % number of classes

    for p=1:P
        for s=1:S
            l2norm = sqrt(sum(classes{p, class_i, s}.^2, [2 3]));  % column vector
            l2norm = l2norm / mean(l2norm);  % keep average power the same

            for c=1:C
                classes{p,c,s} = classes{p,c,s} ./ l2norm;
            end
        end
    end
end
