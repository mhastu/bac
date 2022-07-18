% imports
addpath LDA

% create quite hardly distinguishable trainals
dim = 522;  % number of features
C = 3;

% data cloud means
mu1 = zeros(1, dim);
mu2 = mod(1:dim, 2) * 3;
mu3 = mod(2:dim+1, 2) * 3;

% data cloud covariance matrices
sigma1 = eye(dim);
sigma2 = eye(dim);
sigma3 = eye(dim);

% train data
class1 = mvnrnd(mu1, sigma1, 100);
class2 = mvnrnd(mu2, sigma2, 80);
class3 = mvnrnd(mu3, sigma3, 20);

% train model
[classify, gammas] = train_mda({class1, class2, class3}, 'rs');

% test data
test = {mvnrnd(mu1, sigma1, 100), mvnrnd(mu2, sigma2, 100), mvnrnd(mu3, sigma3, 100)};

conf = zeros(C);
for c=1:C
    conf(c, :) = sum(classify(test{c}) == (1:C), 1);
end

performance = sum(conf .* eye(C), 'all') / sum(conf, 'all');
fprintf(['test_train_mda: performance: ' num2str(performance) '\n']);
conf_normalized = 100 * conf ./ sum(conf, 2) %#ok<NOPTS> 
