% script for ith round. Set i=0 and then begin script. 
i = i+1;
n_in(i)= input('Total relevant ballots drawn: ');
k_all(i)= input('Total winner ballots drawn: ');

if i == 1
    % insert parameters of choice
    fprintf('This is the first round of the audit, enter audit parameters \n')
    margin = input('Margin as a fraction: ');
    alpha = input('Risk limit, alpha, as a fraction: ');
    delta= input('delta value for Athena: ');
    audit_method = input('audit method as a string: ');
    % parameters below are fixed
    currently_drawn_ballots = 0;
    CurrentTierStop = (1);
    CurrentTierRisk = (1);
    StopSched = (0);
    RiskSched = (0);
end

this_draw = n_in(i)-currently_drawn_ballots;

% Generate winning vote distributions for each hypothesis
CurrentTierStop = R2CurrentTier(margin,CurrentTierStop,this_draw);
CurrentTierRisk = R2CurrentTier(0,CurrentTierRisk,this_draw);

% Compute pvalues and likelihood ratios
[pvalue(i), LR(i)] = p_value(margin, StopSched, RiskSched, ...
    CurrentTierStop, CurrentTierRisk, n_in(i), k_all(i), audit_method);

% Compute kmin
if strcmp(audit_method,'Arlo')
    [~, ~, ~, kmin(i)] = R2BRAVOkmin(margin, alpha, n_in(i));
    if kmin(i) == [] % round not large enough for decision
        kmin(i) = n_in(i)+1;
    end
else
    kmin(i) = AthenaNextkmin(margin, alpha, delta, StopSched, RiskSched, ...
        CurrentTierStop, CurrentTierRisk, n_in(i), audit_method);
end

if kmin(i) <= n_in(i)
    % Round is large enough for  non-zero stopping probbaility. Compute 
    % tails for each hypothesis at kmin
    StopSched(i) = sum(CurrentTierStop(kmin(i)+1:size(CurrentTierStop,2)));
    RiskSched(i) = sum(CurrentTierRisk(kmin(i)+1:size(CurrentTierRisk,2)));
    % Compute new distribution for a kmin decision
    CurrentTierStop = CurrentTierStop(1:kmin(i));
    CurrentTierRisk = CurrentTierRisk(1:kmin(i));
end
currently_drawn_ballots = n_in(i);

fprintf('Margin = %f, alpha = %f, delta = %f, audit type = %s \n', margin, alpha, delta, audit_method);
fprintf('Most recently drew %d ballots \n', this_draw);
for j=1:i
    fprintf('%d. Round size: %d, winner ballots: %d, kmin: %d, pvalue: %f, LR: %f \n', j, n_in(j), k_all(j), kmin(j), pvalue(j), LR(j));
end



