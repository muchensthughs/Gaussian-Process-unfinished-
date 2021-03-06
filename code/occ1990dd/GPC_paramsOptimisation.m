function [optimised_params, latent_f_opt, L, W, K,fval] = GPC_paramsOptimisation (initialParams, ind, numSamples, numDims, numPoints, X, Y,sig_func)


%real value bounds
l_bounds = [1 10];
sigmaf_bounds= [1 10];
f_bounds = [0.1 1];

%weight_bounds = [1 5; 1 5; 1 5; 1 5;1 5;1 5;1 5;1 5;1 5;1 5;1 5; 1 5; 1 5; 1 5; 1 10; 1 10; 1 10];
weight_bounds = zeros(numDims,2);
weight_bounds(:,1) = 1;
weight_bounds(:,2) = 50;
%weight_bounds = [1 10; 1 10; 1 10; 1 10;1 10;1 10;1 10;1 10;1 10;1 10;1 10];

%weight_bounds = [1 100];
%initial samples for optimisation
upperbound = [];
lowerbound = [];
options = optimoptions(@fminunc,'Algorithm','quasi-newton','GradObj','on');
l_bounds = [log(l_bounds(1)) log(l_bounds(2))];
if ind(1) == 1,
upperbound = [upperbound l_bounds(2)];
lowerbound = [lowerbound l_bounds(1)];
end
sigmaf_bounds = [log(sigmaf_bounds(1)) log(sigmaf_bounds(2))];
if ind(2) == 1,
upperbound = [upperbound l_bounds(2)];
lowerbound = [lowerbound l_bounds(1)];
end
f_bounds = [log(f_bounds(1)) log(f_bounds(2))];
if ind(3) == 1,
upperbound = [upperbound f_bounds(2)];
lowerbound = [lowerbound f_bounds(1)];
end

for i=1:numDims,
 weight_bounds(i,:) = [log(weight_bounds(i,1)) log(weight_bounds(i,2))];
 if ind(i+3) == 1,
     upperbound = [upperbound weight_bounds(i,2)];
     lowerbound = [lowerbound weight_bounds(i,1)];
 end
end




%sampling over exponentiated values
var_inits = lhs_sample(l_bounds, sigmaf_bounds, f_bounds, weight_bounds, numSamples, numDims, ind, 'need exponential' );
%take log of the samples so that the original sample values can be read
%corretly in calcLikelihood.m
var_inits = log(var_inits);
%find the optimised set of parameters where function output of the
%GP_calcLikelihood (log marginal likelihood) is maxmised

params_matrix = [];
for i = 1:numSamples
     funcObj = @(variables) GPC_calcLikelihood (variables,initialParams, ind,numDims, numPoints, X, Y,sig_func);
    funcProj = @(variables)boundProject(variables,lowerbound',upperbound');
   [local_opt_vars, local_fmin ] = minConf_PQN(funcObj, var_inits(i,:)',funcProj,[]);
%   [local_opt_vars, local_fmin, exitflag] = fminunc(@(variables) GPC_calcLikelihood (variables,initialParams, ind,numDims, numPoints, X, Y), var_inits(i,:),options);
%[local_opt_vars, local_fmin, exitflag] = fminsearch(@(variables) GPC_calcLikelihood (variables,initialParams, ind,numDims, numPoints, X, Y, const_weights), var_inits(i,:));
%[local_opt_vars, local_fmin] = patternsearch(@(variables) GPC_calcLikelihood (variables,initialParams, ind,numDims, numPoints, X, Y), var_inits(i,:),[],[],[],[],[l_bounds;sigmaf_bounds;weight_bounds]);

  params_matrix = [params_matrix; local_fmin local_opt_vars' var_inits(i,:) i];
end


params_matrix = sortrows(params_matrix);
chosen_params = params_matrix(1,2:1+length(local_opt_vars)); %exclude the local_fmin and choose the parameters only
count = 1;
for i = 1:length(ind)
 if ind(i) == 1,
     optimised_params(i) = chosen_params(count);
     count = count + 1;
 else
     optimised_params(i) = initialParams(i);
 end
end

%%using the optimised parameters to calculate the best latent f

[fval, ~, latent_f_opt, L, W, K] = GPC_calcLikelihood (optimised_params,optimised_params,ones(1,length(ind)),numDims, numPoints, X, Y,sig_func);
fval = -fval;
