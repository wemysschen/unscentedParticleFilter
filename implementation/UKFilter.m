function [x_mean_est, P_est] = UKFilter(x_prev, P_prev, U, Q, y_true, R, t, alpha, beta, kappa  )
% Input:
% Output:
% x_mean_predict
% P_predict

%UKF(x(t-1,i), P(t-1,i), [], Q, yt(t), R, t, alpha, beta, kappa);

% dim(x_mean_a) = 3x1

% Augment the state vector with the noise vectors

P_a = [P_prev 0 0; 0 Q 0; 0 0 R];
x_a = [x_prev, 0, 0];


% Calculate the sigma points and the sigma_weights
[sigma_points, sigma_weights, number_of_sigma_points] = ...
    getSigmaPoints(x_mean_a, P_a, alpha, beta, kappa);







Pxy = 

K = Pxy / P_yy;

x_mean_est = x_mean_pred + K* y - y_mean_pred;

P_est = P_pred - K*P_yy*K';

end
