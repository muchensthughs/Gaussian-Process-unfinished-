
function [fval, gradient, latent_f, L, W, K] = GPC_calcLikelihood (variables,initialParams,ind, numPoints, X, Y)


% loading the parameters

% Variables:  1xnumVars containing all the variables that need to be
% opimised for each group of variable sample

varCount = 1;

if ind(1) == 1,
    l = variables(varCount);
    varCount = varCount + 1;
else
    l = initialParams(1);
end
exp_l = exp(l);
if ind(2) == 1,
    sigma_f = variables(varCount);
    varCount = varCount + 1;
else
    sigma_f = initialParams(2);
end
exp_sigma_f = exp(sigma_f);
if ind(3) == 1,
    f = variables(varCount);
    varCount = varCount + 1;
else
    f = initialParams(3);
end
exp_f = exp(f);


% covariance matrix and derivatives
K = zeros(numPoints); dKdl = zeros(numPoints); dKdf = zeros(numPoints); dKdw = zeros(numPoints);
for i = 1:numPoints,
    for j = 1:numPoints,
        [K(i,j), dKdl(i,j), dKdf(i,j), dKdw(i,j)] = GPC_covariance (X(i),X(j),exp_l, exp_sigma_f, exp_f);
    end
end



    K =  K + (1e3*eps).*eye(numPoints);


latent_f = zeros(numPoints,1);
ti = (Y+1)/2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Logistic function%%%%%%%%%%%%%%%%%%%%%
%with correction
%yf = Y.*latent_f; s = -yf;
%   ps   = max(0,s); 
%    logpYf = -(ps+log(exp(-ps)+exp(s-ps))); 
%    logpYf = sum(logpYf);
%   s   = min(0,latent_f); 
%   p   = exp(s)./(exp(s)+exp(s-latent_f));                    % p = 1./(1+exp(-f))
 %  dlogpYf = ti-p;                          % derivative of log likelihood                         % 2nd derivative of log likelihood
 %  d2logpYf = -exp(2*s-latent_f)./(exp(s)+exp(s-latent_f)).^2;


    %without correction

%ti = (Y + 1)/2 ;
%pii = 1./(1+exp(-latent_f));
%d2logpYf = -pii.*(1 - pii);
%dlogpYf = ti - pii;

%find objective function with current settings
%logpYf = -log(1 + exp(-Y.*latent_f));
%logpYf = sum(logpYf);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Probit function%%%%%%%%%%%%%%%%%%%%%%
cdf = normcdf(Y.*latent_f);
pdf = normpdf(latent_f);
logpYf = log(cdf);
logpYf = sum(logpYf);
dlogpYf =( Y.*pdf)./ cdf;
d2logpYf = - (Y.*Y.*pdf.*pdf)./(cdf.*cdf) - (Y.*latent_f.*pdf)./cdf;

a0 = zeros(numPoints,1);
a_mat(:,1) = a0; 
obj = logpYf - (1/2)*a0'*latent_f ;

obj_mat(1) =obj;
obj_grad = dlogpYf - K'*latent_f;
 count = 2;
%check whether the objective function has approached its stationary point
%while norm(obj_grad) > 1e-3,
tol = 1e-6;
change = inf - obj_mat(1);
while change > tol,
   
    %store the value of latent_f and objective function from last iteration  
    %last_latent_f = latent_f;   
  

    %update latent_f 
    W = - diag(d2logpYf);
sqrtW = sqrt(W);

B = eye(numPoints) + sqrtW*K*sqrtW;
[L,q] = chol (B,'lower');
jitter = 1e-16;
K_prev = K;
min_eigB = min(eig(B));
min_eigK = min(eig(K));
while q ~= 0 || min_eigB < 1 || min_eigK < 0,
    K =  K_prev + jitter.*eye(numPoints);
    B = eye(numPoints) + sqrtW*K*sqrtW;
    [L,q] = chol (B,'lower');
    jitter = jitter*10;
    min_eigB = min(eig(B));
    min_eigK = min(eig(K));
end
min_eigB = min(eig(B));
min_eigK = min(eig(K));
if min_eigB < 1 || min_eigK < 0,
    exp_l = exp_l
    exp_sigma_f = exp_sigma_f
    eigB = eig(B)
    eigK = eig(K)
end
b = W*latent_f + dlogpYf;
a = b - sqrtW*(L'\(L\(sqrtW*(K*b))));

a_mat(:,count) = a;
step(:,count) = zeros(numPoints,1);
latent_f = K*a;
    %step = latent_f - last_latent_f;
    if count > 1,
  step(:,count-1) = a_mat(:,count) - a_mat(:,count-1);
    end

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Probit function%%%%%%%%%%%%%%%%%%%%%%
cdf = normcdf(Y.*latent_f);
pdf = normpdf(latent_f);
logpYf = log(cdf);
logpYf = sum(logpYf);
obj = logpYf - (1/2)*a'*latent_f ;
obj_mat(count) = obj;
change = obj_mat(count) - obj_mat(count - 1);
dlogpYf =( Y.*pdf)./ cdf;
d2logpYf = - (Y.*Y.*pdf.*pdf)./(cdf.*cdf) - (Y.*latent_f.*pdf)./cdf;
obj_grad = dlogpYf - K'*latent_f;

    %%%%%%%%%%%%%%%%%%%%%Logistic function%%%%%%%%%%%%%%%%%%%%%%%%%%
    % without corrections!!!!!!!!
%    logpYf = -log(1 + exp(-Y.*latent_f));
%    logpYf = sum(logpYf);
%    obj = logpYf - (1/2)*a'*latent_f ;
%    obj_mat(count) = obj;
%    change = obj_mat(count) - obj_mat(count - 1);
%    pii = 1./(1+exp(-latent_f));
%    d2logpYf = -pii.*(1 - pii);
%    dlogpYf = ti - pii;
%    obj_grad = dlogpYf - K'*latent_f;
    
    %with corrections!!!!!!!!!!!
%    yf = Y.*latent_f; s = -yf;
%    ps   = max(0,s); 
%    logpYf = -(ps+log(exp(-ps)+exp(s-ps))); 
%    logpYf = sum(logpYf);
%    s   = min(0,latent_f); 
%    p   = exp(s)./(exp(s)+exp(s-latent_f));                    % p = 1./(1+exp(-f))
%    dlogpYf = (Y+1)/2-p;                          % derivative of log likelihood                         % 2nd derivative of log likelihood
%    d2logpYf = -exp(2*s-latent_f)./(exp(s)+exp(s-latent_f)).^2;
%    obj = logpYf - (1/2)*a'*latent_f ;
%    obj_mat(count) = obj;
%    change = obj_mat(count) - obj_mat(count - 1);
%    obj_grad = dlogpYf - K'*latent_f;
    
    count = count +1;  
    
 
%%error check -- step may not be of the right scale
if change < 0,
    %%%%debug plots%%%%%%%
  
  %  for n = 1:count-1 
  n = count - 1;
    %x = -5:0.1:5;
    %latent_f_test = latent_f;
    %a_test = last_a;
   %x = -20:0.1:0;
    for i = 0:200
    %latent_f_test(n) = x(i+1);
     %a_test(n) = x(i+1);
    a_test = a_mat(:,n) + ((i+1)/10)*(-step(:,n));
    latent_f_test = K*a_test;
    
    %%with correction!!!!!!!!!!!!!
%    yf = Y.*latent_f_test; s = -yf;
%    ps   = max(0,s); 
%   logpYf = -(ps+log(exp(-ps)+exp(s-ps))); 
%    logpYf = sum(logpYf);
%    s   = min(0,latent_f_test); 
%   p   = exp(s)./(exp(s)+exp(s-f));                    % p = 1./(1+exp(-f))
%    dlogpYf = (Y+1)/2-p;                          % derivative of log likelihood                         % 2nd derivative of log likelihood
%    d2logpYf = -exp(2*s-latent_f_test)./(exp(s)+exp(s-latent_f_test)).^2;
%    obj = logpYf - (1/2)*a_test'*latent_f_test ;


    %%%%%%%%%%%%%%%%%%%%%Logistic function%%%%%%%%%%%%%%%%%%%%%%%%%%
    % without corrections!!!!!!!!
    logpYf = -log(1 + exp(-Y.*latent_f_test));
    logpYf = sum(logpYf);
    obj = logpYf - (1/2)*a_test'*latent_f_test ;
    change_a = obj;
    
    %change = obj - obj_mat(count - 1);
    pii = 1./(1+exp(-latent_f_test));
    d2logpYf = -pii.*(1 - pii);
    dlogpYf = ti - pii;
    obj_grad = dlogpYf - K'*latent_f_test;
    
 %   y(i+1) = obj;
    end


end
end

 %calculate optimised latent_f with final a    
 W = -diag(d2logpYf);
sqrtW = sqrt(W);
B = eye(numPoints) + sqrtW*K*sqrtW;
[L,q] = chol (B,'lower');
jitter = 1e-16;
K_prev = K;
min_eigB = min(eig(B));
min_eigK = min(eig(K));
while q ~= 0 || min_eigB < 1 || min_eigK < 0,
    K =  K_prev + jitter.*eye(numPoints);
    B = eye(numPoints) + sqrtW*K*sqrtW;
    [L,q] = chol (B,'lower');
    jitter = jitter*10;
    min_eigB = min(eig(B));
    min_eigK = min(eig(K));
end
min_eigB = min(eig(B));
min_eigK = min(eig(K));
if min_eigB < 1 || min_eigK < 0,
    eigB = eig(B)
    eigK = eig(K)
end
b = W*latent_f + dlogpYf;
a = b - sqrtW*(L'\(L\(sqrtW*K*b)));

a_mat(:,count) = a;
step(:,count) = zeros(numPoints,1);
latent_f = K*a;

%update parameters with optimised latent_f that will be used 
%for estimation of marginal likelihood and its gradients 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%Probit function%%%%%%%%%%%%%%%%%%%%%%
cdf = normcdf(Y.*latent_f);
pdf = normpdf(latent_f);
logpYf = log(cdf);
logpYf = sum(logpYf);
dlogpYf =( Y.*pdf)./ cdf;
d2logpYf = - (Y.*Y.*pdf.*pdf)./(cdf.*cdf) - (Y.*latent_f.*pdf)./cdf;
d3logpYf  = (3.*Y.*Y.*pdf.*pdf.*latent_f)./(cdf.*cdf) + (2.*Y.*Y.*Y.*pdf.*pdf.*pdf - Y.*pdf.*(1 - latent_f.*latent_f))./(cdf.*cdf.*cdf);
%%%%%%%%%%%%%%%%%%%%%%%%%% Logistic function%%%%%%%%%%%%%%%%%%%%%
%without correction!!!!!!!!
%pii = 1./(1+exp(-latent_f));
%dlogpYf = ti - pii;
%d2logpYf = -pii.*(1 - pii);
%d3logpYf = pii.*(2.*pii - 1).*(1 - pii);

%W = - diag(d2logpYf);
%sqrtW = sqrtm(W);
%B = eye(numPoints) + sqrtW*K*sqrtW;
%L = chol (B,'lower');
%b = W*latent_f + dlogpYf;
%a = b - sqrtW*(L'\(L\(sqrtW*K*b)));

% with corrections!!!!!!!!!!!
%yf = Y.*latent_f; s = -yf;
%    ps   = max(0,s); 
%    logpYf = -(ps+log(exp(-ps)+exp(s-ps))); 
%    logpYf = sum(logpYf);
%    s   = min(0,latent_f); 
%    p   = exp(s)./(exp(s)+exp(s-latent_f));                    % p = 1./(1+exp(-f))
%    dlogpYf = (Y+1)/2-p;                          % derivative of log likelihood                         % 2nd derivative of log likelihood
%    d2logpYf = -exp(2*s-latent_f)./(exp(s)+exp(s-latent_f)).^2;
%   d3logpYf = 2*d2logpYf.*(0.5-p);
%    obj = logpYf - (1/2)*a'*latent_f ;
%    obj_mat(count) = obj;
%    change = obj_mat(count) - obj_mat(count - 1);
%    obj_grad = dlogpYf - K'*latent_f;


% Log marginal likelihood and its gradients w.r.t. hyperparameters
logqYX = -a'*latent_f/2 - sum(log(diag(L))) + logpYf;
R = sqrtW*(L'\(L\sqrtW));
C = L\(sqrtW*K);
s2 = -diag(diag(K) - diag(C'*C))/2 * d3logpYf;

%negative marginal likelihood and its gradients
fval = -logqYX; gradient = [];
if ind(1) == 1,
    s1 = (1/2)*a'*dKdl*a - (1/2)*trace(R*dKdl);
    beta = dKdl*dlogpYf;
    s3 = beta - K*R*beta;
    dlogp_dl = s1 + s2' * s3;
    dlogp_dl = dlogp_dl*exp_l;
    gradient = [gradient -dlogp_dl];
end
if ind(2) == 1,
        s1 = (1/2)*a'*dKdf*a - (1/2)*trace(R*dKdf);
    beta = dKdf*dlogpYf;
    s3 = beta - K*R*beta;
    dlogp_df = s1 + s2' * s3;
    dlogp_df = dlogp_df*exp_sigma_f;
    gradient = [gradient -dlogp_df];
end
if ind(3) == 1,
    s1 = (1/2)*a'*dKdw*a - (1/2)*trace(R*dKdw);
    beta = dKdw*dlogpYf;
    s3 = beta - K*R*beta;
    dlogp_dw = s1 + s2' * s3;
    dlogp_dw = dlogp_dw*exp_f;
    gradient = [gradient -dlogp_dw];
end


