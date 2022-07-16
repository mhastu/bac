function [] = plotConfMat(confmat, labels, ptitle, bcolor)
    %PLOTCONFMAT plots the confusion matrix with colorscale, absolute numbers
    %   and precision normalized percentages
    %
    %   usage: 
    %   PLOTCONFMAT(confmat) plots the confmat with integers 1 to n as class labels
    %   PLOTCONFMAT(confmat, labels) plots the confmat with the specified labels
    %   PLOTCONFMAT(confmat, labels, ptitle) plots given title
    %   PLOTCONFMAT(confmat, labels, ptitle, bcolor) specificies the border color
    %
    %   changed from Vahe Tshitoyan (20/08/2017): https://de.mathworks.com/matlabcentral/fileexchange/64185-plot-confusion-matrix
   
    % config
    map = [linspace(0.95, 0, 256)' linspace(1, 0.44, 256)' linspace(1, 0.74, 256)'];

    numlabels = size(confmat, 1); % number of labels
    % calculate the percentage accuracies
    %confpercent = 100*confmat./repmat(sum(confmat, 1),numlabels,1);
    confpercent = 100*confmat;
    % plotting the colors
    imagesc(confpercent, [0 100]);
    ylabel('True', 'FontSize', 14); xlabel('Predicted', 'FontSize', 14);
    % set the colormap
    colormap(map)
    % Create strings from the matrix values and remove spaces
    textStrings = num2str(confpercent(:), '%.1f');
    textStrings = strtrim(cellstr(textStrings));
    % Create x and y coordinates for the strings and plot them
    [x,y] = meshgrid(1:numlabels);
    hStrings = text(x(:),y(:),textStrings(:), ...
        'HorizontalAlignment','center', ...
        'FontSize', 20);
    % Choose white or black for the text color of the strings so
    % they can be easily seen over the background color
    textColors = repmat(confpercent(:) > 75,1,3);
    set(hStrings,{'Color'},num2cell(textColors,2));

    % make maximum values bold
    [~, bold_i] = max(confmat, [], 2);
    textBold = false(size(confmat));
    textBold(sub2ind(size(x),1:size(x,1),bold_i.'))=true;
    textBold = textBold(:);
    textFontWeight = cell(size(textBold));
    textFontWeight(textBold) = {'bold'};
    textFontWeight(~textBold) = {'normal'};
    set(hStrings, {'FontWeight'}, textFontWeight);

    % Setting the axis labels
    set(gca,'XTick',1:numlabels,...
        'XTickLabel',labels,'FontSize', 14,...
        'YTick',1:numlabels,...
        'YTickLabel',labels,'FontSize', 14,...
        'TickLength',[0 0]);
    title(ptitle, 'FontSize', 12);

    % style square
    axis square

    % plot grid
    for i=1:numlabels-1
        yline(i+0.5);
        xline(i+0.5);
    end

    if nargin > 3
        yline(0.5, 'Color', bcolor, 'LineWidth', 5)
        yline(numlabels+0.5, 'Color', bcolor, 'LineWidth', 5)
        xline(0.5, 'Color', bcolor, 'LineWidth', 5)
        xline(numlabels+0.5, 'Color', bcolor, 'LineWidth', 5)
    end

    colorbar
end