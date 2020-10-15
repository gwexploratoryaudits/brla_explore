% For Ordered Ballot Draw First Rounds Using Election data. 
%--------
alpha = [0.1];
percentiles = [0.9];
N = [10000];

fname='2016_one_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
factors = zeros(1, size(states,1));
margins = zeros(1, size(states,1));

for i=1:size(states,1)
    margins(i) = abs(election_results.(states{i}).contests.presidential.margin);
    total_ballots = election_results.(states{i}).contests.presidential.ballots_cast;
    total_relevant_ballots = sum(election_results.(states{i}).contests.presidential.results);
    factors(i) = total_ballots/total_relevant_ballots;
end
new_margins = margins;

new_margins(new_margins < 0.01) = [];

%--------------BRAVO------------%
[nBRAVO, kminBRAVO] = B2BRAVOkminMany(new_margins, alpha);
[StopSchedBRAVO, StopProbBRAVO, ExpectedBallotsCorrectBRAVO] = ...
    B2RisksMany(new_margins, N, nBRAVO, kminBRAVO, 0);

%--------------Stopping Percentiles-----------%
BRAVOTable = StoppingPercentilesMany(nBRAVO,StopSchedBRAVO,percentiles);

new_factors = factors;
new_factors(margins < 0.01) = [];

scaled_BRAVOTable = (new_factors.').*BRAVOTable;
new_scaled_BRAVOTable = vertcat(scaled_BRAVOTable(1:22), 100, ...
    scaled_BRAVOTable(23:28), 100, ...
    scaled_BRAVOTable(29:36), 100, ...
    scaled_BRAVOTable(37:46), 100, ...
    scaled_BRAVOTable(47));

for i=1:size(margins,2)
    if i==23 % Computed using estimate_first_round_Arlo and scaled??!!
        fprintf('%s & %1.4f & %d & %d & 0.4810 \\\\ \\hline \n', states{i}, ...
            margins(i), ...
            2618926, ...
            1259688)    
    else
    fprintf('%s & %1.4f & %d & %d & %1.4f \\\\ \\hline \n', states{i}, ...
            margins(i), ...
            ceil(new_scaled_BRAVOTable(i)), ...
            election_results.(states{i}).contests.presidential.Athena_pv_scaled, ...
            election_results.(states{i}).contests.presidential.Athena_pv_scaled/...
            new_scaled_BRAVOTable(i)) 
    end
end


