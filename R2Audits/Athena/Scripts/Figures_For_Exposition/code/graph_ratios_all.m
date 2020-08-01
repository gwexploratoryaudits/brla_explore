% This script graphs the Bravo Likelihood Ratios in the first round
%---
% Required input is
%       p: winner fraction
%       n1: size of first draw
%       alpha: risk limit
%       k1: sample winner votes
%---

%----Input
p = 0.75; % Announced winner fraction
n1 = 50; % Ballots drawn in round 1
alpha = 0.1; % risk limit
k1 = 32;

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

% Chose to begin at Minerva kmin 
begin_from = floor(kmin_minerva-1); 
end_at = min(ceil(n1-0.2*n1), n1-1); 
k = (begin_from:end_at);
LR_bravo = binopdf((begin_from:end_at), n1, p)./binopdf((begin_from:end_at), n1, 0.5); 
LR_minerva = (1-binopdf((begin_from-1:end_at-1), n1, p))./(1-binocdf((begin_from-1:end_at-1), n1, 0.5));
%----Begin graph

% Name colors
maroon = [0.5 0 0];
navy = [0 0 0.5];
dull_green = [0 0.6 0];
dull_orange = [0.8, 0.3, 0];

axes.FontSize=12;

% Bravo p-value 
first_plot = semilogy((begin_from:end_at), LR_bravo, '-', ...
   'Color', dull_green, 'LineWidth', 3);
hold
second_plot = semilogy((begin_from:end_at), LR_minerva, '--', ...
   'Color', dull_orange, 'LineWidth', 3);

% Draw horizontal line at risk limit inverse and label
yl1 = yline(1/alpha, ':', {sprintf('${\\alpha}^{-1}$ = %1.4f', 1/alpha)}, 'Interpreter', 'latex');
yl1.LineWidth=2;
yl1.FontSize=14;
yl1.LabelHorizontalAlignment='left';

% Draw vertical line at k1 and label it
xl = xline(k1, '-.', {sprintf('$k_1$=%d', k1)}, 'Interpreter', 'latex');
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Draw corresponding horizontal lines where vertical line crosses each of 
% the two curves and label
yl1 = yline(LR_minerva(k1-begin_from+1), ':', ...
    {sprintf('$\\tau _1$ = %1.4f', ...
    LR_minerva(k1-begin_from+1))}, 'Interpreter', 'latex');
yl1.LineWidth=2;
yl1.FontSize=14;
yl1.LabelHorizontalAlignment='left';

yl2 = yline(LR_bravo(k1-begin_from+1), ':', ...
    {sprintf('$\\sigma(%d, %1.4f, %d)$ = %1.4f', ...
    k1, p, n1, LR_bravo(k1-begin_from+1))}, 'Interpreter', 'latex');
yl2.LineWidth=2;
yl2.FontSize = 14;
yl2.LabelHorizontalAlignment='left';


% Label axes
xlabel('Number of winner ballots in first round, $k_1$', ...
    'FontSize', 14, 'Interpreter', 'latex')
ylabel('$\sigma$ or $\tau_1$ (log scale)', 'FontSize', 14, ...
    'Interpreter', 'latex')
title({sprintf('First round Bravo and Minerva ratios for $n_1$ = %d and p = %1.4f', n1, p)}, ...
    'FontSize', 16, 'Interpreter', 'latex') 

% Legend
legend(vertcat(first_plot, second_plot), ...
    'Bravo likelihood ratio, $\sigma$ (log scale)', ...
    'Minerva tail ratio, $\tau_1$ (log scale)', ...
    'Location', 'NorthWest', 'FontSize', 14, 'Interpreter', 'latex')


