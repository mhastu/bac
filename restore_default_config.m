if ~isfile('default_config.mat')
    fig = uifigure;
    uialert(fig, 'Cannot find default configuration.', 'missing default_config.mat');
    error('Cannot find default configuration.');
end
if isfile('config.mat')
    fig = uifigure;
    if uiconfirm(fig, 'Overwrite existing config?', 'found config.mat')
        restore_defaults();
    end
else
    restore_defaults();
end

function [] = restore_defaults()
    defaults = load('default_config.mat');
    save('config.mat','-struct', 'defaults');
end
