% finish preprocessing for multiple datasets (post-ICA part in
% preprocess.m)

% =========================================================================
% CONFIG
% -------------------------------------------------------------------------
participants = 1:15;  % max 1:15
systems = ['V'];      % max ['G', 'V', 'H']
filename_ica = '_preprocessed_ica.set';  % loaded from
filename = '_preprocessed_without_ica.mat';  % saved as
rest_wait = 8;  % time (s) to wait after rest-onset and before rest-offset for trial extraction
% =========================================================================

for sys=systems
    ntrials_rej = 0;
    ntrials_total = 0;
    for p=participants
        id = [sys num2str(p, '%02d')];

        EEG = pop_loadset('filename',[id filename_ica],'filepath','/home/michi/OneDrive/TU/Bac/matlab/eeglab_datasets/');
        load(['/home/michi/bac/data/' id '.mat'], 'header');
        [ntrials_rej_tmp, ntrials_total_tmp] = preprocess_finish(EEG, header, [id filename], rest_wait);
        ntrials_rej = ntrials_rej + ntrials_rej_tmp;
        ntrials_total = ntrials_total + ntrials_total_tmp;
    end
    fprintf(['Rejected in system "' sys '": '...
        num2str(ntrials_rej) '/' num2str(ntrials_total)...
        ' (' num2str(100*ntrials_rej/ntrials_total, '%.2f') '%%)'...
        '\n']);
end
