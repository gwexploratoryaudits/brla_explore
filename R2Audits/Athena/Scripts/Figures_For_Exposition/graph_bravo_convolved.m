% This script graphs the lopped off Minerva curves after a first
% round
%---
% Required input is
%       x: winner fraction
%       n1: size of first draw
%       alpha: risk limit
%       n2: size of the second draw (new ballots drawn)
%---

%----Input
x = 0.75; % Announced winner fraction
n1 = 50; % Ballots drawn in round 1
alpha = 0.1; % risk limit
n2 = 50; % Ballots drawn in round 2

%----Computations
margin = 2*x-1;
ntotal = n1+n2;

% For Bravo kmin, first round
[kmslope, kmintercept, n, kmin] = B2BRAVOkmin(margin, alpha);
kmin_bravo = kmin(n==n1);
k2_max = kmin_bravo-1+n2;

% Compute distribution at end of first round
CurrentTierStop = binopdf((0:kmin_bravo-1), n1, x);
CurrentTierRisk = binopdf((0:kmin_bravo-1), n1, 0.5);

% Convolution of distributions with binomials for second draw
NewTierStop = R2CurrentTier(margin, CurrentTierStop, n2);
NewTierRisk = R2CurrentTier(0, CurrentTierRisk, n2);

%----Begin plots
first_plot = plot((0:k2_max),NewTierStop, 'b', (0:k2_max), ...
    NewTierRisk, '--r', 'LineWidth', 3);
hold
axis([0, k2_max, 0, inf]);

% Label axes
xlabel(sprintf('Number of winner ballots in second round BRAVO; round schedule = [%d, %d]', n1, n2), 'FontSize', 14)
ylabel('Probability', 'FontSize', 14)
title('Probability as a function of winner ballots', 'FontSize', 16) 

% Legend
legend(sprintf('Election with margin = %1.1f', margin), 'Tied election', 'location', 'NorthWest');