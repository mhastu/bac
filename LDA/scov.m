function [scovmat, gamma] = scov(data, dmean, gamma, gpu)
%SCOV shrunk covariance matrix with target "diagonal, common variance".
%   scovmat = SCOV(data, dmean, gpu) returns the shrunk covariance matrix.
%       data: N-by-D matrix
%           N...number of trainals
%           D...number of features
%       dmean: (optional) 1-by-D matrix specifying the sample mean.
%       gpu: (optional) logical, whether to calculate on GPU (faster)
%           (default: true)
%
%   [scovmat, gamma] = SCOV(data) also returns the shrinkage parameter.
%
%   Shrinkage estimation is based on [Blankertz et al., 2011]
%
%   References:
%   [Blankertz et al., 2011] Blankertz, B., Lemm, S., Treder, M., Haufe, S., and Müller, K.-R. (2011). "Single-trial analysis and classification of ERP components—a tutorial. NeuroImage 56, 814–825." doi: 10.1016/j.neuroimage.2010.06.048
%   [Schäfer et al., 2005] Schäfer, Juliane and Strimmer, Korbinian. "A Shrinkage Approach to Large-Scale Covariance Matrix Estimation and Implications for Functional Genomics" Statistical Applications in Genetics and Molecular Biology, vol. 4, no. 1, 2005. https://doi.org/10.2202/1544-6115.1175

    if nargin < 3
        gamma = -1;  % default: calculate gamma
    end
    if nargin < 4
        gpu = true;
    end

    if gpu
        covmat = gather(cov(gpuArray(data)));  % normal covariance matrix (sigma hat)
    else
        covmat = cov(data);  % normal covariance matrix (sigma hat)
    end
    if gamma == 0
        scovmat = covmat;
        return;
    end

    D = size(data, 2);   % number of features
    diagmean = (trace(covmat) / D) * eye(D);

    if gamma < 0 % calculate gamma
        N = size(data, 1);   % number of trainals
    
        if nargin < 2
            dmean = sum(data, 1) / N;
        end
    
        meaned = data - dmean;  % remove mean from data
        clearvars dmean;
        meaned2 = permute(meaned, [3 2 1]);
        if gpu; meaned2 = gpuArray(meaned2); end
        clearvars meaned;
        Z = pagemtimes(meaned2, 'transpose', meaned2, 'none');
        clearvars meaned2;
    
        % =====================================================================
        % equation 13 in [Blankertz et al., 2011]
        nom_gpu = sum((Z - sum(Z,3)./N).^2,'all');
        clearvars Z;
        if gpu
            nom = gather(nom_gpu);
        else
            nom = nom_gpu;
        end
        clearvars nom_gpu;

        denom = sum((covmat - diagmean).^2, 'all');
        % var in nom should be normalized by N-1 as in [Blankertz et al., 2011]
        % --> (N-1)^3
        gamma = N/((N-1)^3) * nom / denom;
        % ensure 0 <= gamma <= 1 (2.3 in [Schäfer et al., 2005])
        gamma = max(0,min(1,gamma));
        % =====================================================================
    end

    % equation 12 in [Blankertz et al., 2011]
    scovmat = (1-gamma)*covmat + gamma*diagmean;  % Sigma tilde
end
