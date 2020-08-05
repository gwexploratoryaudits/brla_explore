% very basic script to read Athena first round values and plot
fname='2016_one_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
margin = zeros(size(states,2),1);

for i=1:size(states,1)
    if i==23 % Computed using estimate_first_round_Arlo and scaled
        margin(i) = abs(election_results.(states{i}).contests.presidential.margin);
        Arlo(i) = 2618926;
        Athena(i) = 1259688;
        %ratio(i) = Arlo(i)/Athena(i);
    else
        margin(i) = abs(election_results.(states{i}).contests.presidential.margin);
        Arlo(i) = election_results.(states{i}).contests.presidential.Arlo_pv_scaled;
        Athena(i) = election_results.(states{i}).contests.presidential.Athena_pv_scaled;
        %ratio(i) = Arlo(i)/Athena(i);
    end
end

% Load from 2016_Presidential
% load 
% Delete the four states with low margin
new_scaled_BRAVOTable2 = ceil(new_scaled_BRAVOTable);
new_scaled_BRAVOTable2(new_scaled_BRAVOTable==100) = [];
margin2 = margin;
margin2(new_scaled_BRAVOTable==100) = [];

%---plot
semilogy(margin, Athena, 'ks', 'MarkerSize', 10, 'LineWidth', 3);
hold
semilogy(margin, Arlo, 'bx', 'MarkerSize', 10, 'LineWidth', 3);
semilogy(margin2, new_scaled_BRAVOTable2, 'v', 'Color', [0.5 0 0], ...
    'MarkerSize', 10, 'LineWidth', 3);
xlabel('Announced Election Margin');
ylabel('First-Round Size (Log Scale)');
title('Athena and Bravo First Round Sizes as a Function of Margin')
legend('Athena', 'End-of-Round Bravo', 'Selection-Ordered-Ballots Bravo')

%--- another one
figure
Athena2= Athena;
Athena2(new_scaled_BRAVOTable==100) = [];
ratio_SO = (Athena2.')./new_scaled_BRAVOTable2;
ratio = Athena./Arlo;
plot(margin, ratio, 'bx', 'MarkerSize', 10, 'LineWidth', 3);
hold
plot(margin2, ratio_SO, 'v', 'Color', [0.5 0 0], 'MarkerSize', 10, 'LineWidth', 3);
xlabel('Announced Election Margin');
ylabel('Athena Round-Size as a Fraction')
legend('End-of-Round Bravo', 'Selection-Ordered-Ballots Bravo')
