% This script graphs the lopped off Minerva curves after a first
% round

%----Input
x = 0.75; % Announced winner fraction
n1 = 50; % Ballots drawn in round 1

%----Computations
margin = 2*x-1;

% For Minerva kmin
[n_out, kmin_minerva, StopSched, RiskSched, CurrentTierStop, ...
    CurrentTierRisk] = Athenakmin(0.5, 0.1, 1.0, (50), 'Minerva');

% Two curves in one plot for Minerva
plot((0:n1), [binopdf((0:kmin_minerva-1),n1, 0.75), zeros(1,n1-kmin_minerva+1)], 'b', ...
    (0:n1), [binopdf((0:kmin_minerva-1),n1,0.5), zeros(1,n1-kmin_minerva+1)], ...
    '--r', 'LineWidth', 3);
hold

axis([0, 50, 0, inf]);

% Draw line at kmin and label it
xl = xline(kmin_minerva, '-.', {sprintf('kmin=%d', kmin_minerva)});
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Label axes
xlabel('Number of winner ballots after testing condition in first round', 'FontSize', 14)
ylabel('Probability', 'FontSize', 14)
title('After testing Minerva condition, round 1', 'FontSize', 16) 

% Legend
legend(sprintf('Election with margin = %1.1f', margin), 'Tied election', ...
    'Location', 'NorthWest', 'FontSize', 14)

