% very basic script to plot Minerva values, first run 
% first_round_preds_10_2020 script

% Delete the four states with low margin
% new_scaled_BRAVOTable2 = ceil(new_scaled_BRAVOTable);
% new_scaled_BRAVOTable2(new_scaled_BRAVOTable==100) = [];
% margin2 = margin;
% margin2(new_scaled_BRAVOTable==100) = [];

%---plot
semilogy(margin_many, distinct, 'ks', 'MarkerSize', 10, 'LineWidth', 3);
hold
semilogy(margin_many, distinct_B, 'bx', 'MarkerSize', 10, 'LineWidth', 3);
%semilogy(margin2, new_scaled_BRAVOTable2, 'v', 'Color', [0.5 0 0], ...
%    'MarkerSize', 10, 'LineWidth', 3);
xlabel('Announced Election Margin');
ylabel('First-Round Size (Log Scale)');
title('Minerva and Bravo First Round Sizes as a Function of Margin')
%legend('Minerva', 'End-of-Round Bravo', 'Selection-Ordered-Ballots Bravo')
legend('Minerva', 'End-of-Round Bravo')
%--- another one
figure
plot(margin_many, distinct_factor_many, 'bx', 'MarkerSize', 10, 'LineWidth', 3);
hold
%plot(margin2, ratio_SO, 'v', 'Color', [0.5 0 0], 'MarkerSize', 10, 'LineWidth', 3);
xlabel('Announced Election Margin');
ylabel('Minerva Round-Size as a Fraction')
%legend('End-of-Round Bravo', 'Selection-Ordered-Ballots Bravo')
legend('End-of-Round Bravo')
