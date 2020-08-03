% For Ordered Ballot Draw First Rounds Using Election data. 
%--------
alpha = [0.1];
percentiles = [0.9];
N = [10000];

fname='2016_one_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
margins = zeros(1, size(states,1));

for i=1:size(states,1)
    margins(i) = abs(election_results.(states{i}).contests.presidential.margin);
end

margins(margins > 0.05) = [];
margins(margins < 0.01) = [];

%--------------BRAVO------------%
[nBRAVO, kminBRAVO] = B2BRAVOkminMany(margins, alpha);
[StopSchedBRAVO, StopProbBRAVO, ExpectedBallotsCorrectBRAVO] = ...
    B2RisksMany(margins, N, nBRAVO, kminBRAVO, 0);

%--------------Stopping Percentiles-----------%
BRAVOTable = StoppingPercentilesMany(nBRAVO,StopSchedBRAVO,percentiles);

