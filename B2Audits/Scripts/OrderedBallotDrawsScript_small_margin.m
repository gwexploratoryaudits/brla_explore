% For Ordered Ballot Draw First Rounds Using Election data for small margins.
% Takes hours for 23, Michigan. Maybe less for others. 
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
new_margins = margins(23);

%--------------BRAVO------------%
[nBRAVO, kminBRAVO] = B2BRAVOkminMany(new_margins, alpha);
[StopSchedBRAVO, StopProbBRAVO, ExpectedBallotsCorrectBRAVO] = ...
    B2RisksMany(new_margins, N, nBRAVO, kminBRAVO, 0);

%--------------Stopping Percentiles-----------%
BRAVOTable = StoppingPercentilesMany(nBRAVO,StopSchedBRAVO,percentiles);

new_factors = factors(23);

scaled_BRAVOTable = (new_factors.').*BRAVOTable;