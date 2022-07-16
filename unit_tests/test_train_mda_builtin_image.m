% Test train_mda_builtin
% not a classical unit test

%% config
mu1 = [0, 0];
mu2 = [5, -5];
mu3 = [2, -8];
sigma1 = [1 1.5; 1.5 3];
sigma2 = [1 -1.5; -1.5 3];
sigma3 = [1 1.5; 1.5 3];
sz1 = 10;
sz = 40;  % scatter size test

% image size
nrows = 100;
ncols = 100;

class2color = @(c) [1 2 3] == c;

%%
class1 = mvnrnd(mu1, sigma1, 10000);
class2 = mvnrnd(mu2, sigma2, 800);
class3 = mvnrnd(mu3, sigma3, 20);

%%
% cvmda({class1, class2, class3}, 10, 5)
[classify, gammas] = train_mda_builtin({class1, class2, class3}, 'rs');

%%

test = {mvnrnd(mu1, sigma1, 3), mvnrnd(mu2, sigma2, 3), mvnrnd(mu3, sigma3, 3)};

figure(1);
clf;
scatter(class1(:,1), class1(:,2),sz1,[1 .7 .7],'filled')
hold on
scatter(class2(:,1), class2(:,2),sz1,[.7 1 .7],'filled')
scatter(class3(:,1), class3(:,2),sz1,[.7 .7 1],'filled')

for k=1:length(test)
    cs = classify(test{k});
    for i=1:length(test{k})
        if (cs(i) == k)
            scatter(test{k}(i,1),test{k}(i,2),sz,class2color(cs(i)),'filled')
        else
            scatter(test{k}(i,1),test{k}(i,2),sz+40,'MarkerEdgeColor',class2color(k),...
                  'MarkerFaceColor',class2color(cs(i)),...
                  'LineWidth',3)
        end
    end
end
row_lims = ylim();
col_lims = xlim();


figure(2);
%%
tocolor = permute(1:3, [3 1 2]);
row_indices = linspace(row_lims(2), row_lims(1), nrows);
col_indices = linspace(col_lims(1), col_lims(2), ncols);
test2_row = reshape(repmat(row_indices, [ncols 1]), [nrows*ncols 1]);
test2_col = repmat(col_indices.', [nrows 1]);
test2 = [test2_col, test2_row];
clsd = classify(test2);
img = reshape(clsd, [ncols nrows]).';
image(img == tocolor);