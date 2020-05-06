% very basic script to compute Athena first round values for Montgomery
% County, Ohio, 2020 primary audit

% Parameters
alpha = 0.1;
delta = 1;
percentiles = [0.7, 0.8, 0.9];

% Read election results
fname='2020_montgomery.json';
election_results = jsondecode(fileread(fname));

% Delete fields 8, 12, 15 as contests are local and too many ballots 
% required. 
election_results = rmfield(election_results, 'd_39th');
election_results = rmfield(election_results, 'r_judge');
election_results = rmfield(election_results, 'r_43rd');

% Want to change the names
election_results = renameStructField(election_results, 'd_primary', 'd_president');
election_results = renameStructField(election_results, 'd_cc_feb', 'd_cc_1_2_2021');
election_results = renameStructField(election_results, 'd_cc_mar', 'd_cc_1_3_2021');
election_results = renameStructField(election_results, 'r_cc_feb', 'r_cc_1_2_2021');

contests = fieldnames(election_results);
% First four fields are global values for the election. 
% Next 9 fields are contests. 
% For each contest 

for i=1:size(contests)-4
    votes = election_results.(contests{i+4}).votes;
    
    % Find max votes
    [votes_max, r] = max(votes);
    
    % Find second highest votes
    votes(r) = [];
    votes_second = max(votes);
    
    % Total relevant ballots
    total_relevant_ballots = votes_max + votes_second;
    
    % factor to scale up raw values
    factor = election_results.total_ballots/total_relevant_ballots;
    election_results.(contests{i+4}).scale_factor = factor;
    
    % For each value in percentiles
    for j=1:size(percentiles,2)
        election_results.(contests{i+4}).Athena_first_round(j).percentile = percentiles(j);
        % Compute raw values for first round
        [next_rounds_max, next_rounds_min, ~, ~, ~]  = RangeNextRoundSizes(election_results.(contests{i+4}).margin, alpha, delta, (0), (0), (1), (1), 0, 0, (percentiles(j)), 800, 'Athena');
        election_results.(contests{i+4}).Athena_first_round(j).raw_max = next_rounds_max;
        election_results.(contests{i+4}).Athena_first_round(j).raw_min = next_rounds_min;
    
        % scale up
        next_rounds_max_scaled = ceil(factor*next_rounds_max);
        next_rounds_min_scaled = ceil(factor*next_rounds_min);
        election_results.(contests{i+4}).Athena_first_round(j).raw_max_scaled = next_rounds_max_scaled;
        election_results.(contests{i+4}).Athena_first_round(j).raw_min_scaled = next_rounds_min_scaled;
    end
end

% Write this back into new file
txt = jsonencode(election_results);
fname2 = '2020_montgomery_results.json';
fid = fopen(fname2, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

