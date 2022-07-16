function [] = extract_and_save_trials(eeg, header, filename)
%EXTRACT_AND_SAVE_TRIALS Extracts and saves the trials from the eeg data.

    [rest, palmar, lateral, rest_lat, rest_len, palm_lat, palm_len, lat_lat, lat_len] = extract_trials(eeg, header);
    save(filename, 'rest', 'palmar', 'lateral', 'rest_lat', 'rest_len', 'palm_lat', 'palm_len', 'lat_lat', 'lat_len');
end
