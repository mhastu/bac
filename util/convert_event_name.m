function [converted_name] = convert_event_name(name)
%CONVERT_EVENT_NAME shorten event names
    keys = {'palmar grasp, movement onset'...
            'palmar grasp, grasp onset'...
            'palmar grasp, grasp offset'...
            'lateral grasp, movement onset'...
            'lateral grasp, grasp onset'...
            'lateral grasp, grasp offset'...
            'resting onset'...
            'resting offset'...
            'vertical eye-movements, onset'...
            'vertical eye-movements, offset'...
            'horizontal eye-movements, onset'...
            'horizontal eye-movements, offset'...
            'eye blinking, onset'...
            'eye blinking, offset'};
    values = {'PMon'...
              'PGon'...
              'PGoff'...
              'LMon'...
              'LGon'...
              'LGoff'...
              'Ron'...
              'Roff'...
              'VEon'...
              'VEoff'...
              'HEon'...
              'HEoff'...
              'EBon'...
              'EBoff'};
    m = containers.Map(keys, values);
    if (isKey(m, name))
        converted_name = m(name);
    else
        converted_name = name;
    end
end