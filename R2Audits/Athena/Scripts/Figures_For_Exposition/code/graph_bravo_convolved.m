% This script graphs the convolution of lopped-off curve from first round
% with a fresh draw for the second. 
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

% For Bravo kmin, first round.
% Function outputs slope and intercept of straight line kmin as a 
% function of round size n. Both kmin and n are vectors, such that 
% kmin(j) is the kmin value for n(j). The vectors go upto a maximum 
% round size of 6*ASN. They begin at the smallest round size for which a
% decision to stop has non-zero probability. 
[kmslope, kmintercept, n, kmin] = B2BRAVOkmin(margin, alpha);
kmin_bravo = kmin(n==n1);
k2_max = kmin_bravo-1+n2;

% Compute distribution at end of first round.
% Binomials with the tails cut off from kmin onward.
CurrentTierStop = binopdf((0:kmin_bravo-1), n1, x);
CurrentTierRisk = binopdf((0:kmin_bravo-1), n1, 0.5);

% Convolution of distribution with binomial for second draw.
% R2CurrentTier computes the convolution of CurrentTierStop 
% with binomial for draw of size n2, from a distribution 
% characterized by margin. 
NewTierStop = R2CurrentTier(margin, CurrentTierStop, n2);
NewTierRisk = R2CurrentTier(0, CurrentTierRisk, n2);

%----Begin plots.
% Name colors
maroon = [0.5 0 0];
navy = [0 0 0.5];
dull_green = [0 0.6 0];

first_plot = plot((0:k2_max), NewTierStop, 'Color', navy, 'LineWidth', 3);
hold
second_plot= plot((0:k2_max), NewTierRisk, '--', 'Color', maroon, 'LineWidth', 3);
axis([0, k2_max, 0, inf]);

% Label axes.
xlabel(sprintf('Number of winner ballots after second draw, BRAVO; round schedule = [%d, %d]', n1, ntotal), 'FontSize', 14)
ylabel('Probability', 'FontSize', 14)
title('Probability as a function of winner ballots', 'FontSize', 16) 

% Legend.
hleg = legend(sprintf('Election with margin = %1.1f', margin), 'Tied election', 'location', 'NorthWest');
hleg.FontSize = 14;