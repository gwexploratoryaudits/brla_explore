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

for i=1:size(states,1)
	fprintf('%s & %1.4f & %d & %d & %d & %d & %1.4f & %1.4f \\\\ \\hline \n', states{i}, ...
        margin(i), Arlo(i), distinct_Arlo(i), Athena(i), distinct_Athena(i), old_ratio(i), new_ratio(i)) 
end