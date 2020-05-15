% very basic script to compute Athena MULTIPLE rounds for Montgomery
% County, Ohio, 2020 primary audit
% -------
% interface script for ith round. Set round=0 and then begin script. Set 
% s = test number. 
round = round+1;

% If this is the first round, need audit parameters
if round == 1
    % Read election results
    fname = '2020_montgomery_formatted.json';
    election_computations = loadjson(fileread(fname));
    races = fieldnames(election_computations.contests);

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

    % For each candidate, including winner, compute margin
    relevant_ballots = votes_max + votes;
    margin = (votes_max-votes)./relevant_ballots;
    
    % factor to scale up raw values
    factor = election_computations.total_ballots./relevant_ballots;
    
    % list of all losing candidate (numbers)
    losers = (1:size(candidates,1)); 
    losers(winner) = []; % delete the winner
    
    % Initialization parameters below are fixed, don't mess with them
    % Columns will be added to these vectors for each round
    n_last = zeros(size(candidates)); %last cumulative relevant sample size
    n_actual = n_last; % current cumulative relevant sample size 
    kmin_last = n_last; % last cumulative kmin
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
    
    % Initialize testing structure and write it into file. 
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
next_rounds_max_scaled = zeros(size(candidates,1), size(percentiles,2));
next_rounds_min_scaled = next_rounds_max_scaled;
next_rounds_max = next_rounds_max_scaled;
next_rounds_min = next_rounds_max;
kmin_max = next_rounds_max_scaled;
kmin_min = kmin_max;
stop_min = kmin_max;
stop_max = kmin_max;

% For each loser, compute next round
for j = losers 
    [next_rounds_max(j,:), next_rounds_min(j,:), n, kmin, Stopping]  = ...
        RangeNextRoundSizes(margin(j), alpha, delta, StopSched(j,:), ...
        RiskSched(j,:), CurrentTierStop{j}, CurrentTierRisk{j}, ...
        n_last(j,round), k_last(round), percentiles, ...
        n_last(j,round)+floor(max_ballots(round)/factor(j)), audit_method);
    
    next_rounds_max_scaled(j,:) = ceil(factor(j)*next_rounds_max(j,:));
    next_rounds_min_scaled(j,:) = ceil(factor(j)*next_rounds_min(j,:)); 
    kmin_max(j,:) = kmin(next_rounds_max(j,:));
    kmin_min(j,:) = kmin(next_rounds_min(j,:));
    stop_max(j,:) = Stopping(next_rounds_max(j,:));
    stop_min(j,:) = Stopping(next_rounds_min(j,:));
end

% Find largest rounds
[largest_max_round_size, max_round_cand] = max(next_rounds_max_scaled);
[largest_min_round_size, min_round_cand] = max(next_rounds_min_scaled);

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
    stop_max(min_round_cand(2),2), stop_min(min_round_cand(3),3)];

% Inform
fprintf('Recommended min round sizes are as follow\n')
fprintf('Minimum sizes for percentiles [%1.2f, %1.2f, %1.2f] are [%d, %d, %d]\n', ...
    percentiles, largest_min_round_size)
fprintf('with stopping probabilities [%1.2f, %1.2f, %1.2f]\n', actual_stop_min)
fprintf('Corresponding to pairwise relevant ballots [%d, %d, %d]\n', ...
    pairwise_relevant_min) 
fprintf('and requiring minimum winner votes (kmin) [%d, %d, %d] to stop\n', ...
    pairwise_kmin_min)  
fprintf('for announced winner %s and candidates [%s, %s, %s]\n\n\n', ...
    candidates{winner}, candidates{min_round_cand(1)}, ...
    candidates{min_round_cand(2)}, candidates{min_round_cand(3)})

fprintf('Recommended max round sizes are as follow\n')
fprintf('Maximum sizes for percentiles [%1.2f, %1.2f, %1.2f] are [%d, %d, %d]\n', ...
    percentiles, largest_max_round_size)
fprintf('with stopping probabilities [%1.2f, %1.2f, %1.2f]\n', actual_stop_max)
fprintf('Corresponding to pairwise relevant ballots [%d, %d, %d]\n', ...
    pairwise_relevant_max) 
fprintf('and requiring minimum winner votes [%d, %d, %d] to stop\n', ...
    pairwise_kmin_max)  
fprintf('for announced winner %s and candidates [%s, %s, %s]\n\n\n', ...
    candidates{winner}, candidates{max_round_cand(1)},...
    candidates{max_round_cand(2)}, candidates{max_round_cand(3)})

% save in testing structure
testing.interactive.(sprintf('test%d',s)).next_round_size.expected.(sprintf('round_%d',round)).sizes_max.largest_round_scaled ...
    = largest_max_round_size;
testing.interactive.(sprintf('test%d',s)).next_round_size.expected.(sprintf('round_%d',round)).sizes_max.round_sizes ...
    = pairwise_relevant_max;
testing.interactive.(sprintf('test%d',s)).next_round_size.expected.(sprintf('round_%d',round)).sizes_max.round_kmins ...
    = pairwise_kmin_max;
testing.interactive.(sprintf('test%d',s)).next_round_size.expected.(sprintf('round_%d',round)).sizes_max.round_candidates ...
    = pairwise_candidates_max;
testing.interactive.(sprintf('test%d',s)).next_round_size.expected.(sprintf('round_%d',round)).sizes_max.round_probs ...
    = actual_stop_max;


testing.interactive.(sprintf('test%d',s)).next_round_size.expected.(sprintf('round_%d',round)).sizes_min.largest_round_scaled ...
    = largest_min_round_size;
testing.interactive.(sprintf('test%d',s)).next_round_size.expected.(sprintf('round_%d',round)).sizes_min.round_sizes ...
    = pairwise_relevant_min;
testing.interactive.(sprintf('test%d',s)).next_round_size.expected.(sprintf('round_%d',round)).sizes_min.round_kmins ...
    = pairwise_kmin_min;
testing.interactive.(sprintf('test%d',s)).next_round_size.expected.(sprintf('round_%d',round)).sizes_min.round_candidates ...
    = pairwise_candidates_min;
testing.interactive.(sprintf('test%d',s)).next_round_size.expected.(sprintf('round_%d',round)).sizes_min.round_probs ...
    = actual_stop_min;

% Get sample 
fprintf('Enter information on sample drawn as directed.\n')
% n_in is a row vector of size round, that gets incremented in size with 
% every round. 
n_in(round) = input('Enter cumulative ballots drawn\n') 
% k_in is an array of size: round X no. candidates, a row of values gets
% added every round. 
k_in(round, :) = input('Enter cumulative ballots by candidate as a row vector\n')
fprintf('Total new ballots drawn = %d \n', n_in(round))
fprintf('Total ballots by candidate are as follow:\n')
for j=1:size(candidates)
    fprintf('%s: %d\n', candidates{j}, k_in(round, j))
end

%----------error checking---- %
if (sum(k_in(round,:)) ~= n_in(round)) % sample size mismatch
            fprintf('%s, %d, %s, %d\n','sample size mismatch, test', s, 'round', round)
end

% Write to structure
testing.interactive.(sprintf('test%d',s)).evaluate_risk.round_schedule = n_in; 
testing.interactive.(sprintf('test%d',s)).evaluate_risk.audit_observations_by_round = k_in;

for j=1:size(candidates,1)
    testing.interactive.(sprintf('test%d',s)).evaluate_risk.audit_observations_by_candidate.(candidates{j}) = k_in(:,j).'; 
end


% ------ PART II ----- For each loser, compute pvalues---- 
for j = losers
	% Compute new relevant ballots drawn
    n_actual(j,round) = k_in(round,winner) + k_in(round,j); % cumulative relevant ballots
	this_draw = n_actual(j,round) - n_last(j,round); % new relevant ballots
	% Winning vote distributions for each hypothesis
	CurrentTierStop{j} = R2CurrentTier(margin(j),CurrentTierStop{j},this_draw);
	CurrentTierRisk{j} = R2CurrentTier(0, CurrentTierRisk{j}, this_draw);
            
	% Compute pvalue and likelihood ratio
	[pvalue(j,round), LR(j,round)] = p_value(margin(j), StopSched(j,:), ...
        RiskSched(j,:), CurrentTierStop{j}, CurrentTierRisk{j}, ...
        n_actual(j,round), k_in(round,winner), audit_method);
        dvalue(j,round) = 1/LR(j,round);
            
	% Compute kmin to get stop and risk schedules, current and stop tiers
	kmin_actual(j, round) = AthenaNextkmin(margin(j), alpha, delta, ...
	StopSched(j, :), RiskSched(j, :), CurrentTierStop{j}, ...
    CurrentTierRisk{j}, n_actual(j,round), audit_method);
    
    if kmin_actual(j,round) <= (n_actual(j,round))
        % Round is large enough for  non-zero stopping 
        % probability. Compute tails for each hypothesis at kmin
        StopSched(j, round) = sum(CurrentTierStop{j}(kmin_actual(j,round)+1:size(CurrentTierStop,2)));
        RiskSched(j, round) = sum(CurrentTierRisk{j}(kmin_actual(j,round)+1:size(CurrentTierRisk,2)));
    
        % Compute new distribution corresponding to a kmin decision
        CurrentTierStop{j} = CurrentTierStop{j}(1:kmin_actual(j,round));
        CurrentTierRisk{j} = CurrentTierRisk{j}(1:kmin_actual(j,round));
    else
        StopSched(j, round) = 0;
        RiskSched(j, round) = 0;
    end
    
    % Done for this loser. Write into test structure
    testing.interactive.(sprintf('test%d',s)).evaluate_risk.expected.(candidates{j}).kmin ...
        = kmin_actual(j, :); 
    testing.interactive.(sprintf('test%d',s)).evaluate_risk.expected.(candidates{j}).pvalue ...
        = pvalue(j, :); 
    testing.interactive.(sprintf('test%d',s)).evaluate_risk.expected.(candidates{j}).delta ...
        = dvalue(j, :); 
    testing.interactive.(sprintf('test%d',s)).evaluate_risk.expected.(candidates{j}).StopSched ...
        = StopSched(j, :);
    testing.interactive.(sprintf('test%d',s)).evaluate_risk.expected.(candidates{j}).RiskSched ...
        = RiskSched(j, :);
end % for every loser
    
% Done with all losers
% Summary maximum p and d values for this round. Max finds max in each column. 
pvalue_max = max(pvalue);
dvalue_max = max(dvalue);
passed_true(round) = int8((pvalue_max(round) <= alpha) && ...
    (dvalue_max(round) <= delta));
passed_found = find(passed_true, 1);
passed = ~isempty(passed_found);

% Write to structure
testing.interactive.(sprintf('test%d',s)).expected.passed = passed; 
testing.interactive.(sprintf('test%d',s)).expected.pvalue = min(pvalue_max); 
testing.interactive.(sprintf('test%d',s)).expected.delta = min(dvalue_max);

% Output to user
fprintf('Total new ballots drawn = %d \n', n_in(round))

% Update
% Round is done, update number of relevant ballots for all
n_last(:,round+1) = n_actual(:,round);
k_last(round+1) = k_in(round,winner);

% Write tests back into testing file
txt = savejson('',testing);
fname3 = '2020_montgomery_interactive_tests.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

%sprintf('%s',(candidates{winner}),'*')