% This script graphs the Athena pvalues in the first round
%---
% Required input is
%       p: winner fraction
%       n1: size of first draw
%       alpha: risk limit
%---

%----Input
p = 0.75; % Announced winner fraction
n1 = 50; % Ballots drawn in round 1
alpha = 0.1;

%----Computations
margin = 2*p-1;

% For Minerva kmin
% Function outputs n1 if it is a round size with a non-zero probability of 
% stopping, and the corresponding kmin. 
% StopSched and RiskSched are the stopping probability and risk 
% respectively of the round (the area of the lopped-off tails). 
% CurrentTierStop and CurrentTierRisk are the lopped probability
% distributions. 
[n_out, kmin_minerva, StopSched, RiskSched, CurrentTierStop, ...
    CurrentTierRisk] = Athenakmin(margin, alpha, 1.0, (n1), 'Minerva');

% Chose to begin at one less than kmin 
begin_from = floor(kmin_minerva-1); 
end_at = min(ceil(n1-0.04*n1), n1-1); 
k = (begin_from:end_at);
% pvalue_bravo = binopdf((begin_from:end_at), n1, 0.5)./...
%    binopdf((begin_from:end_at), n1, p); 
pvalue_minerva = (1-binocdf((begin_from-1:end_at-1), n1, 0.5))./...
    (1-binopdf((begin_from-1:end_at-1), n1, p)); 

%----Begin graph

% Name colors
maroon = [0.5 0 0];
navy = [0 0 0.5];
dull_green = [0 0.6 0];
dull_orange = [0.8, 0.3, 0];

% Bravo p-value 
% first_plot = plot((begin_from:end_at), pvalue_bravo, ...
%    'Color', dull_green, 'LineWidth', 3);
% hold
% Minerva p-value
second_plot = plot((begin_from:end_at), pvalue_minerva, '-*', ...
    'Color', dull_orange, 'LineWidth', 3);
hold

% Draw horizontal line at risk limit and label
yl1 = yline(alpha, ':', {sprintf('Risk limit = %1.4f', alpha)});
yl1.LineWidth=2;
yl1.FontSize=14;
yl1.LabelHorizontalAlignment='left';

% Label axes
xlabel('Number of winner ballots in first round', 'FontSize', 14)
ylabel('p-value', 'FontSize', 14)
title('Minerva p-value as a function of winner ballots', 'FontSize', 16) 

% Legend
legend(vertcat(second_plot), 'Minerva p-value', ...
    'Location', 'NorthEast', 'FontSize', 14)
