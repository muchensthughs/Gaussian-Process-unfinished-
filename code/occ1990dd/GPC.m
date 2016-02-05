%%%%%%%%%% Initialisation %%%%%%%%%%%%%%%
clear all



addpath(genpath('/Users/muchen/Desktop/Gaussian-Process/code/occ1990dd'));


filename1 = '1990_all.xlsx';
A = xlsread(filename1);


filename2 = '/Users/muchen/Desktop/Gaussian-Process/code/1990results.csv';



filename4 = '/Users/muchen/Desktop/Gaussian-Process/code/data_matching.xlsx';

file_1990 = '1990dd.xlsx';
training_data = xlsread(file_1990,1);
X = training_data(:,2:4);
running_data = xlsread(file_1990,2);
X_est = running_data(:,2:4);
X_all = A(:,3:5);


num_dims = 3;
numSamples = 40;

 mean_A = mean (X_all);
 num_inst = length(X_all(:,1));
 
 for j = 1:num_dims,
     X(:,j) = X(:,j) - mean_A(1,j);
%     var = sum(X(:,j).^2)/num_inst;
%     X(:,j) = X(:,j)./sqrt(var);
     
     X_est(:,j) = X_est(:,j) - mean_A(1,j);
%     var = sum(X_est(:,j).^2)/num_inst;
%     X_est(:,j) = X_est(:,j)./sqrt(var);
     
     X_all(:,j) = X_all(:,j) - mean_A(1,j);     
%     var = sum(X_all(:,j).^2)/num_inst;
%     X_all(:,j) = X_all(:,j)./sqrt(var);
 end


class = []; Y_01 = [];
Y_01 = training_data(:,5);
Y = Y_01;

for i = 1:length(Y_01)
    if Y_01(i) == 0,
        Y(i) = -1;
    end
end

train_length = size(X,1);

AUC_all = [];
optimised_params_all = [];



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ROC%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% train_length = size(X,1);
% % while mod(train_length,2) ~= 0,
% %    X = X(1:(end-1),:);
% %    Y = Y(1:(end-1),:);
% %    Y_01 = Y_01(1:(end-1),:);
% %    train_length = train_length - 1;
% % end
% 
% AUC_all = [];
% 
% for j = 1:10,
%     
%  r = randsample(train_length,train_length/2-1 );
%  [rest] = setdiff((1:train_length),r,'stable');
%  train_X = X(rest,:);
%  train_Y = Y(rest,:);
%  target_X = X(r,:);
%  target_Y = Y_01(r,:);
%  target_Y = target_Y';
 
 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%For A%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


weights = zeros(1,num_dims);
change_weights = ones(1,num_dims);
params = [-1, 0.3, 0, weights];
change_vars = [1, 1, 0, change_weights];


% %%%%%%%%%%%%%PCA%%%%%%%%%%%%%%%%%%%%
% %  [coeff, score, latent] = princomp(X_est);
% %   varorder = cumsum(latent)./sum(latent);
% %   %preserve 95% variance
% %  coeffinuse = coeff(:,1:11);
% %  X_est = X_est * coeffinuse;
% %  
% for i = 1:num_inst,
%     if A(i,20) == 0 ,
%         X = [X; X_est(i, :)];
%         Y = [Y; -1];
%         Y_01 = [Y_01; 0];
%     elseif A(i,20) == 1,
%         X = [X; X_est(i, :)];
%         Y = [Y; 1]; 
%  Y_01 = [Y_01; 1];
%     end
%  
% %   if A(i,2) >= 0.5,
% %       class = [class; 1];
% %   else
% %       class = [class; -1];
% %   end
%   %X_est = X; 
% end
% train_length = size(X,1);
% if mod(train_length,2) ~= 0,
%    X = X(1:(end-1),:);
%    Y = Y(1:(end-1),:);
%    Y_01 = Y_01(1:(end-1),:);
%    train_length = train_length - 1;
% end
% 
%  r = randsample(train_length,train_length/2);
%  [rest] = setdiff((1:train_length),r,'stable');
%  train_X = X(r,:);
%  train_Y = Y(r,:);
%  target_X = X(rest,:);
%  target_Y = Y_01(rest,:);
%  target_Y = target_Y';
% 
% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%For A%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% numInputPoints = size(X,1);
% [optimised_params, latent_f_opt, L, W, K] = GPC_paramsOptimisation(params, change_vars, numSamples,num_dims, numInputPoints,X,Y);

for k = 1:3,    
 r = randsample(train_length,5);
 [rest] = setdiff((1:train_length),r,'stable');
 train_X = X(rest,:);
 train_Y = Y(rest,:);
 test_X = X(r,:);
 test_Y = Y_01(r,:);
 test_Y = test_Y';

numInputPoints = size(train_X,1);
[optimised_params, latent_f_opt, L, W, K] = GPC_paramsOptimisation(params, change_vars, numSamples,num_dims, numInputPoints,train_X,train_Y);
optimised_params_all = [optimised_params_all; optimised_params];


[test_X, K, variance, pi_star, pi_star_ave] = GPC_inference(train_X, train_Y, optimised_params, test_X, latent_f_opt, L, W, num_dims);
[X_AUC,Y_AUC,T,AUC] = perfcurve(test_Y,pi_star_ave,'1'); 
AUC_all = [AUC_all AUC];
end

[AUC_max, max_index] = max(AUC_all);
AUC_max
optimised_params = optimised_params_all(max_index,:);
optimised_params(:)



[X_all, K, variance, pi_star, pi_star_ave] = GPC_inference(train_X, train_Y, optimised_params, X_all, latent_f_opt, L, W, num_dims);

pi_star_ave = pi_star_ave';
xlswrite(filename2,pi_star_ave);



% h = histogram(E)
% title('Histogram of changes in automatability from 1990 to 2010')
% xlabel('change in probability of computerisation')
% ylabel('Number of occupations')





% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ROC%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  figure
%  plot(pi_star_ave,target_Y, 'b+');
%  xlabel('MC');
%  ylabel('target class');
%  title('Ave. Probability');
%  ax = gca; % current axes
%     ax.FontSize = 14;
%  hold on;
% figure
% %[tpr,fpr,thresholds,AUC] = roc(target_Y,pi_star_ave);
% [X_AUC,Y_AUC,T,AUC] = perfcurve(target_Y,pi_star_ave,'1');
% AUC_all = [AUC_all AUC];
% % plot(X_AUC,Y_AUC)
% % xlabel('False positive rate')
% % ylabel('True positive rate')
% % title('ROC for Employment Automatability Classification')
% % outputString  = sprintf('AUC = %f',AUC);
% % text(0.5,0.5,outputString,'FontSize', 16);
% % %plotroc(target_Y,pi_star_ave);
% % ax = gca; % current axes
% %     ax.FontSize = 16;
% %  hold on   
% end
% 
% AUC = mean(AUC_all)