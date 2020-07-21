% This script graphs the lopped off BRAVO curves after a first
% round

%----Input
x = 0.75; % Announced winner fraction
n1 = 50; % Ballots drawn in round 1

%----Computations
margin = 2*x-1;

% For bravo kmin
[kmslope, kmintercept, n, kmin] = B2BRAVOkmin(0.5, 0.1);
kmin_bravo = kmin(n==n1);

% Two curves in one plot for BRAVO
plot((0:n1), [binopdf((0:kmin_bravo-1),n1, 0.75), zeros(1,n1-kmin_bravo+1)], 'b', ...
    (0:n1), [binopdf((0:kmin_bravo-1),n1,0.5), zeros(1,n1-kmin_bravo+1)], ...
    '--r', 'LineWidth', 3);
hold

axis([0, 50, 0, inf]);

% Label axes
xlabel('Number of winner ballots after testing condition in first round', 'FontSize', 14)
ylabel('Probability', 'FontSize', 14)
title('After testing BRAVO condition, round 1', 'FontSize', 16) 

% Legend
legend(sprintf('Election with margin = %1.1f', margin), 'Tied election', ...
    'Location', 'NorthWest', 'FontSize', 14)

