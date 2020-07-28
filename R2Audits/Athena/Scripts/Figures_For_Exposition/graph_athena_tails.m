% This script graphs the Athena tails in the first round
%---
% Required input is
%       p: winner fraction
%       n1: size of first draw
%       k1: winner ballots in sample
%---

%----Input
p = 0.75; % Announced winner fraction
n1 = 50; % Ballots drawn in round 1
k1 = 32; % winner ballots in sample

%----Computations
margin = 2*p-1;

%----Begin graphs

% Name colors
maroon = [0.5 0 0];
navy = [0 0 0.5];
dull_green = [0 0.6 0];

% Binomial for the announced election 
first_plot = plot((0:n1), binopdf((0:n1),n1,p), 'Color', navy, 'LineWidth', 3);
hold
% Binomial for a tie
second_plot = plot((0:n1), binopdf((0:n1),n1,0.5), '--', ...
    'Color', maroon, 'LineWidth', 3)

% Draw vertical line at k1 and label it
xl = xline(k1, '-.', {sprintf('k1=%d', k1)});
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Draw corresponding horizontal lines where vertical line crosses each of 
% the two curves and label
yl1 = yline(binopdf(k1,n1,p), ':', ...
    {sprintf('Prob(k1 = %d | margin = %1.1f) = %1.4f', k1, margin, binopdf(k1,n1,p))});
yl1.LineWidth=2;
yl1.FontSize=14;
yl1.LabelHorizontalAlignment='left';

yl2 = yline(binopdf(k1,n1,0.5), ':', ...
    {sprintf('Prob(k1 = %d | margin = 0) = %1.4f', k1, binopdf(k1,n1,0.5))});
yl2.LineWidth=2;
yl2.FontSize = 14;
yl2.LabelHorizontalAlignment='left';

% Label axes
xlabel('Number of winner ballots in first round', 'FontSize', 14)
ylabel('Probability', 'FontSize', 14)
title(sprintf('Probability as a function of winner ballots; sample size = %d', n1), 'FontSize', 16) 

% Color tails
patch_label1 = patch([(k1:n1), fliplr((k1:n1))], ...
    [binopdf((k1:n1),n1,p), fliplr(zeros(1,n1-k1+1))], navy, 'FaceAlpha', 0.25);
patch_label2 = patch([(k1:n1), fliplr((k1:n1))], ...
    [binopdf((k1:n1),n1,0.5), fliplr(zeros(1,n1-k1+1))], maroon);

% Legend
legend(vertcat(first_plot, second_plot, patch_label1, patch_label2), ...
    sprintf('Election with margin = %1.1f', margin), 'Tied election', ...
    sprintf('Prob(k1 >= %d | margin = %1.1f) = %1.4f', k1, margin, 1-binocdf(k1-1,n1,p)), ...
    sprintf('Prob(k1 >= %d | margin = 0) = %1.4f', k1, 1-binocdf(k1-1,n1,0.5)), ...
    'Location', 'NorthWest', 'FontSize', 14)

