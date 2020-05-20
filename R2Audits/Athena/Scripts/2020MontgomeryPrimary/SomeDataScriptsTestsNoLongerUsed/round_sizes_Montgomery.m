% Very basic script to compute interesting properties of announced results 
% as well as Athena first round values for Montgomery County, Ohio, 2020 
% primary audit.

% Parameters for audit
alpha = 0.1;
delta = 1;
percentiles = [0.7, 0.8, 0.9];
max_ballots = 100; % raw max

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
    
    % ----- PART I ---- Compute necessary properties -------%
    % Find max votes
    [votes_max, winner] = max(votes);

    % For each candidate, including winner, compute margin and relevant ballots
    relevant_ballots = votes_max + votes;
    margin = (votes_max-votes)./relevant_ballots;
    
    % factor to scale up raw values
    factor = election_computations.total_ballots./relevant_ballots;
    
    % ------ PART II ----- For each loser, compute Athena first rounds ---- %
    
    % Initialize testing structure
    testing.next_round_size.(sprintf('test%d',i)).audit_type = 'athena';
    testing.next_round_size.(sprintf('test%d',i)).election = ...
        election_computations.name;
    testing.next_round_size.(sprintf('test%d',i)).contest = races{i};
    testing.next_round_size.(sprintf('test%d',i)).alpha = alpha; 
    testing.next_round_size.(sprintf('test%d',i)).quants = percentiles; 
    
    % look at all losing candidates
    losers = (1:size(candidates)); 
    losers(winner) = []; % delete the winner
    
    % Initialize arrays that will be rewritten for each contest
    next_rounds_max_scaled = zeros(size(candidates,1), size(percentiles,2));
    next_rounds_min_scaled = next_rounds_max_scaled;
    
    for j = losers 
        [next_rounds_max, next_rounds_min, n, kmin, Stopping]  = ...
        RangeNextRoundSizes(margin(j), alpha, delta, (0), (0), (1), (1), ...
        0, 0, percentiles, max_ballots, 'Athena');
    
        next_rounds_max_scaled(j,:) = ceil(factor(j)*next_rounds_max);
        next_rounds_min_scaled(j,:) = ceil(factor(j)*next_rounds_min);
        
        % Write results for this losing candidate
        testing.next_round_size.(sprintf('test%d',i)).expected.(candidates{j}).round_candidates_max ...
            = next_rounds_max; 
        testing.next_round_size.(sprintf('test%d',i)).expected.(candidates{j}).round_candidates_max_kmins ...
            = kmin(next_rounds_max); 
        testing.next_round_size.(sprintf('test%d',i)).expected.(candidates{j}).round_candidates_max_probs ...
            = Stopping(next_rounds_max); 
        
        testing.next_round_size.(sprintf('test%d',i)).expected.(candidates{j}).round_candidates_min ...
            = next_rounds_min; 
        testing.next_round_size.(sprintf('test%d',i)).expected.(candidates{j}).round_candidates_min_kmins ...
            = kmin(next_rounds_min); 
        testing.next_round_size.(sprintf('test%d',i)).expected.(candidates{j}).round_candidates_min_probs ...
            = Stopping(next_rounds_min); 
        
        testing.next_round_size.(sprintf('test%d',i)).expected.(candidates{j}).round_candidates_max_scaled ...
            = next_rounds_max_scaled(j,:); 
        testing.next_round_size.(sprintf('test%d',i)).expected.(candidates{j}).round_candidates_min_scaled ...
            = next_rounds_min_scaled(j,:);      
    end
    % Find largest rounds
    
    largest_max_round_size = max(next_rounds_max_scaled);
    largest_min_round_size = max(next_rounds_min_scaled);
    testing.next_round_size.(sprintf('test%d',i)).expected.largest_round_max_scaled = largest_max_round_size;
    testing.next_round_size.(sprintf('test%d',i)).expected.largest_round_min_scaled = largest_min_round_size;
end

% Write all new results into a new file
% txt = jsonencode(election_results);
txt = savejson('',testing);
fname3 = '2020_montgomery_new_tests.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);
