function [fig] = event_preview(data)
    events = data.events;
    signal = data.signal;
    header = data.header;
    channel = cellfun(@(x) strcmp(strtrim(x), 'C1'), header.channels_labels);
    sig = signal(channel,:);  % C1

    [~, cols] = size(signal);
    t = (1:cols) ./ header.sample_rate ./ 60;  % in minutes

    fig = figure;
    plot(t,sig);
    hold on;

    visual_events_i = (10 <= events.codes & events.codes <= 15);
    visual_events = events.positions(visual_events_i);
    num_visual_events = max(size(visual_events));  % can be cell- or row-array
    stem(visual_events ./header.sample_rate ./ 60, 1000*ones(1, num_visual_events), 'Color', 'Blue');

    resting_events_i = (events.codes == 768 | events.codes == 769);
    resting_events = events.positions(resting_events_i);
    num_resting_events = max(size(resting_events));  % can be cell- or row-array
    stem(resting_events ./header.sample_rate ./ 60, 1000*ones(1, num_resting_events), 'Color', 'Red');

    grasp_events_i = events.codes > 50000;
    grasp_events = events.positions(grasp_events_i);
    num_grasp_events = max(size(grasp_events));  % can be cell- or row-array
    stem(grasp_events ./header.sample_rate ./ 60, 1000*ones(1, num_grasp_events), 'Color', 'Green');

    legend('C1', 'visual events', 'resting events', 'grasp events');
    hold off;
end

