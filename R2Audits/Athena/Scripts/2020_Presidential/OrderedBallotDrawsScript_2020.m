% For Ordered Ballot Draw First Rounds Using 2020 Presidential Election data. 
% For paper. 
% May not need going forward, as not clear who is using. 
% Assumed you've run the script first_round_preds_10_2020 before this
%--------
alpha = [0.1]; % risk limit
percentiles = [0.9]; % 90% stopping probabilities. 
N = [10000]; % Max size first round, works for wider margins. 
min_margin = 0.033;

% Create new variable to hold wider margins; all margins 0.033 and
% above. 
new_margins = margin_many;
new_margins(new_margins < min_margin) = [];

total_ballots = zeros(size(states,1),1);
total_relevant_ballots = total_ballots;
factor_many = total_ballots;

for i=1:size(states,1)
    % factor to scale up raw values
    total_ballots(i) = ...
            election_results.(states{i}).contests.presidential.ballots_cast;
    total_relevant_ballots(i) = ...
            sum(election_results.(states{i}).contests.presidential.results);
	factor_many(i) = total_ballots(i)/total_relevant_ballots(i);
end

%--------------BRAVO kmin and stopping probs------------%
[nBRAVO, kminBRAVO] = B2BRAVOkminMany(new_margins, alpha);
[StopSchedBRAVO, StopProbBRAVO, ExpectedBallotsCorrectBRAVO] = ...
    B2RisksMany(new_margins, N, nBRAVO, kminBRAVO, 0);

%--------------Stopping Percentiles-----------%
BRAVOTable = StoppingPercentilesMany(nBRAVO,StopSchedBRAVO,percentiles);

% Create new variable for the factors for wider margins. 
new_factors = factor_many;
new_factors(margin_many < min_margin) = [];

% Scale the Bravo table. 
scaled_BRAVOTable = ceil((new_factors.').*BRAVOTable);

for i=1:size(new_margins,2)
    distinct_S(i) = ceil(total_ballots(i)*(1-((1-(1/total_ballots(i)))^scaled_BRAVOTable(i))));
end

% Michigan: i=23
N=15000;

%--------------BRAVO kmin and stopping probs------------%
[nBRAVO, kminBRAVO] = B2BRAVOkminMany(margin_many(23), alpha);
[StopSchedBRAVO, StopProbBRAVO, ExpectedBallotsCorrectBRAVO] = ...
    B2RisksMany(margin_many(23), N, nBRAVO, kminBRAVO, 0);

%--------------Stopping Percentiles-----------%
NewValue = factor_many(23)*StoppingPercentilesMany(nBRAVO,StopSchedBRAVO,percentiles);
NewValue_distinct = ceil(total_ballots(23)*(1-((1-(1/total_ballots(23)))^NewValue)));

% Insert by hand a value of 100 which may be recognized going further
% for narrower margins. 
new_distinct = [distinct_S(1:2), 100, ...
    distinct_S(3:9), 100, ...
    distinct_S(10:20), NewValue_distinct, ...
    distinct_S(21:25), 100, ...
    distinct_S(26:29), 100, ...
    distinct_S(30:33), 100, ...
    distinct_S(34:43), 100, ...
    distinct_S(44)];

% Output on screen to copy/paste into LaTex file. 
for i=1:size(margin_many,2)
    fprintf('%s & %1.4f & %d & %d & %1.4f \\\\ \\hline \n', states{i}, ...
            margin_many(i), ...
            new_distinct(i), ...
            distinct(i), ...
            new_distinct(i)/distinct(i)) 
end


