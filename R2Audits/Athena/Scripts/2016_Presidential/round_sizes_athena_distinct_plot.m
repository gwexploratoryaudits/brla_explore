% very basic script to read Athena first round EoR values, compute distinct ballots and print in Latex
% table
fname='2016_one_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
margin = zeros(size(states,2),1);
ballots_cast = margin;
Arlo = margin;
Athena = margin;
distinct_Arlo = margin;
distinct_Athena = margin;

for i=1:size(states,1)
    if i==23 % Computed using estimate_first_round_Arlo and scaled
        margin(i) = abs(election_results.(states{i}).contests.presidential.margin);
        ballots_cast(i) = abs(election_results.(states{i}).contests.presidential.ballots_cast);
        Arlo(i) = 2618926;
        Athena(i) = 1259688;
        %ratio(i) = Arlo(i)/Athena(i);
    elseif i== 30 % New Hampshire, cut and pasted from other EoR numbers
        margin(i) = abs(election_results.(states{i}).contests.presidential.margin);
        ballots_cast(i) = abs(election_results.(states{i}).contests.presidential.ballots_cast);
        Arlo(i) = 1007590;
        Athena(i) = 475357;
    else
        margin(i) = abs(election_results.(states{i}).contests.presidential.margin);
        ballots_cast(i) = abs(election_results.(states{i}).contests.presidential.ballots_cast);
        Arlo(i) = election_results.(states{i}).contests.presidential.Arlo_pv_scaled;
        Athena(i) = election_results.(states{i}).contests.presidential.Athena_pv_scaled;
        %ratio(i) = Arlo(i)/Athena(i);
    end
    distinct_Arlo(i) = ceil(ballots_cast(i)*(1-((1-(1/ballots_cast(i)))^Arlo(i))));
    distinct_Athena(i) = ceil(ballots_cast(i)*(1-((1-(1/ballots_cast(i)))^Athena(i))));
end

    new_ratio = distinct_Athena./distinct_Arlo;
    old_ratio = Athena./Arlo;
    
    load 
    % Delete the four states with low margin
    new_scaled_BRAVOTable2 = ceil(new_scaled_BRAVOTable);
    new_scaled_BRAVOTable2(new_scaled_BRAVOTable==100) = [];
    margin2 = margin;
    margin2(new_scaled_BRAVOTable==100) = [];
    SB = new_scaled_BRAVOTable2;
    distinct_SB = SB;
    for i=1:size(margin2,1)
        distinct_SB(i) = ceil(ballots_cast(i)*(1-((1-(1/ballots_cast(i)))^SB(i))));
    end
        
    %---plot
semilogy(margin, distinct_Athena, 'ks', 'LineWidth', 2);
hold
semilogy(margin, distinct_Arlo, 'bx', 'LineWidth', 2);
semilogy(margin2, distinct_SB, 'v', 'Color', [0.5 0 0],'LineWidth', 2);
xlabel('Announced Election Margin', 'FontSize', 18);
ylabel('First-Round Size (Log Scale)', 'FontSize', 18);
title('Minerva and Bravo First Round Sizes as a Function of Margin', 'FontSize', 18)
legend('Minerva', 'End-of-Round Bravo', 'Selection-Ordered-Ballots Bravo', 'FontSize', 18)

%--- another one
figure
Athena2= distinct_Athena;
Athena2(new_scaled_BRAVOTable==100) = [];
ratio_SO = (Athena2.')./distinct_SB;
plot(margin, new_ratio, 'bx', 'LineWidth', 2);
hold
plot(margin2, ratio_SO, 'v', 'Color', [0.5 0 0], 'LineWidth', 2);
xlabel('Announced Election Margin', 'FontSize', 18);
ylabel('Minerva Round-Size as a Fraction', 'FontSize', 18)
legend('End-of-Round Bravo', 'Selection-Ordered-Ballots Bravo', 'FontSize', 18)

