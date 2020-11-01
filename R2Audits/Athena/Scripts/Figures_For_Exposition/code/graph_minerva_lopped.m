% This script graphs the lopped off Minerva curves after a first
% round
%---
% Required input is
%       x: winner fraction
%       n1: size of first draw
%       alpha: risk limit
%---

%----Input
x = 0.65; % Announced winner fraction
n1 = 50; % Ballots drawn in round 1
alpha = 0.1; % risk limit

%----Computations
margin = 2*x-1;

% For Minerva kmin
% Function outputs n1 if it is a round size with a non-zero probability of 
% stopping, and the corresponding kmin. 
% StopSched and RiskSched are the stopping probability and risk 
% respectively of the round (the area of the lopped-off tails). 
% CurrentTierStop and CurrentTierRisk are the lopped probability
% distributions. 
[n_out, kmin_minerva, StopSched, RiskSched, CurrentTierStop, ...
    CurrentTierRisk] = Athenakmin(margin, alpha, 1.0, (n1), 'Minerva');

%----Begin plots
% Name colors
maroon = [0.5 0 0];
navy = [0 0 0.5];
dull_green = [0 0.6 0];

% Two curves in one plot for Minerva
% pdfs up to kmin-1, and zeros thereafter.
% Zeros plotted as different plots so the "vertical" (not!) line dropping 
% at kmin is not in the graph.
plot1 = plot((0:kmin_minerva-1), binopdf((0:kmin_minerva-1),n1, x), ...
    'Color', navy, 'LineWidth', 3, ... 
    'DisplayName', sprintf('Election with margin = %1.1f', margin));
hold on;
plot2 = plot((kmin_minerva:n1), zeros(1,n1-kmin_minerva+1), ...
    'Color', navy, 'LineWidth', 3, 'DisplayName', 'BlueZeros');
plot3 = plot((0:kmin_minerva-1), binopdf((0:kmin_minerva-1),n1, 0.5), '--', ...
    'Color', maroon, 'LineWidth', 3, 'DisplayName', 'Tied Election');
plot4 = plot((kmin_minerva:n1), zeros(1,n1-kmin_minerva+1), '--', ...
    'Color', maroon, 'LineWidth', 3, 'DisplayName', 'RedZeros');
hleg = legend('location','NorthWest');
axis([0, n1, 0, inf]);

% Draw vertical line at kmin and label it.
xl = xline(kmin_minerva, '-.', {sprintf('kmin=%d', kmin_minerva)});
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Label axes.
xlabel('Number of winner ballots after testing condition in first round', 'FontSize', 14)
ylabel('Probability', 'FontSize', 14)
title('After testing Minerva condition, round 1', 'FontSize', 16) 

% Delete parts of the legend corresponding to zeros.
hleg = legend([plot1 plot3], 'Location', 'NorthWest');
hleg.FontSize = 14;
