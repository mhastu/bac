function [scovmat, gamma] = scov(data, dmean)
%SCOV shrunk covariance matrix with target "diagonal, common variance".
%   scovmat = SCOV(data, dmean) returns the shrunk covariance matrix.
%       data: N-by-D matrix
%           N...number of trainals
%           D...number of features
%       dmean: (optional) 1-by-D matrix specifying the sample mean.
%
%   [scovmat, gamma] = SCOV(data) also returns the shrinkage parameter.
%
%   Shrinkage estimation is based on Blankertz et al., 2011

    D = size(data, 2);   % number of features
    N = size(data, 1);   % number of trainals

    if nargin < 2
        dmean = sum(data, 1) / N;
    end

    meaned = data - dmean;  % remove mean from data
    clearvars dmean;
    meaned2 = gpuArray(permute(meaned, [3 2 1]));
    clearvars meaned;
    Z = pagemtimes(meaned2, 'transpose', meaned2, 'none');
    clearvars meaned2;

    % =====================================================================
    % equation 13 in blankertz_2011
    nom_gpu = sum((Z - sum(Z,3)./N).^2,'all');
    clearvars Z;
    nom = gather(nom_gpu);
    clearvars nom_gpu;

    covmat = cov(data);  % normal covariance matrix (sigma hat)
    diagmean = (trace(covmat) / D) * eye(D);
    denom = sum((covmat - diagmean).^2, 'all');
    % var in nom should be normalized by N-1 (as in blankertz) --> (N-1)^3
    gamma = N/((N-1)^3) * nom / denom;
    gamma = max(0,min(1,gamma));  % ensure 0 <= gamma <= 1 (2.3 in shrinkage_strimmer)
    % =====================================================================

    % equation 12 in blankertz_2011
    scovmat = (1-gamma)*covmat + gamma*diagmean;  % Sigma tilde
end
