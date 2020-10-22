% This runs the examples of the read_me file in B2Audits and plots them
% Part 2: Probabilities. 
% RUN PART 1 FIRST
% The script is broken up to make the plots more manageable. 

%---Probability computations for a single audit

%---Bravo
[StopSched1, StopValue1, ExpectedBallots1] = B2Risks(0.4, [], n1, kmin1, 0);
        
%---BravoLike
[StopSched2, StopValue2, ExpectedBallots2] = B2Risks(0.4, 200, n2, kmin2, 1);

%---Plot
figure
plot(n1,StopSched1, 'Marker', 'o', 'Color', navy)
% Label axes
xlabel('sample size, n', 'FontSize', 14)
ylabel('Stopping Probability', 'FontSize', 14)
title(sprintf('BRAVO Stopping Probability for margin=0.4 and kmins computed for margin=0.4 and risk limit=0.1'), ...
    'FontSize', 16) 

figure
plot(n2,StopSched2, 'Marker', '+', 'Color', maroon)
% Label axes
xlabel('sample size, n', 'FontSize', 14)
ylabel('Stopping Probability for margin=0.4 and N=200', 'FontSize', 14)
title(sprintf('BRAVOLike Stopping Probability with kmins computed for N=200, margin=0.4 and risk limit=0.1'), ...
    'FontSize', 16) 

% Risk schedule for Bravo
[RiskSched1, RiskValue1, ExpectedBallotsInCorrect1] = B2Risks(0, [], n1, kmin1, 0);

% Plot risk and alpha times stopping probability on the same graph to observe 
% how similar the behaviour is. 
figure
plot(n1, RiskSched1, 'Marker', '^', 'Color', dull_green)
hold on
plot(n1,StopSched1/10, 'Marker', '+', 'Color', navy)
% Label axes
xlabel('sample size, n', 'FontSize', 14)
ylabel('Risk and alpha times Stopping Probability for margin=0.4 and N=200', 'FontSize', 14)
title(sprintf('BRAVO Risks and Stopping Probability with kmins computed for margin=0.4 and risk limit=0.1'), ...
    'FontSize', 16) 
legend('risk', 'alpha times stopping probability', 'FontSize', 14)

%---Probability Computations for multiple audits

%---BRAVO
[StopSchedBRAVO, StopProbBRAVO, ExpectedBallotsCorrectBRAVO] = ...
    B2RisksMany(margins, [], nBRAVO, kminBRAVO, 0);

margin_incorrect = zeros(1,size(margins,2)); 
[RiskSchedBRAVO, RiskValueBRAVO, ExpectedBallotsInCorrectBRAVO] = ...
    B2RisksMany(margin_incorrect, [], nBRAVO, kminBRAVO, 0);

% Plot for alpha=0.1
for i=1:size(margins,2)
	figure
	plot(nBRAVO{i,1}, RiskSchedBRAVO{i,1}, 'Marker', '^', 'Color', dull_green)
	hold on
	plot(nBRAVO{i,1}, StopSchedBRAVO{i,1}/10, 'Marker', '+', 'Color', navy)
    % Label axes
    xlabel('sample size, n', 'FontSize', 14)
    ylabel('Risk and alpha times Stopping Probability', 'FontSize', 14)
    title(sprintf('BRAVO Risk and alpha times Stopping Probability for margin=%2.2f and kmins computed for the same margin and risk limit=0.1', margins(i)), ...
        'FontSize', 16)
    legend('risk', 'alpha times stopping probability', 'FontSize', 14)
end

%---BRAVOLike 
[StopSchedBRAVOLike, StopProbBRAVOLike, ExpectedBallotsCorrectBRAVOLike] = ...
    B2RisksMany(margins, N, nBRAVOLike, kminBRAVOLike, 1);

% Plot stopping probs for alpha=0.1 and N=1000; risks maybe similarly
% computed. 
for i=1:size(margins,2)
	figure
	plot(nBRAVOLike{i,1,1}, StopSchedBRAVOLike{i,1,1})
    % Label axes
    xlabel('sample size, n', 'FontSize', 14)
    ylabel(sprintf('Stopping Probability for margin=%2.2f and N=1000', margins(i)), 'FontSize', 14)
    title('BRAVOLike Stopping Probability for kmins computed for the same margin, N=1000 and risk limit=0.1', ...
        'FontSize', 16)
end

[RiskSchedBRAVOLike, RiskValueBRAVOLike, ExpectedBallotsInCorrectBRAVOLike] = ...
    B2RisksMany(margin_incorrect, N, nBRAVOLike, kminBRAVOLike, 1);
