% This script graphs the lopped off Minerva curves after a first
% round
%---
% Required input is
%       x: winner fraction
%       n1: size of first draw
%       alpha: risk limit
%---

%----Input
x = 0.75; % Announced winner fraction
n1 = 50; % Ballots drawn in round 1
alpha = 0.1; % risk limit

%----Computations
margin = 2*x-1;

% For Minerva kmin
[n_out, kmin_minerva, StopSched, RiskSched, CurrentTierStop, ...
    CurrentTierRisk] = Athenakmin(margin, alpha, 1.0, (n1), 'Minerva');

%----Begin plots
% Two curves in one plot for Minerva
% Zeros plotted as different plots so the vertical line dropping at 
% kmin is not in the graph (because it isn't vertical)
plot1 = plot((0:kmin_minerva-1), binopdf((0:kmin_minerva-1),n1, x), 'b', ...
    'LineWidth', 3, ... 
    'DisplayName', sprintf('Election with margin = %1.1f', margin));
hold on;
plot2 = plot((kmin_minerva:n1), zeros(1,n1-kmin_minerva+1), 'b', ...
    'LineWidth', 3, 'DisplayName', 'BlueZeros');
plot3 = plot((0:kmin_minerva-1), binopdf((0:kmin_minerva-1),n1, 0.5), '--r', ...
    'LineWidth', 3, 'DisplayName', 'Tied Election');
plot4 = plot((kmin_minerva:n1), zeros(1,n1-kmin_minerva+1), '--r', ...
    'LineWidth', 3, 'DisplayName', 'RedZeros');
hleg = legend('location','NorthWest');
axis([0, n1, 0, inf]);

% Draw line at kmin and label it
xl = xline(kmin_minerva, '-.', {sprintf('kmin=%d', kmin_minerva)});
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Label axes
xlabel('Number of winner ballots after testing condition in first round', 'FontSize', 14)
ylabel('Probability', 'FontSize', 14)
title('After testing Minerva condition, round 1', 'FontSize', 16) 

% Delete parts of the legend
hleg = legend([plot1 plot3], 'Location', 'NorthWest')
hleg.FontSize = 14;
