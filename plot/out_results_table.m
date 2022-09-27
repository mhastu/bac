function [] = out_results_table(type, filename)
%OUT_RESULTS_TABLE Print the results table on the CLI in LaTeX format.
    
    if nargin < 2
        filename = [type '_classification_allnorm'];
    end

    % config
    systems = {'G', 'V', 'H'};
    Devs = 1:3;
    C = 3;  % number of classes% timepoint config
    WOI = [-2 3];        % window of interest in seconds (open on left side)
    fs = 16;
    t = WOI(1)+1/fs:1/fs:WOI(2);
    T = length(t);

    load('config', 'dir_results');
    load(fullfile(dir_results, filename), 'calib_conf', 'test_conf', 'timepoint');

    if any(strcmp(type, {'CP', 'AS'}))
        fprintf('    \\begin{tabular}{l c c c@{\\hspace{0.5cm}} c c}\n');
        fprintf('        \\toprule\n');
        fprintf('        & \\multicolumn{2}{c}{\\textbf{Calibration set}} & & \\multicolumn{2}{c}{\\textbf{Test set}} \\\\\n');
        fprintf('        \\cmidrule{2-3}\\cmidrule{5-6}\n');
        fprintf('        \\textbf{\\#} & \\textbf{Peak (\\%%)} & \\textbf{Time (s)} & & \\textbf{Peak (\\%%)} & \\textbf{Time (s)} \\\\\n');
        fprintf('        \\midrule\n');
    elseif strcmp(type, 'LS')
        fprintf('    \\begin{tabular}{l c c c@{\\hspace{0.5cm}} c c c@{\\hspace{0.5cm}} c c}\n');
        fprintf('        \\toprule\n');
        fprintf('        & \\multicolumn{2}{c}{\\textbf{Gel}} & & \\multicolumn{2}{c}{\\textbf{Water}} & & \\multicolumn{2}{c}{\\textbf{Dry}} \\\\\n');
        fprintf('        \\cmidrule{2-3}\\cmidrule{5-6}\\cmidrule{8-9}\n');
        fprintf('        \\textbf{\\#} & \\textbf{Peak (\\%%)} & \\textbf{Time (s)} & & \\textbf{Peak (\\%%)} & \\textbf{Time (s)} & & \\textbf{Peak (\\%%)} & \\textbf{Time (s)} \\\\\n');
        fprintf('        \\midrule\n');
    end

    switch type
        % =================================================================
        case 'CP'
            % convert cells
            calib_conf_mat = zeros(C, C, T, size(calib_conf,1), size(calib_conf,2));
            for dev=Devs
                for p=1:size(calib_conf,2)
                    calib_conf_mat(:,:,:,dev,p) = calib_conf{dev,p};
                end
            end
            test_conf_mat = zeros(C, C, T, size(test_conf,1), size(test_conf,2));
            for dev=Devs
                for p=1:size(test_conf,2)
                    test_conf_mat(:,:,:,dev,p) = test_conf{dev,p};
                end
            end

            for dev=Devs
                % accuracy for each participant (dim5) over whole WOI (dim3)
                calib_accuracies = sum(calib_conf_mat(:,:,:,dev,:) .* eye(C), [1,2]) ./ sum(calib_conf_mat(:,:,:,dev,:), [1,2]);
                test_accuracies = sum(test_conf_mat(:,:,:,dev,:) .* eye(C), [1,2]) ./ sum(test_conf_mat(:,:,:,dev,:), [1,2]);

                calib_acc_sum = 0;
                calib_t_sum = 0;
                test_acc_sum = 0;
                test_t_sum = 0;
                for p=1:15
                    calib_accuracy = permute(calib_accuracies(:,:,:,:,p), [1 3 2]);  % convert to row vector
                    [calib_peak_accuracy, calib_timepoint_i] = max(calib_accuracy);
                    calib_peak_accuracy = 100*calib_peak_accuracy;  % in percent
                    calib_t = t(calib_timepoint_i);
                    calib_acc_sum = calib_acc_sum + calib_peak_accuracy;
                    calib_t_sum = calib_t_sum + calib_t;

                    test_accuracy = permute(test_accuracies(:,:,:,:,p), [1 3 2]);  % convert to row vector
                    [test_peak_accuracy, test_timepoint_i] = max(test_accuracy);
                    test_peak_accuracy = 100 * test_peak_accuracy;  % in percent
                    test_t = t(test_timepoint_i);
                    test_acc_sum = test_acc_sum + test_peak_accuracy;
                    test_t_sum = test_t_sum + test_t;

                    if (calib_t ~= timepoint{dev,p})
                        error('mismatching best timepoint')  % assertion
                    end

                    id = [systems{dev} num2str(p, '%02d')];
                    fprintf(['        ' id ' & ' num2str(calib_peak_accuracy, '%.1f') ' & ' num2str(calib_t, '%.1f') ' & & ' num2str(test_peak_accuracy, '%.1f') ' & ' num2str(test_t, '%.1f') ' \\\\\n']);
                end
                fprintf(['        Average & ' num2str(calib_acc_sum/15,'%.1f') ' & ' num2str(calib_t_sum/15,'%.1f') ' & & ' num2str(test_acc_sum/15,'%.1f') ' & ' num2str(test_t_sum/15,'%.1f') '\\\\\n']);
            end
        % =================================================================
        case 'AS'
            % convert cells
            calib_conf_mat = zeros(C, C, T, size(calib_conf,1), size(calib_conf,2));
            for p=1:size(calib_conf,2)
                calib_conf_mat(:,:,:,1,p) = calib_conf{p};
            end
            test_conf_mat = zeros(C, C, T, size(test_conf,1), size(test_conf,2));
            for dev=Devs
                for p=1:size(test_conf,2)
                    test_conf_mat(:,:,:,dev,p) = test_conf{dev,p};
                end
            end

            calib_acc_sum = 0;
            calib_t_sum = 0;
            test_acc_sum = 0;
            test_t_sum = 0;
            % accuracy for each participant (dim5) over whole WOI (dim3)
            calib_accuracies = sum(calib_conf_mat .* eye(C), [1,2]) ./ sum(calib_conf_mat, [1,2]);

            for p=1:15
                calib_accuracy = permute(calib_accuracies(:,:,:,:,p), [1 3 2]);  % convert to row vector
                [calib_peak_accuracy, calib_timepoint_i] = max(calib_accuracy);
                calib_peak_accuracy = 100*calib_peak_accuracy;  % in percent
                calib_t = t(calib_timepoint_i);
                calib_acc_sum = calib_acc_sum + calib_peak_accuracy;
                calib_t_sum = calib_t_sum + calib_t;

                if (calib_t ~= timepoint{p})
                    error('mismatching best timepoint')  % assertion
                end

                for dev=Devs
                    test_accuracies = sum(test_conf_mat(:,:,:,dev,p) .* eye(C), [1,2]) ./ sum(test_conf_mat(:,:,:,dev,p), [1,2]);
                    test_accuracy = permute(test_accuracies, [1 3 2]);  % convert to row vector
                    [test_peak_accuracy, test_timepoint_i] = max(test_accuracy);
                    test_peak_accuracy = 100 * test_peak_accuracy;  % in percent
                    test_t = t(test_timepoint_i);
                    test_acc_sum = test_acc_sum + test_peak_accuracy;
                    test_t_sum = test_t_sum + test_t;


                    id = [systems{dev} num2str(p, '%02d')];
                    if dev==2
                        fprintf(['        ' id ' & ' num2str(calib_peak_accuracy, '%.1f') ' & ' num2str(calib_t, '%.1f') ' & & ' num2str(test_peak_accuracy, '%.1f') ' & ' num2str(test_t, '%.1f') ' \\\\\n']);
                    else
                        fprintf(['        ' id ' & & & & ' num2str(test_peak_accuracy, '%.1f') ' & ' num2str(test_t, '%.1f') ' \\\\\n']);
                    end
                    if dev==3
                        fprintf('        \\midrule\n');
                    end
                end
            end
            fprintf(['        Average & ' num2str(calib_acc_sum/15,'%.1f') ' & ' num2str(calib_t_sum/15,'%.1f') ' & & ' num2str(test_acc_sum/45,'%.1f') ' & ' num2str(test_t_sum/45,'%.1f') '\\\\\n']);
        % =================================================================
        case 'LS'
            % convert cells
            test_conf_mat = zeros(C, C, T, size(test_conf,1), size(test_conf,2));
            for dev=Devs
                for p=1:size(test_conf,2)
                    test_conf_mat(:,:,:,dev,p) = test_conf{dev,p};
                end
            end

            test_acc_sum = [0 0 0];
            test_t_sum = [0 0 0];
            for p=1:15
                id = num2str(p, '%02d');
                fprintf(['        ' id]);
                for dev=Devs
                    test_accuracies = sum(test_conf_mat(:,:,:,dev,p) .* eye(C), [1,2]) ./ sum(test_conf_mat(:,:,:,dev,p), [1,2]);
                    test_accuracy = permute(test_accuracies, [1 3 2]);  % convert to row vector
                    [test_peak_accuracy, test_timepoint_i] = max(test_accuracy);
                    test_peak_accuracy = 100 * test_peak_accuracy;  % in percent
                    test_t = t(test_timepoint_i);
                    test_acc_sum(dev) = test_acc_sum(dev) + test_peak_accuracy;
                    test_t_sum(dev) = test_t_sum(dev) + test_t;
    
                    fprintf([' & ' num2str(test_peak_accuracy, '%.1f') ' & ' num2str(test_t, '%.1f') ' &']);
                end
                fprintf('\b\\\\\n');
            end
            fprintf('        Average');
            for dev=Devs
                fprintf([' & ' num2str(test_acc_sum(dev)/15,'%.1f') ' & ' num2str(test_t_sum(dev)/15,'%.1f') ' &']);
            end
            fprintf('\b\\\\\n');
        % =================================================================
        case 'LSc'
            % convert cells
            calib_conf_mat = zeros(C, C, T, size(calib_conf,1), size(calib_conf,2));
            for dev=Devs
                calib_conf_mat(:,:,:,dev,1) = calib_conf{dev};
            end

            for dev=Devs
                calib_accuracies = sum(calib_conf_mat .* eye(C), [1,2]) ./ sum(calib_conf_mat, [1,2]);
                calib_accuracy = permute(calib_accuracies(:,:,:,dev,1), [1 3 2]);  % convert to row vector
                [calib_peak_accuracy, calib_timepoint_i] = max(calib_accuracy);
                calib_peak_accuracy = 100*calib_peak_accuracy;  % in percent
                calib_t = t(calib_timepoint_i);
                fprintf(['device ' systems{dev} ': ' num2str(calib_peak_accuracy,'%.1f') ' at ' num2str(calib_t,'%.1f') '\n']);
            end
    end

    fprintf('    \\end{tabular}\n');
end

