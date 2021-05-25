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

% Chose to begin a couple values before Minerva kmin 
begin_from = floor(kmin_minerva-3); 
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

axes.FontSize=16;

% Bravo p-value 
first_plot = semilogy((begin_from:end_at), LR_bravo, '-', ...
   'Color', dull_green, 'LineWidth', 3);
hold
second_plot = semilogy((begin_from:end_at), LR_minerva, '--', ...
   'Color', dull_orange, 'LineWidth', 3);

axis([begin_from, end_at, LR_bravo(1), LR_bravo(end_at-begin_from+1)]);

% Draw horizontal line at risk limit inverse and label
yl1 = yline(1/alpha, ':', {sprintf('${\\alpha}^{-1}$ = %1.4f', 1/alpha)}, 'Interpreter', 'latex');
yl1.LineWidth=2;
yl1.FontSize=16;
yl1.LabelHorizontalAlignment='left';

% Draw vertical line at Minerva kmin and label it
xl1 = xline(kmin_minerva, '-.', {sprintf('Minerva $k_{min}$=%d', kmin_minerva)}, 'Interpreter', 'latex');
xl1.LineWidth=1;
xl1.FontSize=16;
xl1.LabelVerticalAlignment='top';

% Compute Bravo kmin, draw vertical line and label
[kmslope, kmintercept, ~, ~] = B2BRAVOkmin(margin, alpha);
kmin_bravo = ceil(kmslope*n1 + kmintercept);

% Draw vertical line at Bravo kmin and label it
xl2 = xline(kmin_bravo, '-.', {sprintf('Bravo $k_{min}$=%d', kmin_bravo)}, 'Interpreter', 'latex');
xl2.LineWidth=1;
xl2.FontSize=16;
xl2.LabelVerticalAlignment='top';

% Color half planes
lim=axis;
y_max = lim(4);
y_min = lim(3);
x_minerva = [kmin_minerva, kmin_minerva, end_at, end_at];
y_minerva = [y_min, y_max, y_max, y_min];
patch_label1 = patch(x_minerva+3, y_minerva, dull_green, 'FaceAlpha', 0.25);
patch_label2 = patch(x_minerva, y_minerva, dull_orange, 'FaceAlpha', 0.25);

ti = title({sprintf('First round Bravo and Minerva ratios for $n_1$ = %d and p = %1.4f', n1, p)}, ...
    'Interpreter', 'latex');
ti.FontSize = 20;

% Legend
leg = legend(vertcat(first_plot, second_plot, patch_label1, patch_label2), ...
    'Bravo likelihood ratio, $\sigma_1$ (log scale)', ...
    'Minerva tail ratio, $\tau_1$ (log scale)', ...
    'Bravo audit stops, $\sigma_1 \geq \alpha^{-1}$', ...
    'Minerva audit stops, $\tau_1 \geq \alpha^{-1}$', ...
    'Interpreter', 'latex');
leg.FontSize = 16;
leg.Location = 'SouthEast'; 

ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

% Label axes
xlab = xlabel('Number of winner ballots in first round, $k_1$', ...
    'Interpreter', 'latex'); 
xlab.FontSize = 18;

ylab = ylabel('$\sigma_1$ or $\tau_1$ (log scale)', ...
    'Interpreter', 'latex');
ylab.FontSize = 18;


