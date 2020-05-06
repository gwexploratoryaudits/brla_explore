% very basic script to compute Athena first round values for Montgomery
% County, Ohio, 2020 primary audit

% Parameters
alpha = 0.1;
delta = 1;
percentiles = [0.7, 0.8, 0.9];
% raw max
max_ballots = 100;

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
    [votes_max, r(1)] = max(votes);
    election_results.(contests{i+4}).info.votes_max = votes_max;
    election_results.(contests{i+4}).info.winner = r(1)-1;
    
    % Find second highest votes
    votes(r(1)) = [];
    votes_second = max(votes);
    election_results.(contests{i+4}).info.votes_second_highest = votes_second;
    votes = election_results.(contests{i+4}).votes;
    position = find(votes==votes_second, 1)-1;
    election_results.(contests{i+4}).info.runnerup = position;
    
    % Total relevant ballots
    total_relevant_ballots = votes_max + votes_second;
    election_results.(contests{i+4}).info.total_relevant_ballots = ... 
        total_relevant_ballots;
    
    % factor to scale up raw values
    factor = election_results.total_ballots/total_relevant_ballots;
    election_results.(contests{i+4}).scale_factor = factor;
    
    [next_rounds_max, next_rounds_min, n{i}, kmin{i}, Stopping{i}]  = RangeNextRoundSizes(election_results.(contests{i+4}).margin, alpha, delta, (0), (0), (1), (1), 0, 0, percentiles, max_ballots, 'Athena');
    next_rounds_max_scaled = ceil(factor*next_rounds_max);
    next_rounds_min_scaled = ceil(factor*next_rounds_min);
    n_scaled{i} = ceil(factor*n{i});
        
    % For each value in percentiles, note the results in election_results
    for j=1:size(percentiles,2)
        election_results.(contests{i+4}).Athena_first_round(j).alpha = alpha;
        election_results.(contests{i+4}).Athena_first_round(j).percentile = percentiles(j);
        election_results.(contests{i+4}).Athena_first_round(j).raw_max = next_rounds_max(j);
        election_results.(contests{i+4}).Athena_first_round(j).raw_min = next_rounds_min(j);
        election_results.(contests{i+4}).Athena_first_round(j).raw_max_scaled = next_rounds_max_scaled(j);
        election_results.(contests{i+4}).Athena_first_round(j).raw_min_scaled = next_rounds_min_scaled(j);
    end
    
    % write kmins into a different file
    fname2 = sprintf('2020_montgomery_kmins_%s.txt',(contests{i+4}));
    fid = fopen(fname2, 'w');
    if fid == -1, error('Cannot create kmin file'); end
    fprintf(fid, 'alpha = %4f\n', alpha);
    fprintf(fid,'%8s \t %8s\n','n','kmin(n)');
    fprintf(fid, '%8d \t %8d\n',[n{i}; kmin{i}]); 
    fclose(fid);
end

% Write election_results back into new file
%txt = jsonencode(election_results);
txt = savejson(election_results);
fname3 = '2020_montgomery_results.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

plot(n_scaled{1}, Stopping{1}, 'r--o', n_scaled{2}, Stopping{2}, 'g--+', ...
    n_scaled{3}, Stopping{3}, 'b--*', n_scaled{4}, Stopping{4}, 'm->', ...
    n_scaled{5}, Stopping{5}, '-s', n_scaled{6}, Stopping{6}, 'c-^', ...
    n_scaled{7}, Stopping{7}, 'k-d', n_scaled{8}(1:40), Stopping{8}(1:40), 'r-h', ...
    n_scaled{9}, Stopping{9}, 'b-v', ...
    n_scaled{3}, 0.9*ones(size(n_scaled{3})), '-')
legend('d\_president', 'd\_congress', 'd\_senator', ...
    'd\_cc\_1\_2\_2021', 'd\_cc\_1\_3\_2021', 'r\_10th', ...
    'r\_senator', 'r\_42nd', 'r\_cc\_1\_2\_2021')
xlabel('Sample Size (in total ballots, including irrelevant ones)')
ylabel('Probability of stopping')
title('Stopping probability vs. Sample size')
