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
    race = input('Contest name as a string:');
    alpha = input('Risk limit, alpha, as a fraction: ');
    percentiles = input('Percentiles as a row vector of size 3: ');
    audit_method = input('audit method as a string: ');
    if strcmp(audit_method,'Athena')
        delta= input('delta value for Athena: ');
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
    n_last = zeros(size(candidates));
    kmin_last = n_last;
    n_rounds = n_last;
    currently_drawn_ballots = 0;
    % Initialize p-values and d-values
    pvalue = zeros(size(candidates)); % initialize pvalues, same size as votes
    dvalue = pvalue; % initialize dvalues, same size as pvalues
    LR = pvalue;
    % Initialize probbaility vectors
    CurrentTierStop = ones(size(candidates));
    CurrentTierRisk = CurrentTierStop;
    StopSched = zeros(size(candidates));
    RiskSched = StopSched;
    
    % Initialize testing structure and write it into file. 
    testing.interactive.(sprintf('test%d',s)).audit_type = 'athena';
    testing.interactive.(sprintf('test%d',s)).election = ...
        election_computations.name;
    testing.interactive.(sprintf('test%d',s)).contest = race;
    testing.interactive.(sprintf('test%d',s)).alpha = alpha; 
    testing.interactive.(sprintf('test%d',s)).quants = percentiles; 
end

% To compute next round sizes, find limit of size of next round
fprintf('To compute the round size of round %d, enter the following information\n', round)
max_ballots = input('Maximum number of ballots:');

testing.interactive.(sprintf('test%d',s)).(sprintf('round%d',round)).max_ballots_drawn = max_ballots;

% Initialize arrays that will be rewritten for each round
next_rounds_max_scaled = zeros(size(candidates,1), size(percentiles,2));
next_rounds_min_scaled = next_rounds_max_scaled;
next_rounds_max = next_rounds_scaled;
next_rounds_min = next_rounds_max;
kmin_max = next_rounds_max_scaled;
kmin_min = kmin_max;

% For each loser, compute next round
for j = losers 
    [next_rounds_max(j,:), next_rounds_min(j,:), n, kmin, Stopping]  = ...
        RangeNextRoundSizes(margin(j), alpha, delta, StopSched(j,:), ...
        RiskSched(j,:), CurrentTierStop(j,:), CurrentTierRisk(j,:), ...
        n_last(j,round), kmin_last(j,round), percentiles, ...
        max_ballots/factor(j), audit_method);
    
    next_rounds_max_scaled(j,:) = ceil(factor(j)*next_rounds_max(j,:));
    next_rounds_min_scaled(j,:) = ceil(factor(j)*next_rounds_min(j,:)); 
    kmin_max(j,:) = kmin(next_rounds_max(j,:));
    kmin_min(j,:) = kmin(next_rounds_min(j,:));
end

% Find largest rounds
[largest_max_round_size, max_round_cand] = max(next_rounds_max_scaled);
[largest_min_round_size, min_round_cand] = max(next_rounds_min_scaled);

pairwise_relevant_max = [next_rounds_max(max_round_cand(1),1), ...
    next_rounds_max(max_round_cand(2),2), ...
    next_rounds_max(max_round_cand(3),3)];
pairwise_kmin_max = [kmin_max(max_round_cand(1),1), ...
    next_rounds_max(max_round_cand(2),2), ...
    next_rounds_max(max_round_cand(3),3)];
pairwise_candidates_max = [candidates{max_round_cand(1)},...
    candidates{max_round_cand(2)}, candidates{max_round_cand(3)}];

pairwise_relevant_min = [next_rounds_min(min_round_cand(1),1), ...
    next_rounds_min(min_round_cand(2),2), ...
    next_rounds_min(min_round_cand(3),3)];
pairwise_kmin_min = [kmin_min(min_round_cand(1),1), ...
    next_rounds_min(min_round_cand(2),2), ...
    next_rounds_min(min_round_cand(3),3)];
pairwise_candidates_min = [candidates{min_round_cand(1)},...
    candidates{min_round_cand(2)}, candidates{min_round_cand(3)}];

% Inform
fprintf('Recommended min round sizes are as follow\n')
fprintf('Minimum sizes for percentiles [%1.2f, %1.2f, %1.2f] are [%d, %d, %d]\n', ...
    percentiles, largest_min_round_size)
fprintf('Corresponding to pairwise relevant ballots [%d, %d, %d]\n', ...
    pairwise_relevant_min) 
fprintf('and requiring minimum winner votes [%d, %d, %d] to stop\n', ...
    pairwise_kmin_min)  
fprintf('for announced winner %s and candidates [%s, %s, %s]\n', ...
    candidates{winner}, pairwise_candidates_min)

fprintf('Recommended max round sizes are as follow\n')
fprintf('Maximum sizes for percentiles [%1.2f, %1.2f, %1.2f] are [%d, %d, %d]\n', ...
    percentiles, largest_max_round_size)
fprintf('Corresponding to pairwise relevant ballots [%d, %d, %d]\n', ...
    pairwise_relevant_max) 
fprintf('and requiring minimum winner votes [%d, %d, %d] to stop\n', ...
    pairwise_kmin_max)  
fprintf('for announced winner %s and candidates [%s, %s, %s]\n', ...
    candidates{winner}, pairwise_candidates_max)

% save in testing structure
testing.interactive.(sprintf('test%d',s)).expected.(sprintf('round%d',round)).largest_max_round_size ...
    = largest_max_round_size;
testing.interactive.(sprintf('test%d',s)).expected.(sprintf('round%d',round)).pairwise_relevant_max ...
    = pairwise_relevant_max;
testing.interactive.(sprintf('test%d',s)).expected.(sprintf('round%d',round)).pairwise_kmin_max ...
    = pairwise_kmin_max;
testing.interactive.(sprintf('test%d',s)).expected.(sprintf('round%d',round)).pairwise_candidates_max ...
    = pairwise_candidates_max;

testing.interactive.(sprintf('test%d',s)).expected.(sprintf('round%d',round)).largest_min_round_size ...
    = largest_min_round_size;
testing.interactive.(sprintf('test%d',s)).expected.(sprintf('round%d',round)).pairwise_relevant_min ...
    = pairwise_relevant_min;
testing.interactive.(sprintf('test%d',s)).expected.(sprintf('round%d',round)).pairwise_kmin_min ...
    = pairwise_kmin_min;
testing.interactive.(sprintf('test%d',s)).expected.(sprintf('round%d',round)).pairwise_candidates_min ...
    = pairwise_candidates_min;

% Get input ballot numbers
fprintf('Enter information on sample drawn\n')
n_in(round) = input('Enter total ballots drawn\n');
k_in(round) = input('Enter total ballots by candidate\n');
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
testing.interactive.(sprintf('test%d',s)).round_schedule = n_in; 
testing.interactive.(sprintf('test%d',s)).audit_observations_by_round = k_in;

for j=1:size(candidates,1)
    testing.interactive.(sprintf('test%d',s)).audit_observations_by_candidate.(candidates{j}) = k_in(:,j).'; 
end

passed_true = kmin; % initialize kmin, same size as kmin
    
% ------ PART II ----- For each loser, compute pvalues---- 
for j = losers
	% Compute new relevant ballots drawn
	this_draw = k_in(round,winner) + k_in(round,j) - currently_drawn_ballots;
	% Winning vote distributions for each hypothesis
	CurrentTierStop(j,:) = R2CurrentTier(margin(j),CurrentTierStop(j,:),this_draw);
	CurrentTierRisk(j,:) = R2CurrentTier(0, CurrentTierRisk(j,:), this_draw);
            
	% Compute pvalue and likelihood ratio
	[pvalue(j,round), LR(j,round)] = p_value(margin(j), StopSched(j,:), ...
        RiskSched(j,:), CurrentTierStop(j,:), CurrentTierRisk(j,:), ...
        k_in(round,winner) + k_in(round,j), k_in(round,winner), audit_method);
        dvalue(j,round) = 1/LR(j,round);
            
	% Compute kmin to get stop and risk schedules and 
	% current tier and stop tier
	kmin(j, round) = AthenaNextkmin(margin(j), alpha, delta, ...
	StopSched(j, :), RiskSched(j, :), CurrentTierStop(j, :), ...
    CurrentTierRisk(j, :), k_in(round,winner) + k_in(round,j), audit_method);
    
    if kmin(j,round) <= (k_in(round,winner) + k_in(round,j))
        % Round is large enough for  non-zero stopping 
        % probability. Compute tails for each hypothesis at kmin
        StopSched(j, round) = sum(CurrentTierStop(j, kmin(round)+1:size(CurrentTierStop,2)));
        RiskSched(j, round) = sum(CurrentTierRisk(j, kmin(round)+1:size(CurrentTierRisk,2)));
    
        % Compute new distribution corresponding to a kmin decision
        CurrentTierStop = CurrentTierStop(1:kmin(round));
        CurrentTierRisk = CurrentTierRisk(1:kmin(round));
	end
            
            % Round is done, update number of relevent ballots for this
            % loser
            currently_drawn_ballots = k_in{s}(round,winner) + ...
                k_in{s}(round,j);
        end % for every round
        
        % All rounds done for this loser. Write into test structure  
        testing.evaluate_risk.(sprintf('test%d',s)).expected.(candidates{j}).kmin = kmin; 
        testing.evaluate_risk.(sprintf('test%d',s)).expected.(candidates{j}).pvalue = pvalue(j, :); 
        testing.evaluate_risk.(sprintf('test%d',s)).expected.(candidates{j}).delta = dvalue(j, :); 
        testing.evaluate_risk.(sprintf('test%d',s)).expected.(candidates{j}).StopSched = StopSched;
        testing.evaluate_risk.(sprintf('test%d',s)).expected.(candidates{j}).RiskSched = RiskSched;
    end % for every loser
    
    % Done with all losers
    % Summary maximum p and d values for each round. Max finds max in each 
    % column. 
    pvalue_max = max(pvalue);
    dvalue_max = max(dvalue);
    
    for round = 1:num_rounds
        passed_true(round) = int8((pvalue_max(round) <= alpha) && ...
            (dvalue_max(round) <= delta));
    end
    passed_found = find(passed_true, 1);
    passed = ~isempty(passed_found);
        
    testing.evaluate_risk.(sprintf('test%d',s)).expected.passed = passed; 
    testing.evaluate_risk.(sprintf('test%d',s)).expected.pvalue = min(pvalue_max); 
    testing.evaluate_risk.(sprintf('test%d',s)).expected.delta = min(dvalue_max); 
end

% Write tests back into testing file
txt = savejson('',testing);
fname3 = '2020_montgomery_pvalue_multiple_round_tests.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

%sprintf('%s',(candidates{winner}),'*')

