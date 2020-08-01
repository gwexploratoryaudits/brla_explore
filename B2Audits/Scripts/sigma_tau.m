% This script computes p-values of B2 Minerva and B2 Bravo

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

plot(sigma)
hold
plot(tau)

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

plot(sigma_new)
plot(tau_new)

