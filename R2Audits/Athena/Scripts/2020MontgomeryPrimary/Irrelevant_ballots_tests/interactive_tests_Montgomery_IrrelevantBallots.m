% Very basic copycat script of interactive_tests_Montgomery.m,
% only computes FIRST round sizes for Montgomery County, Ohio, 2020 primary 
% audit using new irrelevant ballot approach.
% Maybe add code for further rounds later.
% -------
% interface script for ith round. Set round=0 and then begin script. Set 
% s = test number. 
round = 0;
s = 1;

if s ~= 1 % Not first test, 
    % Read test file to append to it. 
	fname = '2020_montgomery_interactive_tests_using_montgomery_official.json';
	testing = loadjson(fileread(fname));
end

round = round+1;

% If this is the first round, need audit parameters
if round == 1
    % Read election results
    fname = '2020_montgomery_official.json';
    election_computations = loadjson(fileread(fname));
    races = fieldnames(election_computations.contests)

    % interactively insert other parameters of choice
    fprintf('This is the first round of the audit, enter audit parameters \n')
    race = input('Contest name as a string: ')
    alpha = input('Risk limit, alpha, as a fraction: ')
    percentiles = input('Percentiles as a row vector of size 3: ')
    audit_method = input('audit method as a string: ')
    if strcmp(audit_method,'Athena')
        delta = input('delta value for Athena: ')
    else
        delta = [];
    end
    
    % Read candidate list
    candidates = fieldnames(election_computations.contests.(race).tally);
    votes = zeros(size(candidates));
    
    % ----- PART I ---- Compute necessary properties -------
    for j=1:size(candidates,1)
        votes(j) = election_computations.contests.(race).tally.(candidates{j});
    end
    
    % Find max votes
    [votes_max, winner] = max(votes);
    
    % For each candidate, including winner, compute the difference fraction
    % (the difference between the winner votes and the candidates votes as a 
    % fraction) as well as the irrelevant fraction (the number of votes that 
    % are not for either the winner or the current candidate as a fraction)
    difference_fraction = (votes_max/election_computations.total_ballots) - (votes/election_computations.total_ballots);
    irrelevant_fraction = (election_computations.total_ballots - (votes_max+votes)) / election_computations.total_ballots;  
    
    % list of all losing candidate (numbers)
    losers = (1:size(candidates,1)); 
    losers(winner) = []; % delete the winner
    
    % Initialization parameters below are fixed, don't mess with them
    % Columns will be added to these vectors for each round
    n_last = zeros(size(candidates)); %last cumulative relevant sample size
    n_actual = n_last; % current cumulative relevant sample size 
    kmin_actual = n_last; % current cumulative kmin
    passed_true = kmin_actual; % whether test passed
    % Initialize p-values, d-values and likelihood ratios
    pvalue = zeros(size(candidates)); 
    dvalue = pvalue; 
    LR = pvalue;
    % Rows representing probability vectors; their sizes will increase with
    % ballots drawn. 
    for j=1:size(candidates,1)
        CurrentTierStop{j} = (1);
    end
    CurrentTierRisk = CurrentTierStop;
    StopSched = zeros(size(candidates));
    RiskSched = StopSched;
    % Current number of votes drawn for winner, more will be added with
    % each round
    k_last = 0;
    
    % Initialize testing structure to write into file. 
    testing.interactive.(sprintf('test%d',s)).audit_type = 'athena';
    testing.interactive.(sprintf('test%d',s)).election = ...
        election_computations.name;
    testing.interactive.(sprintf('test%d',s)).contest = race;
    testing.interactive.(sprintf('test%d',s)).alpha = alpha;
    testing.interactive.(sprintf('test%d',s)).quants = percentiles; 
end

% To compute next round sizes, find max size of next round
fprintf('To compute recommended sizes for round %d, enter the following information\n', round)
max_ballots(round) = input('Maximum number of ballots that can be drawn next: ')

testing.interactive.(sprintf('test%d',s)).next_round_size.max_new_ballots_drawn = max_ballots;

% Initialize arrays that will be rewritten for each round
next_rounds_max = zeros(size(candidates,1), size(percentiles,2));
next_rounds_min = next_rounds_max;
kmin_max = next_rounds_max;
kmin_min = kmin_max;
stop_min = kmin_max;
stop_max = kmin_max;
Stopping = zeros(size(candidates,1), max_ballots(round));

% For each loser, compute next round
for j = losers 
    [next_rounds_max(j,:), next_rounds_min(j,:), n, kmin, Stopping(j,:)]  = ...
        RangeNextRoundSizes_IrrelevantBallots(difference_fraction(j), alpha, delta, StopSched(j,:), ...
        RiskSched(j,:), CurrentTierStop{j}, CurrentTierRisk{j}, ...
        n_last(j,round), k_last(round), percentiles, ...
        n_last(j,round)+max_ballots(round), audit_method, irrelevant_fraction(j));

    kmin_max(j,:) = kmin(next_rounds_max(j,:));
    kmin_min(j,:) = kmin(next_rounds_min(j,:));
    stop_max(j,:) = Stopping(j, next_rounds_max(j,:));
    stop_min(j,:) = Stopping(j, next_rounds_min(j,:));
end

% Find largest rounds
[largest_max_round_size, max_round_cand] = max(next_rounds_max);
[largest_min_round_size, min_round_cand] = max(next_rounds_min);

pairwise_relevant_max = [next_rounds_max(max_round_cand(1),1), ...
    next_rounds_max(max_round_cand(2),2), ...
    next_rounds_max(max_round_cand(3),3)];
pairwise_kmin_max = [kmin_max(max_round_cand(1),1), ...
    kmin_max(max_round_cand(2),2), kmin_max(max_round_cand(3),3)];

%---- Would be good to fix this, but works for now ----%
pairwise_candidates_max = cellstr(candidates{max_round_cand(1)});
pairwise_candidates_max = [pairwise_candidates_max, ...
    candidates{max_round_cand(2)}];
pairwise_candidates_max = [pairwise_candidates_max, ...
    candidates{max_round_cand(3)}];
%---- End good to fix -----%

actual_stop_max = [stop_max(max_round_cand(1),1), ...
    stop_max(max_round_cand(2),2), stop_max(max_round_cand(3),3)];

pairwise_relevant_min = [next_rounds_min(min_round_cand(1),1), ...
    next_rounds_min(min_round_cand(2),2), ...
    next_rounds_min(min_round_cand(3),3)];
pairwise_kmin_min = [kmin_min(min_round_cand(1),1), ...
    kmin_min(min_round_cand(2),2), kmin_min(min_round_cand(3),3)];

%---- Would be good to fix this, but works for now ----%
pairwise_candidates_min = cellstr(candidates{max_round_cand(1)});
pairwise_candidates_min = [pairwise_candidates_min, ...
    candidates{max_round_cand(2)}];
pairwise_candidates_min = [pairwise_candidates_min, ...
    candidates{max_round_cand(3)}];
%---- End good to fix -----%

actual_stop_min = [stop_min(min_round_cand(1),1), ...
    stop_min(min_round_cand(2),2), stop_min(min_round_cand(3),3)];

% Inform
% NOTE: wiht new irrelevant ballot approach, max and min round sizes should 
% be the same values!
fprintf('Recommended min round sizes for next draw are as follow\n')
fprintf('Minimum sizes for percentiles [%1.4f, %1.4f, %1.4f] are [%d, %d, %d]\n', ...
    percentiles, largest_min_round_size)
fprintf('With actual stopping probabilities [%1.4f, %1.4f, %1.4f]\n', actual_stop_min)
fprintf('Requiring minimum winner votes (kmin) [%d, %d, %d] to stop\n', ...
    pairwise_kmin_min)  
fprintf('For announced winner %s and candidates [%s, %s, %s]\n\n', ...
    candidates{winner}, candidates{min_round_cand(1)}, ...
    candidates{min_round_cand(2)}, candidates{min_round_cand(3)})

fprintf('Recommended max round sizes for next draw are as follow\n')
fprintf('Maximum sizes for percentiles [%1.4f, %1.4f, %1.4f] are [%d, %d, %d]\n', ...
    percentiles, largest_max_round_size)
fprintf('With actual stopping probabilities [%1.4f, %1.4f, %1.4f]\n', actual_stop_max)
fprintf('Requiring minimum winner votes (kmin) [%d, %d, %d] to stop\n', ...
    pairwise_kmin_max)  
fprintf('For announced winner %s and candidates [%s, %s, %s]\n\n\n', ...
    candidates{winner}, candidates{max_round_cand(1)},...
    candidates{max_round_cand(2)}, candidates{max_round_cand(3)})