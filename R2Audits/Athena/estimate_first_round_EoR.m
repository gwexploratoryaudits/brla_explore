function [n_est, kmin, prob_est, kmslope, kmintercept] = estimate_first_round_EoR(margin, alpha, prob)
% n_est = estimate_first_round_EoR(margin, alpha, prob)
% Estimates first round size for EoR, for a very low margin
p = (1+margin)/2;
q = 1-p;

% Find k_a, the max value kmin can take to ensure a probability of
% stopping. Need k_a on the std. normal distribution representing the 
% announced election such that tail(ka) = prob
k_a = norminv(1-prob, 0, 1);

kmslope = (log(0.5) - log(1-p))/(log(p) - log(1-p));
kmintercept = - (log(alpha))/(log(p) - log(1-p)); 

% k_a*sqrt(p*q*n) + p*n is also kmin = kmslope*n + kmintercept
% equating get a quadratic in sqrt(n). Solve for n. 
% (p-kmslope)*n + k_a*sqrt(p*q*n) - kmintercept = 0
est = roots([(p-kmslope), k_a*sqrt(p*q), -kmintercept]);
n_est = ceil(est(1)^2);
kmin = ceil(kmslope*n_est + kmintercept);
prob_est = 1-normcdf(kmin, p*n_est, sqrt(p*q*n_est));
end