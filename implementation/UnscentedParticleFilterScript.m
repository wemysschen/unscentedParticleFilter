%% Generate data part
clear all
clc
close all
t_max = 60;
x0 = 1; % TODO : change to random value.
[xt,yt] = generateData(t_max, x0); % dim(xt) = 61x1, dim(yt) = 60x1


%% Formulate prior
clc

%TODO: talk about this prior to Hedvig, is it to good?
number_of_samples = 1000;
x0 = 1; % TODO : change to random value.
[xt_prior,yt_prior] = generateData(number_of_samples,x0); % dim(xt) = 1x(t_max+1)

% To begin with, we set the prior to a normal distribution, generated by taking the mu and
% sigma from 1000 datapoints. 
% Another thought: maybe we should do this to get the prior but only on our
% real data points.

pd = fitdist(xt_prior,'Normal');
prior_mu = pd.mu;
prior_sigma = pd.sigma;

%% UPF Algorithm
% Repeat the experiment 100 times.
clc
% Set the number of time steps
T = 60;

% Set the number of particles
%N = 200;
N = 10;

% Step 1. INITIALIZATION, t = 0.
% Draw particles from the prior
particles = normrnd(prior_mu, prior_sigma, 1, N); % 1xN
% Initiate noise variables
v0 = zeros(1,N);
n0 = zeros(1,N);
% Compute mean
estimated_x = mean(particles); % 1x1
% Copute Covariance matrix.
diffs = particles - estimated_x; % 1xN
P0 = diffs*diffs'; % 1x1
% Redefine the state rand var as a concatenation of the original state and
% noise variables.
x_a = [particles', v0', n0']'; % 3xN

% Compute the "new" mean
estimated_x_a = [estimated_x, mean(v0), mean(n0)]'; % 3x1
% Compute the "new" Covariance matrix.
estimated_x_a_duplicates = repmat(estimated_x_a,1,N); % 3xN
diffs = x_a - estimated_x_a_duplicates; % 3xN
P0_a = diffs*diffs'; % 3x3

% Define 
previous_estimated_x_a = estimated_x_a;
previous_P_a = P0_a;
previous_estimated_x = estimated_x;
previous_P = P0;

% Step 2. t = 1,...,60
alpha = 1;
beta = 0; % Comment from the paper: beta = 2 for suitable for Gaussian prior. Change to this?
kappa = 2; % Comment from the paper: kappa = 0 is a good default choise. Change to this?
% TODO: Adapt the content in the nestled loop to take the previous values
% in each of the t:th steps. Not only using the original values.

for t = 1 %t=1:T
    % Loop over all particle filter particles.
        % a) Importance sampling step, using SUT.
        % ----- Calculate sigma points and their weights -----
        % Parameter definitions, should maybe be moved outside big loop.
        n_x = size(x_a,1);
        lambda = alpha^2 * (n_x + kappa) - n_x; 
        sqrt_matrix = sqrt((n_x+lambda)*previous_P_a); %3x3
        % Initialization
        previous_sigma_points = zeros(n_x,(2*n_x+1)); %3x7 
        previous_sigma_weights = zeros(2,(2*n_x+1)); %2x7 
        % The calculations
        previous_sigma_points(:,1) = previous_estimated_x_a;
        for sigma_point_i = 2:(n_x+1)
            previous_sigma_points(:,sigma_point_i) = previous_estimated_x_a + sqrt_matrix(:,sigma_point_i-1);
        end
        for sigma_point_i = (n_x+2):(2*n_x+1)
            previous_sigma_points(:,sigma_point_i) = previous_estimated_x_a - sqrt_matrix(:,sigma_point_i-4);
        end
        
        W0_m = lambda/(n_x+lambda);
        W0_c = lambda/(n_x+lambda) + (1 - alpha^2 + beta);
        previous_sigma_weights(1,:) = W0_m; %1x7
        previous_sigma_weights(2,:) = W0_c; %1x7
        for sigma_point_i = 2:(2*n_x+1)
           previous_sigma_weights(sigma_point_i) = 1/(2*(n_x+lambda)); 
        end
        
        % ----- Propagate particle into future (time update) -----
        % Initialization
        current_sigma_points = zeros(n_x,(2*n_x+1)); %3x7 
        current_sigma_weights = zeros(1,(2*n_x+1)); %1x7 Or should sigma_weights also be 3x7 ?

        % The updates
        previous_sigma_x = previous_sigma_points(1,:);
        previous_sigma_v = previous_sigma_points(2,:);
        previous_sigma_n = previous_sigma_points(3,:);
        previous_t = t-1;
        % !!!!! WHEN / HOW DO WE PUT IN THE NOISE DISTRIBUTIONS INSTEAD OF
        % ZEROS !!!! ??????
        current_sigma_points(1,:) = processModel(previous_sigma_x, previous_sigma_v, previous_t); % 1x7
        current_estimated_x = sum(previous_sigma_weights(1,:) .* current_sigma_points(1,:)); % 1x1
        current_P = sum(previous_sigma_weights(2,:) .* ((current_sigma_points(1,:)-current_estimated_x)*(current_sigma_points(1,:)-current_estimated_x)') ); %1x1
        current_sigma_point_propagations = observationModel(current_sigma_points(1,:),previous_sigma_n, t); % 1x7
        current_estimated_y = sum(previous_sigma_weights(1,:) .* current_sigma_point_propagations); % 1x1
        
        % ----- Incorporate new observation (measurement update) -----
        
    % End Loop over all particle filter partcles.
end    







