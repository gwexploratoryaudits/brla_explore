% This script graphs a close-up of the Bravo tails in the second round. 
%---
% Required input is
%       x: winner fraction
%       n1: size of first draw
%       k1: winner ballots in round 1
%       alpha: risk limit
%       n2: size of the second draw (new ballots drawn)
%       k2: winner ballots drawn in round 2
%---

%----Input
x = 0.75; % Announced winner fraction
n1 = 50; % Ballots drawn in round 1
k1 = 30;
alpha = 0.1; % risk limit
n2 = 50; % Ballots drawn in round 2
k2 = 34;

%----Computations
margin = 2*x-1;
ntotal = n1+n2;
ktotal = k1+k2;

% For Bravo kmin, first round.
% Function outputs slope and intercept of straight line kmin as a 
% function of round size n. Both kmin and n are vectors, such that 
% kmin(j) is the kmin value for n(j). The vectors go upto a maximum 
% round size of 6*ASN. They begin at the smallest round size for which a
% decision to stop has non-zero probability. 
[kmslope, kmintercept, n, kmin] = B2BRAVOkmin(margin, alpha);
kmin_bravo = kmin(n==n1);

% Largest k value after second draw
k2_max = kmin_bravo-1+n2;

% Compute distribution at end of first round.
% Binomials with the tails cut off from kmin onward.
CurrentTierStop = binopdf((0:kmin_bravo-1), n1, x);
CurrentTierRisk = binopdf((0:kmin_bravo-1), n1, 0.5);

% Convolution of distribution with binomial for second draw.
% R2CurrentTier computes the convolution of CurrentTierStop 
% with binomial for draw of size n2, from a distribution 
% characterized by margin. 
NewTierStop = R2CurrentTier(margin, CurrentTierStop, n2);
NewTierRisk = R2CurrentTier(0, CurrentTierRisk, n2);

%----Begin plots.

% Somewhat arbitrary choice of what part of tail to display. 
% Chose to begin 2% to the left of the total number of winner ballots
% drawn.
begin_from = floor(ktotal - 0.02*ntotal); 

% Recall that matlab indexes arrays beginning at 1.
% So the prob corresponding to k=0 is NewTierStop(1).
first_plot = plot((begin_from:k2_max),NewTierStop(begin_from+1:k2_max+1), ...
    'b', (begin_from:k2_max), NewTierRisk(begin_from+1:k2_max+1), ...
    '--r', 'LineWidth', 3);
hold
axis([begin_from, k2_max, 0, inf]);

% Draw vertical line at ktotal and label it.
xl = xline(ktotal, '-.', {sprintf('Total winner ballots drawn=%d', ktotal)});
xl.LineWidth=1;
xl.FontSize=14;
xl.LabelVerticalAlignment='middle';

% Draw corresponding horizontal lines and label.
% Recall that matlab begins counting indices at 1, so the entry at index 
% 1 is the value at ktotal=0
yl1 = yline(NewTierStop(ktotal+1), ':', ...
    {sprintf('Prob(ktotal = %d and Round 2| margin = %1.1f and BRAVO audit) = %1.4f', ktotal, margin, NewTierStop(ktotal+1))});
yl1.LineWidth=2;
yl1.FontSize=14;
yl1.LabelHorizontalAlignment='left';

yl2 = yline(NewTierRisk(ktotal+1), ':', ...
    {sprintf('Prob(ktotal = %d and Round 2| margin = 0 and BRAVO audit) = %1.4f', ktotal, NewTierRisk(ktotal+1))});
yl2.LineWidth=2;
yl2.FontSize = 14;
yl2.LabelHorizontalAlignment='left';

% Label axes.
xlabel(sprintf('Number of winner ballots after second draw, BRAVO; round schedule = [%d, %d]', n1, n2), 'FontSize', 14)
ylabel('Probability', 'FontSize', 14)
title('Probability as a function of winner ballots', 'FontSize', 16) 

% Color tails.
patch_label1 = patch([(ktotal:k2_max), fliplr((ktotal:k2_max))], ...
    [NewTierStop(1, ktotal+1:k2_max+1), fliplr(zeros(1, k2_max-ktotal+1))], 'b', 'FaceAlpha', 0.25);
patch_label2 = patch([(ktotal:k2_max), fliplr((ktotal:k2_max))], ...
    [NewTierRisk(1, ktotal+1:k2_max+1), fliplr(zeros(1, k2_max-ktotal+1))], 'r');

% Legend.
legend(vertcat(first_plot, patch_label1, patch_label2), ...
    sprintf('Election with margin = %1.1f', margin), 'Tied election', ...
    sprintf('Prob(winner ballots >= %d and second round | margin = %1.1f and BRAVO audit) = %1.4f', ...
    ktotal, margin, sum(NewTierStop(ktotal+1:k2_max+1))), ...
    sprintf('Prob(winner ballots >= %d  and second round | margin = 0 and BRAVO audit) = %1.4f', ... 
    ktotal, sum(NewTierRisk(ktotal+1:k2_max+1))), ...
    'Location', 'NorthWest', 'FontSize', 14)

