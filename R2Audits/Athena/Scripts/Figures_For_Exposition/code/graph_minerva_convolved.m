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

% For Minerva kmin, first round.
% Function outputs n1 if it is a round size with a non-zero probability of 
% stopping, and the corresponding kmin. 
% StopSched and RiskSched are the stopping probability and risk 
% respectively of the round (the area of the lopped-off tails). 
% CurrentTierStop and CurrentTierRisk are the lopped probability
% distributions. 
[n_out, kmin_minerva, StopSched, RiskSched, CurrentTierStop, ...
    CurrentTierRisk] = Athenakmin(margin, alpha, 1.0, (n1), 'Minerva');

% Largest k value after second draw
k2_max = kmin_minerva-1+n2; 

% Convolution of distributions with binomials for second draw.
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

first_plot = plot((0:k2_max),NewTierStop, 'Color', navy, 'LineWidth', 3);
hold
second_plot = plot((0:k2_max), NewTierRisk, '--', 'Color', maroon, 'LineWidth', 3);
axis([0, k2_max, 0, inf]);

% Legend.
hleg = legend(sprintf('Election with margin = %1.1f', margin), 'Tied election', 'location', 'NorthWest', 'Interpreter', 'latex');
hleg.FontSize = 16;

ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

% Label axes.
xlab = xlabel('Number of winner ballots after second draw', 'Interpreter', 'latex');
xlab.FontSize = 18;

ylab = ylabel('Probability', 'Interpreter', 'latex');
ylab.FontSize = 18;

ti = title(sprintf('Minerva pdfs: round schedule = [%d, %d]', n1, ntotal), 'Interpreter', 'latex'); 
ti.FontSize = 18;

