function [] = print_results(fig)
    fig.Units = 'centimeters';
    fig.Position = [0 0 27 20];  % magic values so text fits well

    % saving as PDF changes the font...
    % fix: save as svg and convert using inkscape
    %fig.PaperUnits = 'centimeters';
    %fig.PaperPositionMode = 'Auto';
    %fig.PaperSize = [fig.Position(3), fig.Position(4)];
    %print(fig, [fig.Name '.pdf'], '-dpdf');
    %fprintf(['Saved as ' fig.Name '.pdf' '\n']);

    print(fig, [fig.Name '.svg'], '-dsvg');
    fprintf(['Saved as ' fig.Name '.svg' '\n']);
end