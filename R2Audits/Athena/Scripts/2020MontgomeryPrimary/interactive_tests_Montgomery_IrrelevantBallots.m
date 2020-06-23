% very basic script to compute Athena MULTIPLE rounds for Montgomery
% County, Ohio, 2020 primary audit
% New Irrelevant Ballot estimates!
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
    races = fieldnames(election_computations.contests);

    % interactively insert other parameters of choice
    fprintf('This is the first round of the audit, enter audit parameters \n')
    race = input('Contest name as a string: ')
    alpha = input('Risk limit, alpha, as a fraction: ')
    percentiles = input('Percentiles as a row vector of size 3: ')
    audit_method = input('audit method as a string: ')
    % add input for irrelevant ballot fraction
    irrelevant_fraction = input('Fraction of irrelevant ballots as a fraction: ')
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
        RangeNextRoundSizes_IrrelevantBallots(margin(j), alpha, delta, StopSched(j,:), ...
        RiskSched(j,:), CurrentTierStop{j}, CurrentTierRisk{j}, ...
        n_last(j,round), k_last(round), percentiles, ...
        n_last(j,round)+floor(max_ballots(round)/factor(j)), audit_method, irrelevant_fraction);
    
    %next_rounds_max_scaled(j,:) = ceil(factor(j)*next_rounds_max(j,:));
    %next_rounds_min_scaled(j,:) = ceil(factor(j)*next_rounds_min(j,:)); 
    kmin_max(j,:) = kmin(next_rounds_max(j,:));
    kmin_min(j,:) = kmin(next_rounds_min(j,:));
    stop_max(j,:) = Stopping(next_rounds_max(j,:));
    stop_min(j,:) = Stopping(next_rounds_min(j,:));
end