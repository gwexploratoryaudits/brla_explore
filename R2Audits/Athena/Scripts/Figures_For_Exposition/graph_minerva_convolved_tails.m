% This script graphs the lopped off Minerva curves after a first
% round
%---
% Required input is
%       x: winner fraction
%       n1: size of first draw
%       k1: winner ballots in round 1
%       alpha: risk limit
%       n2: size of the second draw (new ballots drawn)
%       k2: winner ballots drawn in round 2
%---

%----Input
x = 0.75; % Announced winner fraction
n1 = 50; % Ballots drawn in round 1
k1 = 30;
alpha = 0.1; % risk limit
n2 = 50; % Ballots drawn in round 2
k2 = 32;

%----Computations
margin = 2*x-1;
ntotal = n1+n2;
ktotal = k1+k2;


% For Minerva kmin, first round
[n_out, kmin_minerva, StopSched, RiskSched, CurrentTierStop, ...
    CurrentTierRisk] = Athenakmin(margin, alpha, 1.0, (n1), 'Minerva');
k2_max = kmin_minerva-1+n2;

% Convolution of distributions with binomials for second draw
NewTierStop = R2CurrentTier(margin, CurrentTierStop, n2);
NewTierRisk = R2CurrentTier(0, CurrentTierRisk, n2);

%----Begin plots
first_plot = plot((0:k2_max),NewTierStop, 'b', (0:k2_max), ...
    NewTierRisk, '--r', 'LineWidth', 3);
hold
axis([0, k2_max, 0, inf]);

% Draw line at ktotal and label it
xl = xline(ktotal, '-.', {sprintf('Total winner ballots drawn=%d', ktotal)});
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Draw corresponding horizontal lines and label
% Recall that matlab begins counting indices at 1, so the entry at index 
% 1 is the value at ktotal=0
yl1 = yline(NewTierStop(ktotal+1), ':', ...
    {sprintf('Prob(ktotal = %d and Round 2| margin = %1.1f and Athena audit) = %1.4f', ktotal, margin, NewTierStop(ktotal+1))});
yl1.LineWidth=2;
yl1.FontSize=10;
yl1.LabelHorizontalAlignment='left';

yl2 = yline(NewTierRisk(ktotal+1), ':', ...
    {sprintf('Prob(ktotal = %d and Round 2| margin = 0 and Athena audit) = %1.4f', ktotal, NewTierRisk(ktotal+1))});
yl2.LineWidth=2;
yl2.FontSize = 10;
yl2.LabelHorizontalAlignment='left';

% Label axes
xlabel('Number of winner ballots after second draw, Minerva', 'FontSize', 14)
ylabel('Probability', 'FontSize', 14)
title(sprintf('Probability as a function of winner ballots; sample size = %d', ntotal), 'FontSize', 16) 

