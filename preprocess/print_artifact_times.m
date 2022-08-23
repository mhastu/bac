% assuming global EEG variable is present, print the event times of eye
% artifacts.

latencies = [EEG.event.latency];
fprintf(['Eye blinking: ' num2str(latencies(strcmp({EEG.event.type}, 'EBon'))/EEG.srate) ' seconds\n']);
fprintf(['Vertical eye: ' num2str(latencies(strcmp({EEG.event.type}, 'VEon'))/EEG.srate) ' seconds\n']);
fprintf(['Horizon. eye: ' num2str(latencies(strcmp({EEG.event.type}, 'HEon'))/EEG.srate) ' seconds\n']);