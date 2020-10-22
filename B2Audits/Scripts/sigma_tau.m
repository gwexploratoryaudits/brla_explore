% This script computes p-values of B2 Minerva and B2 Bravo
% First a round size of n(1), where n(1) is the minimum 
% number of ballots needed for B2 Bravo to stop. We observe that, while 
% the p-values are different till n(1), at n(1) they are the same and 
% both B2-Minerva and B2-Bravo stop. 
% 
% Next we see how everything changes when a new ballot is drawn. 
% Note that, for the previous round of size n(1), kmin=n(1). Hence, after 
% a new ballot is drawn, the max number of winner ballots is still n(1). 
% As expected, Minerva p-value is no smaller than Bravo p-value. 

alpha = 0.1;
p = 0.75;

% Computations
margin = 2*p-1;

[kmslope, kmintercept, n, kmin] = B2BRAVOkmin(margin, alpha);

CurrentTierStop = binopdf(0:n(1), n(1), p);
CurrentTierRisk = binopdf(0:n(1), n(1), 0.5);

sigma = CurrentTierStop./CurrentTierRisk;

cdf_stop = CumDistFunc(CurrentTierStop);
cdf_risk = CumDistFunc(CurrentTierRisk);

tau(1)=1;

for i=2:n(1)+1
 tau(i) = (1-cdf_stop(i-1))/(1-cdf_risk(i-1));
end

plot(sigma, '+-', 'LineWidth', 2)
hold on
plot(tau, 'o-', 'LineWidth', 2)
title('Round 1', 'FontSize', 16)
legend('Bravo sigma', 'Minerva tau', 'FontSize', 14)

NewTierStop(1) = (1-p)*CurrentTierStop(1);
NewTierRisk(1) = 0.5*CurrentTierRisk(1);

NewTierStop(n(1)+1) = p*CurrentTierStop(n(1));
NewTierRisk(n(1)+1) = 0.5*CurrentTierRisk(n(1));

for i=2:n(1)
NewTierStop(i) = (1-p)*CurrentTierStop(i) + p*CurrentTierStop(i-1);
NewTierRisk(i) = 0.5*CurrentTierRisk(i) + 0.5*CurrentTierRisk(i-1);
end

sigma_new = NewTierStop./NewTierRisk;

cdf_stop_new = CumDistFunc(NewTierStop);
cdf_risk_new = CumDistFunc(NewTierRisk);

tau_new(1)=1;

for i=2:n(1)+1
 tau_new(i) = (1-cdf_stop_new(i-1))/(1-cdf_risk_new(i-1));
end

hold off 
figure
plot(sigma_new, '+-', 'LineWidth', 2)
hold on
plot(tau_new, 'o-', 'LineWidth', 2)
title('Round 2: One More Ballot', 'FontSize', 16)
legend('Bravo sigma', 'Minerva tau', 'FontSize', 14)

