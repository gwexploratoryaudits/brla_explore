% Very basic script to compute interesting properties of announced results 
% as well as Athena first round values for Montgomery County, Ohio, 2020 
% primary audit.

% Parameters for audit
alpha = 0.1;
delta = 1;
percentiles = [0.7, 0.8, 0.9];
% raw max
max_ballots = 100;

% Read election results
fname='2020_montgomery_formatted.json';
election_results = loadjson(fileread(fname));

% Make a new structure to hold computed values
election_computations = election_results;

% Look at individual contests %
races = fieldnames(election_computations.contests);
for i=1:size(races) % for each contest
    candidates = fieldnames(election_computations.contests.(races{i}).tally);
    votes = zeros(size(candidates));
    for j=1:size(candidates)
        votes(j) = election_computations.contests.(races{i}).tally.(candidates{j});
    end
    
    % ----- PART I ---- Compute properties -------%
    % Find max votes
    [votes_max, r] = max(votes);
      
    % Find second highest votes
    votes(r(1)) = [];
    votes_second = max(votes);
    
    % Because you deleted the highest number of votes, need it again
    for j=1:size(candidates)
        votes(j) = election_computations.contests.(races{i}).tally.(candidates{j});
    end
    
    % Find candidate with second highest votes
    position = find(votes==votes_second, 1);
    
    % Denote them distinctly
    renameStructField(election_computations.contests.(races{i}).tally, candidates(r), 'd_president');
    
    % Total relevant ballots and margin.
    total_relevant_ballots = votes_max + votes_second;
    margin = (votes_max-votes_second)/total_relevant_ballots;
    
    % factor to scale up raw values
    factor = election_computations.total_ballots/total_relevant_ballots;
    
    % ------ PART II ----- Compute Athena first rounds ---- %
    
    [next_rounds_max, next_rounds_min, n{i}, kmin{i}, Stopping{i}]  = ...
        RangeNextRoundSizes(margin, alpha, delta, (0), (0), (1), (1), ...
        0, 0, percentiles, max_ballots, 'Athena');
    next_rounds_max_scaled = ceil(factor*next_rounds_max);
    next_rounds_min_scaled = ceil(factor*next_rounds_min);
    n_scaled{i} = ceil(factor*n{i});
    
    % ----- PART III ----- Output --- %
    % Write properties in a new field of the race
    election_computations.contests.(races{i}).info.runnerup = candidates(position);
    election_computations.contests.(races{i}).info.votes_max = votes_max;
    election_computations.contests.(races{i}).info.votes_second_highest = votes_second;
    election_computations.contests.(races{i}).info.total_relevant_ballots = ... 
        total_relevant_ballots;
    election_computations.contests.(races{i}).info.margin = margin;
    election_computations.contests.(races{i}).info.scale_factor = factor;
    
    % For each value in percentiles, note the Athena first rounds in a new 
    % field of the race
    election_computations.contests.(races{i}).Athena_first_round.alpha = alpha;
    election_computations.contests.(races{i}).Athena_first_round.percentiles = percentiles;
    election_computations.contests.(races{i}).Athena_first_round.raw_max = next_rounds_max;
    election_computations.contests.(races{i}).Athena_first_round.raw_min = next_rounds_min;
    election_computations.contests.(races{i}).Athena_first_round.raw_max_scaled = next_rounds_max_scaled;
    election_computations.contests.(races{i}).Athena_first_round.raw_min_scaled = next_rounds_min_scaled;
    
    % Note the Athena first rounds in a different structure for testing
    testing.next_round_size.(sprintf('test%d',i)).audit_type = 'athena';
    testing.next_round_size.(sprintf('test%d',i)).election = election_computations.name;
    testing.next_round_size.(sprintf('test%d',i)).contest = races{i};
    testing.next_round_size.(sprintf('test%d',i)).alpha = alpha; 
    testing.next_round_size.(sprintf('test%d',i)).quants = percentiles; 
    testing.next_round_size.(sprintf('test%d',i)).expected.round_candidates_max = next_rounds_max; 
    testing.next_round_size.(sprintf('test%d',i)).expected.round_candidates_min = next_rounds_min; 
    testing.next_round_size.(sprintf('test%d',i)).expected.round_candidates_max_scaled = next_rounds_max_scaled; 
    testing.next_round_size.(sprintf('test%d',i)).expected.round_candidates_min_scaled = next_rounds_min_scaled; 
    
  % write kmins into a different file
    fname2 = sprintf('2020_montgomery_kmins_%s.txt',(races{i}));
    fid = fopen(fname2, 'w');
    if fid == -1, error('Cannot create kmin file'); end
    fprintf(fid, 'alpha = %4f\n', alpha);
    fprintf(fid,'%8s \t %8s\n','n','kmin(n)');
    fprintf(fid, '%8d \t %8d\n',[n{i}; kmin{i}]); 
    fclose(fid);
end

% Write all new results into a new file
% txt = jsonencode(election_results);
txt = savejson('',election_computations);
fname3 = '2020_montgomery_formatted_computations.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

% Write next round tests into a testing file
txt = savejson('',testing);
fname3 = '2020_montgomery_tests.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

%------ Plot stopping probabilities------ %
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
