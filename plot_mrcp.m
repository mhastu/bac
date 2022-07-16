%% config
fs = 16;      % sampling frequency in Hz
WOI_s = [-2 3];      % window of interest in seconds
feature_length = 9;  % number of ampvals before the point of interest
feature_gap = 2;     % #ampvals between two features
channel = 'Cz';
sys = 'H';
participants = 1:15;
filename = '_rm12_preprocessed.mat.set';

% feature indices w.r.t. the point of interest
feature_i = int32(-(feature_length-1)*feature_gap:feature_gap:0);
WOI = int32(WOI_s * fs);  % window of interest in ampvals
% indices of the window of interest w.r.t. the movement onset
% leave out last point in WOI
WOI_i = WOI(1):WOI(2)-1;

%% load
PMclass = [];
LMclass = [];
for p=participants
    id = [sys num2str(p, '%02d')];
    EEG = pop_loadset('filename',[id filename],'filepath','/home/michi/OneDrive/TU/Bac/matlab/eeglab_datasets/');

    urchans = {EEG.chanlocs.urchan};  % convert to cell array. this can't go in a single line, because matlab
    urchan = urchans{strcmp({EEG.chanlocs.labels}, channel)};

    % convert start times of all events to array (for indexing)
    event_latencies = [EEG.event.latency];
    PM_lat = event_latencies([EEG.event.code] == 503587);
    % latencies are stored as indices in EEG, but as doubles (to remain
    % accurate after downsampling)
    PM_i = int32(PM_lat);  % indices of palmar grasp - movement onsets
    LM_lat = event_latencies([EEG.event.code] == 503588);
    LM_i = int32(LM_lat);  % indices of lateral grasp - movement onsets
    
    PMclass_tmp = zeros(length(PM_i), length(WOI_i));
    for i=1:length(PM_i)
        % store all EEG channels of this event reshaped to one array
        PMclass_tmp(i,:) = EEG.data(urchan, WOI_i+PM_i(i));
    end
    PMclass = [PMclass; PMclass_tmp]; %#ok<AGROW> 
    LMclass_tmp = zeros(length(PM_i), length(WOI_i));
    for i=1:length(LM_i)
        % store all EEG channels of this event reshaped to one array
        LMclass_tmp(i,:) = EEG.data(urchan, WOI_i+LM_i(i));
    end
    LMclass = [LMclass; LMclass_tmp]; %#ok<AGROW> 
end

%% plot

if ~exist('fig_plot_events', 'var') || ~isvalid(fig_plot_events)
    fig_plot_events = figure();
else 
    fig_plot_events = figure(fig_plot_events);
end
fig_plot_events.Name = EEG.setname;
clf;
subplot(2, 1, 1);

x = double(WOI_i) / fs;

% plot each trial in gray
% for trial_i=1:size(PMclass, 1)
%     plot(x, PMclass(trial_i,:), '-', 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.7);
%     hold on;
% end

y = mean(PMclass, 1);
SEM = std(PMclass) / sqrt(size(PMclass, 1)); % Standard Error
ts = tinv(0.95, size(PMclass, 1) - 1);       % T-score
CI = ts*SEM;                                 % 95% confidence interval
curve1 = y + CI;
curve2 = y - CI;
x2 = [x, fliplr(x)];
inBetween = [curve1, fliplr(curve2)];
fill(x2, inBetween, 'g');
hold on;
plot(x, y, 'r', 'LineWidth', 2);
title(['PG: ' channel]);

subplot(2, 1, 2);
% plot each trial in gray
% for trial_i=1:size(LMclass, 1)
%     plot(x, LMclass(trial_i,:), '-', 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.7);
%     hold on;
% end
y = mean(LMclass, 1);
SEM = std(LMclass) / sqrt(size(LMclass, 1)); % Standard Error
ts = tinv(0.95, size(LMclass, 1) - 1);       % T-score
CI = ts*SEM;                                 % 95% confidence interval
curve1 = y + CI;
curve2 = y - CI;
x2 = [x, fliplr(x)];
inBetween = [curve1, fliplr(curve2)];
fill(x2, inBetween, 'g');
hold on;
plot(x, y, 'r', 'LineWidth', 2);
title(['LG: ' channel]);