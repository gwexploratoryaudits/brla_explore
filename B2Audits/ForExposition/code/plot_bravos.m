function plot_bravos(margin, alpha, N)
% This script graphs the kmins for Bravo and BravoLike (Bravo without
% replacement)
%
% Required input is
%       alpha: risk limit
%       margin: election margin
%       N: election size for Bravolike
%
%---

%----Computations
[~, ~, n1, kmin1] = B2BRAVOkmin(margin, alpha);
[n2, kmin2, ~] = B2BRAVOLikekmin(margin, alpha, N);

%----Plot upto the smaller of the two sizes. It can happen that the smaller
%       value of n is smaller than the first value of other vector n, 
%       hence checking >=
if n1(size(n1,2)) > n2(size(n2,2))
    draws_1 = find((n1>=n2(size(n2,2))),1);
    draws_2 = size(n2,2);
else
    draws_1 = size(n1,2);
    draws_2 = find(n2>=n1(size(n1,2)),1);
end

%----Begin graphs

% Name colors
maroon = [0.5 0 0];
navy = [0 0 0.5];
dull_green = [0 0.6 0];

% Bravo 
plot(n1(1:draws_1), kmin1(1:draws_1), 'Marker', 'o', 'Color', navy, ...
    'LineWidth', 1);
hold
% Bravolike
plot(n2(1:draws_2), kmin2(1:draws_2), 'Marker', '+', 'Color', maroon, ...
    'LineWidth', 1);

% Label axes
xlabel('sample size, n', 'FontSize', 14)
ylabel('kmin', 'FontSize', 14)
title(sprintf('Minimum winner ballots needed to stop audit, margin=%4.1f, risk limit = %4.1f, N = %d', ...
    margin, alpha, N), 'FontSize', 16) 

% Legend
legend('Bravo', 'Bravolike', 'Location', 'NorthWest', 'FontSize', 14);
end

