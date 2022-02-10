% interface script for ith round of Minerva 2.0. 
% Set i=0 and then begin script. 
i = i+1;
n_in(i)= input('Total relevant ballots drawn: ');
k_all(i)= input('Total winner ballots drawn: ');

% If this is the first round, need audit parameters
if i == 1
    % insert parameters of choice
    fprintf('This is the first round of the audit, enter audit parameters \n')
    margin = input('Margin as a fraction: ');
    alpha = input('Risk limit, alpha, as a fraction: ');

    % Initialization parameters below are fixed
    currently_drawn_ballots = 0;
    current_k = 0;
    current_sigma = 1;
end

fprintf('This is round %d of the audit, enter stopping probability \n', i)
sp(i) = input('Next round stopping prob as a fraction: ');

this_draw = n_in(i)-currently_drawn_ballots;
this_k = k_all(i)-current_k;
CurrentTierStop = binopdf(0:this_draw,this_draw, 0.5*(1+margin));
CurrentTierRisk = binopdf(0:this_draw,this_draw, 0.5);
StopSched = (0);
RiskSched = (0);

% Compute tail and likelihood ratios (tail ratio is pvalue for first 
% round Minerva)
[tail_ratio(i), LR(i)] = p_value(margin, StopSched, RiskSched, ...
    CurrentTierStop, CurrentTierRisk, this_draw, this_k, 'Minerva');

pvalue(i) = tail_ratio(i)*current_sigma;
sigma(i) = current_sigma/LR(i);
    
currently_drawn_ballots = n_in(i);
current_k = k_all(i);
current_sigma = sigma(i);

fprintf('Margin = %f, alpha = %f \n', margin, alpha);
fprintf('Most recently drew %d ballots \n', this_draw);
for j=1:i
    fprintf('%d. Round size: %d, winner ballots: %d, pvalue: %f, LR: %f, sigma: %f \n', j, n_in(j), k_all(j), pvalue(j), LR(j), sigma(j));
end

if pvalue(i) >= alpha
   [next_draws(i), ~, ~, ~, ~]  = NextRoundSize(margin, alpha/current_sigma, [], (0), (0), (1), (1), 0, 0, (sp(i)), 500, 0.0001);
else
    next_draws(i) = 0;
end

for j=1:i
    fprintf('next draw: %d \n', next_draws(j));
end

for j=1:i
    fprintf('next round: %d \n', n_in(j)+next_draws(j));
end