% very basic script to compute Athena MULTIPLE rounds for Montgomery
% County, Ohio, 2020 primary audit

% Input values
num_tests = 9;
alpha = 0.1;
delta = 1; %default

% In the first data points for each contest, first rounds below are 
% chosen to be max round sizes for 0.9 percentiles for runnerup, and 
% k=kmin-1. When there is more than one losing candidate, smaller 
% number of votes for that candidate. Second rounds are about 1.5 the 
% size of the first one, as are k. The next two data points are 
% chosen at whim. . 
n_in = [19, 29; 16, 45; 22, 29; ...
    42, 63; 27, 54; 31, 62; ...
    17, 26; 12, 24; 40, 80];

k_in{1} = [0, 11, 1, 0, 0, 0, 0, 6, 1, 0, 0; 0, 17, 1, 0, 0, 0, 0, 10, 1, 0, 0]; 
k_in{2} = [0, 10, 1, 0, 0, 0, 0, 4, 1, 0, 0; 1, 20, 1, 1, 1, 1, 1, 17, 1, 1, 0]; 
k_in{3} = [0, 11, 1, 0, 0, 0, 0, 9, 1, 0, 0; 0, 17, 1, 0, 0, 0, 0, 10, 1, 0, 0]; 

k_in{4} = [17, 25; 26, 37];
k_in{5} = [10, 17; 20, 34];
k_in{6} = [12, 19; 24, 38];

k_in{7} = [11, 6; 16, 10];
k_in{8} = [8, 4; 16, 8];
k_in{9} = [27, 13; 54, 26];

% 
% Read election results
fname = '2020_montgomery_formatted.json';
election_computations = loadjson(fileread(fname));

% ---- Done with input values --- %

races = fieldnames(election_computations.contests);

for s=1:num_tests
    
    %----------PART 0: error checking and initialization ---- %
    % simple error checking
    
    if (size(k_in{s},1) ~= size(n_in,2)) % round sizes don't match
        fprintf('%s, %d \n','round size mismatch, test', s)
    else
        num_rounds = size(n_in,2);
        for round=1:num_rounds
            if (sum(k_in{s}(round,:)) ~= n_in(s,round)) % sample size mismatch
                fprintf('%s, %d, %s, %d\n','sample size mismatch, test', s, 'round', round)
            end
        end
    end

    % contest number is ceil(s/3)
    i = ceil(s/3);
    
    % Initialize testing structure
    testing.evaluate_risk.(sprintf('test%d',s)).audit_type = 'athena';
    testing.evaluate_risk.(sprintf('test%d',s)).election = election_computations.name;
    testing.evaluate_risk.(sprintf('test%d',s)).contest = races{i};
    testing.evaluate_risk.(sprintf('test%d',s)).alpha = alpha; 
    testing.evaluate_risk.(sprintf('test%d',s)).round_schedule = n_in(s, :); 
    
    candidates = fieldnames(election_computations.contests.(races{i}).tally);
    for j=1:size(candidates)
        testing.evaluate_risk.(sprintf('test%d',s)).audit_observations.(candidates{j}) = k_in{s}(:, j).';
    end
    
    votes = zeros(size(candidates)); % initialize vote vector
    pvalue = zeros(size(candidates, 1), num_rounds); % initialize pvalues, same size as votes
    dvalue = pvalue; % initialize dvalues, same size as pvalues
    
    kmin = zeros(1, num_rounds); % initialize kmin
    passed_true = kmin; % initialize kmin, same size as kmin
   
    % ----- PART I ---- Compute necessary properties -------
    for j=1:size(candidates)
        votes(j) = election_computations.contests.(races{i}).tally.(candidates{j});
    end
    % Find max votes
    [votes_max, winner] = max(votes);

    % For each candidate, including winner, compute margin
    relevant_ballots = votes_max + votes;
    margin = (votes_max-votes)./relevant_ballots;
    
    % ------ PART II ----- For each loser, compute pvalues---- 
    losers = (1:size(candidates)); 
    losers(winner) = []; % delete the winner
    
    % look at each losing candidate
    for j = losers
        currently_drawn_ballots = 0;
        CurrentTierStop = (1);
        CurrentTierRisk = (1);
        StopSched = (0);
        RiskSched = (0);
        
        for round = 1:num_rounds
            % Compute new relevant ballots drawn
            this_draw = k_in{s}(round,winner) + k_in{s}(round,j) - ...
                currently_drawn_ballots;
            
            % Winning vote distributions for each hypothesis
            CurrentTierStop = R2CurrentTier(margin(j),CurrentTierStop,this_draw);
            CurrentTierRisk = R2CurrentTier(0, CurrentTierRisk, this_draw);
            
            % Compute pvalue and likelihood ratio
            [pvalue(j,round), LR] = p_value(margin(j), StopSched, ...
                RiskSched, CurrentTierStop, CurrentTierRisk, ...
                k_in{s}(round,winner) + k_in{s}(round,j), ... 
                k_in{s}(round,winner), 'Athena');
            dvalue(j,round) = 1/LR;
            
            % Compute kmin to get stop and risk schedules and 
            % current tier and stop tier
            kmin(round) = AthenaNextkmin(margin(j), alpha, delta, ...
                StopSched, RiskSched, CurrentTierStop, CurrentTierRisk, ...
                k_in{s}(round,winner) + k_in{s}(round,j), 'Athena');
            
            if kmin(round) <= (k_in{s}(round,winner) + k_in{s}(round,j))
                % Round is large enough for  non-zero stopping 
                % probability. Compute tails for each hypothesis at kmin
                StopSched(round) = sum(CurrentTierStop(kmin(round)+1:size(CurrentTierStop,2)));
                RiskSched(round) = sum(CurrentTierRisk(kmin(round)+1:size(CurrentTierRisk,2)));
    
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

