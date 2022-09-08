% ------------------ TEST (sys specific) ------------------
%% calc
versatile_and_hero = figure();
tiledlayout(3, 2, 'TileSpacing', 'tight');
for dev=1:3
    % accuracy for each participant (dim5) over whole WOI (dim3)
    test_pspec_accuracy = sum(test_conf_mat(:,:,:,dev,:) .* eye(C), [1,2]) ./ sum(test_conf_mat(:,:,:,dev,:), [1,2]);
    test_pmean_accuracy = mean(test_pspec_accuracy, 5);
    [test_pspec_peak_accuracy, test_pspec_best_timepoint_i] = max(test_pspec_accuracy, [], 3);

    test_pspecmean_confmat = zeros(C, C, size(test_conf,2));
    for p=1:size(test_conf,2)
        % best timepoint index for each participant
        best_timepoint_indices = permute(test_pspec_best_timepoint_i, [5 1 2 3 4]);
        % assign the participant-specific performance peaks to the confmat
        test_pspecmean_confmat(:,:,p) = test_conf_mat(:,:,best_timepoint_indices(p),dev,p);
    end
    test_pspecmean_confmat = sum(test_pspecmean_confmat, 3);
    test_pspecmean_confmat_normalized = test_pspecmean_confmat ./ sum(test_pspecmean_confmat, 2);

    test_significance = adjust_chance_level(1/C, sum(num_trials_per_sys)/45,alpha,T);

    %% plot participant specific test accuracy over whole WOI
    nexttile(2*dev-1);
    cla;
    xline(0, 'HandleVisibility', 'off');
    hold on
    box off;
    ylim([0 100])
    xlim(WOI)

    for p=1:(size(test_conf_mat, 5)-1)
        plot(t, permute(test_pspec_accuracy(:,:,:,:,p), [1 3 2]) .* 100, '-', 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.7, 'HandleVisibility', 'off');
        stem(t(test_pspec_best_timepoint_i(:,:,:,:,p)), test_pspec_peak_accuracy(:,:,:,:,p) * 100, 'filled', 'Color', device_color{dev}, 'LineStyle', 'none', 'HandleVisibility', 'off');
    end
    % make last participant test plot visible for legend
    p = size(test_conf_mat, 5);
    plot(t, permute(test_pspec_accuracy(:,:,:,:,p), [1 3 2]) .* 100, '-', 'Color', [0.7, 0.7, 0.7], 'LineWidth', 0.7);
    stem(t(test_pspec_best_timepoint_i(:,:,:,:,p)), test_pspec_peak_accuracy(:,:,:,:,p) * 100, 'filled', 'Color', device_color{dev}, 'LineStyle', 'none');

    plot(t, permute(test_pmean_accuracy, [1 3 2]) .* 100, '-', 'Color', 'black', 'LineWidth', 2);
    yline(test_significance*100, 'g--', 'LineWidth', 3)

    legend('participant accuracy', 'participant peak', 'grand average participant accuracy', ['significance: ' num2str(test_significance*100, '%.1f') '%'])

    xlabel('time (s)')
    ylabel('Accuracy (%)')
    title({'Best performing Classification model', 'applied on unseen Testdata'})

    %% plot conf mat corresponding to peak of grand average calib accuraccy
    nexttile(2*dev);
    cla;
    plotConfMat(test_pspecmean_confmat_normalized, {'rest', 'pal', 'lat'}, 'Grand average participant peaks (%)', device_color{dev})
    % ---------------------------------------------------------