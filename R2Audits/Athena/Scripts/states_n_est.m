% very basic script to compute Athena first round values for a single state
% also comparing to Filip's
% for very small margins (round sizes at least 10000)
% 10: Florida; 24: Minnesota; 39: Pennsylvania; 30: NH; 50: Wisconsin 
% 23: Michigan; 

% read previous file of the states
fname='2016_one_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);

i=23;
total_ballots = election_results.(states{i}).contests.presidential.ballots_cast;
total_relevant_ballots = sum(election_results.(states{i}).contests.presidential.results);
margin = abs(election_results.(states{i}).contests.presidential.margin);
factor = total_ballots/total_relevant_ballots;
prob = 0.9;
alpha = 0.1;

% n_est = estimate_first_round_Athena(margin, alpha, prob)
% Estimates first round size for Athena and Minerva, for a very low margin
p = (1+margin)/2;
q = 1-p;

% Find k_a, the max value kmin can take to ensure a probability of
% stopping. Need k_a on the std. normal distribution representing the 
% announced election such that tail(k_a) = prob
k_a = norminv(1-prob, 0, 1);
mod_prob = normcdf(k_a, 0, 1, 'upper'); % this is the exact value of tail

% At that point, the risk (tail of the tied election) should be at most 
% alpha*tail of announced election
k_b = norminv(1-(alpha*mod_prob), 0, 1);

% On equating the respective values of k on the two different
% distributions, we get: 
% k_a*sqrt(p*q)*sqrt(n) + n*p = k_b*0.5*sqrt(n) + 0.5*n
% or: 
% n_est1 = ceil(power((k_b*0.5 - k_a*sqrt(p*q)),2)/power(p-0.5,2))
%
% allowing the two to differ by one, with k_a representing the larger 
% value, we get: 
% k_a*sqrt(p*q)*sqrt(n) + n*p = k_b*0.5*sqrt(n) + 0.5*n + 1
% or
% (p-0.5)x^2 + (k_a*sqrt(p*q) - k_b*0.5)x - 1 = 0
% which is: 
% x = (k_b*0.5 - k_a*sqrt(p*q)) + sqrt[(k_b*0.5 - k_a*sqrt(p*q))^2 +
% 4*(p-0.5)]/2*(p-0.5)
% 
% we get: 
n_est1 = ceil(power((k_b*0.5 - k_a*sqrt(p*q)),2)/power(p-0.5,2))

n_est2 = ceil(( (k_b*0.5 - k_a*sqrt(p*q)) + ...
    sqrt((k_b*0.5 - k_a*sqrt(p*q))^2 + 4*(p-0.5)))/(2*(p-0.5)));

n_est2 = n_est2^2

k_max1 = floor(k_a*sqrt(p*q)*sqrt(n_est1) + p*n_est1);
k_min1 = ceil(k_b*0.5*sqrt(n_est1) + 0.5*n_est1);

k_max2 = floor(k_a*sqrt(p*q)*sqrt(n_est2) + p*n_est2);
k_min2 = ceil(k_b*0.5*sqrt(n_est2) + 0.5*n_est2);

count = 0;
for n = 1241826:n_est2
    k_max = binoinv(1-prob,n,p)-1;
    if 1-binocdf(k_max,n,p) >= prob && alpha*(1-binocdf(k_max,n,p)) >= ...
            1-binocdf(k_max,n,0.5) && k_max >= log(0.5/q)/log(p/q)
        count = count +1;
    else
        count = 0; % restart counting
    end
    if count == 100
        break
    end
end
election_results.(states{i}).contests.presidential.Athena_pv_raw = n-count+1;
election_results.(states{i}).contests.presidential.Athena_pv_scaled = ceil(factor*(n-count+1));

count
n-count+1

% filip's count
fname2='2016_one_round_athena.json';
Athena_rounds = jsondecode(fileread(fname2));
tests = fieldnames(Athena_rounds);
for i=1:size(tests,1)
    fz(i) = Athena_rounds.(tests{i}).expected.round_candidates;
end

% the states are not in the same order as the states file and rather than 
% bother, simply swap them around. Put Maine and Nebraska (Nevada?) in 
% their correct positions. 
fz_fixed = fz(:,[1:19, 50, 20:26, 51, 27:49]);

% Write Filip's Athena values to our structure
election_results.(states{i}).contests.presidential.Athena_fz = fz_fixed(i);

% Write all these into the original file. 
txt = jsonencode(election_results);
fname3 = '2016_one_round_all.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);


