% very basic script to read Athena first round SB values, compute distinct ballots and print in Latex
% table
fname='2016_one_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
margin = zeros(size(states,2),1);
ballots_cast = margin;
SB = margin;
Athena = margin;
distinct_SB = margin;
distinct_Athena = margin;

load 
SB = ceil(new_scaled_BRAVOTable);

for i=1:size(states,1)
    if i==23 % Computed using estimate_first_round_Arlo and scaled
        margin(i) = abs(election_results.(states{i}).contests.presidential.margin);
        ballots_cast(i) = abs(election_results.(states{i}).contests.presidential.ballots_cast);
        Athena(i) = 1259688;
        %ratio(i) = Arlo(i)/Athena(i);
    else
        margin(i) = abs(election_results.(states{i}).contests.presidential.margin);
        ballots_cast(i) = abs(election_results.(states{i}).contests.presidential.ballots_cast);
        Athena(i) = election_results.(states{i}).contests.presidential.Athena_pv_scaled;
        %ratio(i) = Arlo(i)/Athena(i);
    end
    distinct_SB(i) = ceil(ballots_cast(i)*(1-((1-(1/ballots_cast(i)))^SB(i))));
    distinct_Athena(i) = ceil(ballots_cast(i)*(1-((1-(1/ballots_cast(i)))^Athena(i))));
end

    new_ratio = distinct_Athena./distinct_SB;
    old_ratio = Athena./SB';
    
for i=1:size(states,1)
	fprintf('%s & %1.4f & %d & %d & %d & %d & %1.4f & %1.4f \\\\ \\hline \n', states{i}, ...
        margin(i), SB(i), distinct_SB(i), Athena(i), distinct_Athena(i), old_ratio(i), new_ratio(i)) 
end