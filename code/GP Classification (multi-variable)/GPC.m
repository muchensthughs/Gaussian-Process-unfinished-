%%%%%%%%%% Initialisation %%%%%%%%%%%%%%%
clear all
params = GPC_combineParams(1, 0.3, 0);
change_vars = [1, 1, 0];
numSamples = 5;


X1 = [-2.0, -1.9, -1.8, -1.7, -1.5,-1,    -0.1, 0.2, 0.1, 0, 0.15, 0.03, 0.25,    2.2, 2.5, 2.7, 2.3,3,2.8,     5.0, 5.1, 5.2, 5.3, 5.4]';
%X2 = [-1.5, -1, -0.5, 1, 0.5, 1.0, 1.5, 2.0]';
X2 = [-2.0, -1.1, -1.5, -1.3, -1.7,-1.8,   2.5, 2.8, 1.2, 1.9, 1.5, 1.8, 2,    2.1, 4, 2.3, 3.3,5, 4,    5.0, 3.8, 4.2, 2.3, 3.4]';

X = [X1 X2];
Y = [-1, -1, -1, -1, -1, -1, 1, 1, 1, 1, 1, 1, 1, -1, -1, -1, -1, -1, -1, 1, 1, 1, 1, 1]';

numInputPoints = size(X,1);
[optimised_params, latent_f_opt, L, W, K] = GPC_paramsOptimisation(params, change_vars, numSamples,numInputPoints,X,Y );
optimised_params(:)

X_est1  = min(X1) + (0:(1e2-1))/1e2 * (max(X1) - min(X1));
X_est1 = X_est1';
X_est2  = min(X2) + (0:(1e2-1))/1e2 * (max(X2) - min(X2));
X_est2 = X_est2';
X_est = [X_est1 X_est2];
[X_est, K, variance] = GPC_inference(X, Y, optimised_params, X_est, latent_f_opt, L, W, K);


