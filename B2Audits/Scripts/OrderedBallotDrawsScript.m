% For Ordered Ballot Draw First Rounds Using 2016 Presidential Election data. 
% For paper. 
% May not need going forward, as not clear who is using. 
%--------
alpha = [0.1]; % risk limit
percentiles = [0.9]; % 90% stopping probabilities. 
N = [10000]; % Max size first round, works for wider margins. 

fname='2016_one_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
factors = zeros(1, size(states,1)); % Scale up from relevant ballots to all ballots
margins = zeros(1, size(states,1));

for i=1:size(states,1)
    margins(i) = abs(election_results.(states{i}).contests.presidential.margin);
    total_ballots = election_results.(states{i}).contests.presidential.ballots_cast;
    total_relevant_ballots = sum(election_results.(states{i}).contests.presidential.results);
    factors(i) = total_ballots/total_relevant_ballots;
end

% Create new variable to hold wider margins; all margins 0.01 and
% above. 
new_margins = margins;
new_margins(new_margins < 0.01) = [];

%--------------BRAVO kmin and stopping probs------------%
[nBRAVO, kminBRAVO] = B2BRAVOkminMany(new_margins, alpha);
[StopSchedBRAVO, StopProbBRAVO, ExpectedBallotsCorrectBRAVO] = ...
    B2RisksMany(new_margins, N, nBRAVO, kminBRAVO, 0);

%--------------Stopping Percentiles-----------%
BRAVOTable = StoppingPercentilesMany(nBRAVO,StopSchedBRAVO,percentiles);

% Create new variable for the factors for wider margins. 
new_factors = factors;
new_factors(margins < 0.01) = [];

% Scale the Bravo table. 
scaled_BRAVOTable = (new_factors.').*BRAVOTable;

% Insert by hand a valueof 100 which may be recognized going further
% for narrower margins. 
new_scaled_BRAVOTable = vertcat(scaled_BRAVOTable(1:22), 100, ...
    scaled_BRAVOTable(23:28), 100, ...
    scaled_BRAVOTable(29:36), 100, ...
    scaled_BRAVOTable(37:46), 100, ...
    scaled_BRAVOTable(47));

% Output on screen to copy/paste into LaTex file. 
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


