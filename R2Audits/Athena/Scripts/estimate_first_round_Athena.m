function n_est = estimate_first_round_Athena(margin, alpha, prob)
% n_est = estimate_first_round_Athena(margin, alpha, prob)
% Estimates first round size for Athena and Minerva, for a very low margin
p = (1+margin)/2;
q = 1-p;

% Find k_a, the max value kmin can take to ensure a probability of
% stopping. Need k_a on the std. normal distribution representing the 
% announced election such that tail(ka) = prob
k_a = norminv(1-prob, 0, 1);
mod_prob = normcdf(k_a, 0, 1, 'upper'); % this is the exact value of tail

% At that point, the risk (tail of the tied election) should be at most 
% alpha*tail of announced election
k_b = norminv(1-(alpha*mod_prob), 0, 1);

% On equating the respective values of k on the two different
% distributions, we get: 
n_est = ceil(power((k_b*0.5 - k_a*sqrt(p*q)),2)/power(p-0.5,2));
end