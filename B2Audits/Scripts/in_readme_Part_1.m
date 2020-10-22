% This runs the examples of the read_me file in B2Audits and plots them
% Part 1: kmins
% Do this before the other parts

% Name colors
maroon = [0.5 0 0];
navy = [0 0 0.5];
dull_green = [0 0.6 0]; 

%---Computing a single Bravo audit
[~, ~, n1, kmin1] = B2BRAVOkmin(0.4, 0.1);

%---Computing a single BravoLike audit
[n2, kmin2, ~] = B2BRAVOLikekmin(0.4, 0.1, 200);

%---Plot above kmins on the same curve, using the smaller of two draw sizes. 
figure
plot_bravos(0.4, 0.1, 200)
hold off

%---Computing multiple Bravo audits at once
margins = [0.4, 0.3, 0.2, 0.16, 0.1];
alpha = (0.1);
[nBRAVO, kminBRAVO] = B2BRAVOkminMany(margins, alpha); % single risk limit
alpha2 = [0.1,0.05];
[nBRAVO2, kminBRAVO2] = B2BRAVOkminMany(margins, alpha2); % multiple risk limits

%---Plot the above kmins for alpha=0.1 (could also do for others)
for i=1:size(margins,2)
    figure
    plot(nBRAVO2{i,1}, kminBRAVO2{i,1},'Color', navy, 'LineWidth', 2)
    % Label axes
    xlabel('sample size, n', 'FontSize', 14)
    ylabel('kmin', 'FontSize', 14)
    title(sprintf('Minimum winner ballots needed to stop Bravo audit, margin=%4.2f, risk limit = 0.1', ...
        margins(i)), 'FontSize', 16) 
end

%---Bravolike (without replacement)
%---First, audits where only the margin varies
N=(1000);
[nBRAVOLike, kminBRAVOLike] = B2BRAVOLikekminMany(margins, alpha, N); 
%---Next, margins, risk limits and N vary
N2=[1000,10000];
[nBRAVOLike2, kminBRAVOLike2] = B2BRAVOLikekminMany(margins, alpha2, N2);

%---Plot the above kmins for N=1000 and alpha=0.1. 
hold off
figure
for i=1:size(margins,2)
	plot(nBRAVOLike2{i,1,1}, kminBRAVOLike2{i,1,1}, 'LineWidth', 2)
	hold on
end
xlabel('sample size, n', 'FontSize', 14)
ylabel('BravoLike kmin', 'FontSize', 14)
title(sprintf('Minimum winner ballots needed to stop BravoLike audit, N=1000, alpha = 0.1'), ...
           'FontSize', 16)
% Legend
legend('margin=0.4', 'margin=0.3', 'margin=0.2', 'margin=0.16', ...
	'margin=0.1', 'Location', 'SouthEast','FontSize', 14);