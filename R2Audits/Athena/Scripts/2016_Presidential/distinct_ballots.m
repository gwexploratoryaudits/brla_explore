% very basic script to read Athena and EoR first round sizes and compute
% distinct ballots
fname='2016_one_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
margin = zeros(size(states,2),1);

for i=1:size(states,1)
    if i==23 % Computed using estimate_first_round_Arlo and scaled
        margin(i) = abs(election_results.(states{i}).contests.presidential.margin);
        ballots_cast(i) = abs(election_results.(states{i}).contests.presidential.ballots_cast);
        Arlo(i) = 2618926;
        Athena(i) = 1259688;
        %ratio(i) = Arlo(i)/Athena(i);
    else
        margin(i) = abs(election_results.(states{i}).contests.presidential.margin);
        ballots_cast(i) = abs(election_results.(states{i}).contests.presidential.ballots_cast);
        Arlo(i) = election_results.(states{i}).contests.presidential.Arlo_pv_scaled;
        Athena(i) = election_results.(states{i}).contests.presidential.Athena_pv_scaled;
        %ratio(i) = Arlo(i)/Athena(i);
    end
    distinct_Arlo(i) = ballots_cast(i)*(1-((1-(1/ballots_cast(i)))^Arlo(i)));
    distinct_Athena(i) = ballots_cast(i)*(1-((1-(1/ballots_cast(i)))^Athena(i)));
end

    new_ratio = distinct_Athena./distinct_Arlo;