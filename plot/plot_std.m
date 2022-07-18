function [] = plot_std(x, y, std_dev)
    curve1 = y + std_dev;
    curve2 = y - std_dev;
    x2 = [x, fliplr(x)];
    inBetween = [curve1, fliplr(curve2)];
    fill(x2, inBetween, [0.9 0.9 0.9], 'EdgeColor', [0.7 0.7 0.7]);
end