% very basic script to plot Minerva values, first run 
% first_round_preds_10_2020 script

% Delete the four states with low margin
% new_scaled_BRAVOTable2 = ceil(new_scaled_BRAVOTable);
% new_scaled_BRAVOTable2(new_scaled_BRAVOTable==100) = [];
% margin2 = margin;
% margin2(new_scaled_BRAVOTable==100) = [];


distinct_S = [149, 893, 124, 113, 516, 240, 268, 10, 8442, 110, 99, 331, ... 
    370, 1410, 441, 142, 276, 1133, 85, 85, 12279, 1864, 352, 404, 352, 259, ...
    1757, 381, 811, 182, 83, 1485, 85, 362, 222, 705, 137, 178, 3071, ...
    218, 74, 932, 253, 64, 49];
ratio_SO = distinct_S./distinct(margin_many > 0.025); % margins for distinct_S

margin2 = margin_many(margin_many > 0.025); % margins for distinct_S

margin3 = margin2(margin2 < 0.25); % constrained margins for distinct_S
margin4 = margin_many((margin_many > 0.025) & (margin_many < 0.25)); % constrained margins for distinct;

%---plot
figure
ax = gca;
ax.YScale = 'log';
%axes('FontSize', 10)
%hold
semilogy(margin4, distinct((margin_many > 0.025)  & (margin_many < 0.25)), ...
    'ks', 'MarkerSize', 7, 'LineWidth', 2);
ax.FontSize=14;
%semilogy(margin_many, distinct, 'ks', 'MarkerSize', 10, 'LineWidth', 3);
hold
semilogy(margin4, distinct_B((margin_many > 0.025)  & (margin_many < 0.25)), ...
    'bx', 'MarkerSize', 7, 'LineWidth', 2);
%semilogy(margin_many, distinct_B, 'bx', 'MarkerSize', 10, 'LineWidth', 3);
semilogy(margin3, distinct_S(margin2 < 0.25), 'v', 'Color', [0.5 0 0], ...
    'MarkerSize', 7, 'LineWidth', 2);
%semilogy(margin2, distinct_S, 'v', 'Color', [0.5 0 0], ...
    %'MarkerSize', 10, 'LineWidth', 3);
xlabel('Announced Election Margin', 'FontSize', 16);
ylabel('First-Round Size (Log Scale)', 'FontSize', 16);
title('Minerva and Bravo First Round Sizes as a Function of Margin', 'FontSize', 16)
legend('Minerva', 'End-of-Round Bravo', 'Selection-Ordered-Ballots Bravo', 'FontSize', 16)
% legend('Minerva', 'End-of-Round Bravo')
%--- another one
figure
ax2=gca;
ax2.FontSize=14;
%axes('FontSize', 10)
%hold
%plot(margin_many, distinct_factor_many, 'bx', 'MarkerSize', 10, 'LineWidth', 3);
plot(margin_many, distinct_factor_many, 'bx', 'MarkerSize', 7, 'LineWidth', 2);
ax2.FontSize=14;
hold
%plot(margin2, ratio_SO, 'v', 'Color', [0.5 0 0], 'MarkerSize', 10, 'LineWidth', 3);
plot(margin2, ratio_SO, 'v', 'Color', [0.5 0 0], 'MarkerSize', 7, 'LineWidth', 2);
xlabel('Announced Election Margin', 'FontSize', 16);
ylabel('Minerva Round-Size as a Fraction', 'FontSize', 16)
legend('End-of-Round Bravo', 'Selection-Ordered-Ballots Bravo', 'FontSize', 14)
%legend('End-of-Round Bravo')
