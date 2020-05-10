% very basic script to compute Athena first round p-values for Montgomery
% County, Ohio, 2020 primary audit

% Input values
num_tests = 27;
alpha = 0.1;
delta = 1; %default

% Values below are chosen to be max round sizes for 0.9 percentiles for 
% runnerup, and k=kmin+1, kmin, kmin-1. When there is more than one losing 
% candidate, smaller number of votes for that candidate. 
n_in = [17, 18, 19, 42, 42, 42, 17, 17, 17, 49, 49, 49, 19, 19, 19, ...
    9, 11, 11, 39, 39, 40, 33, 33, 33, 86, 86, 86];

k_in{1} = [0, 13, 0, 0, 0, 0, 0, 4, 0, 0, 0]; 
k_in{2} = [0, 12, 1, 0, 0, 0, 0, 5, 0, 0, 0]; 
k_in{3} = [0, 11, 1, 0, 0, 0, 0, 6, 1, 0, 0]; 
k_in{4} = [15, 27];
k_in{5} = [16, 26];
k_in{6} = [17, 25];
k_in{7} = [13, 4];
k_in{8} = [12, 5];
k_in{9} = [11, 6];
k_in{10} = [31, 18];
k_in{11} = [30, 19];
k_in{12} = [29, 20];
k_in{13} = [14, 5];
k_in{14} = [13, 6];
k_in{15} = [12, 7];
k_in{16} = [1, 0, 8];
k_in{17} = [2, 2, 7];
k_in{18} = [3, 2, 6]; 
k_in{19} = [22, 6, 11];
k_in{20} = [21, 6, 12];
k_in{21} = [20, 7, 13];
k_in{22} = [11, 22];
k_in{23} = [12, 21]; 
k_in{24} = [13, 20];
k_in{25} = [35, 51]; 
k_in{26} = [36, 50];
k_in{27} = [37, 49];

% 
% Read election results
fname = '2020_montgomery_formatted.json';
election_computations = loadjson(fileread(fname));

races = fieldnames(election_computations.contests);

for s=1:num_tests
    
    %----------PART 0: error checking and initialization ---- %
    % simple error checking
    if (sum(k_in{s}) ~= n_in(s))
        fprintf('%s, %d \n','error in sum votes', s)
    end
    
    % contest number is ceil(s/3)
    i = ceil(s/3);
    
    % Initialize testing structure
    testing.evaluate_risk.(sprintf('test%d',s)).audit_type = 'athena';
    testing.evaluate_risk.(sprintf('test%d',s)).election = election_computations.name;
    testing.evaluate_risk.(sprintf('test%d',s)).contest = races{i};
    testing.evaluate_risk.(sprintf('test%d',s)).alpha = alpha; 
    testing.evaluate_risk.(sprintf('test%d',s)).round_schedule = n_in(s); 
    
    candidates = fieldnames(election_computations.contests.(races{i}).tally);
    for j=1:size(candidates)
        testing.evaluate_risk.(sprintf('test%d',s)).audit_observations.(candidates{j}) = k_in{s}(j);
    end
    
    votes = zeros(size(candidates)); % initialize vote vector
    pvalue = votes; % initialize pvalues, same size as votes
    dvalue = votes; % initialize dvalues, same size as votes
    
    % ----- PART I ---- Compute necessary properties -------
    for j=1:size(candidates)
        votes(j) = election_computations.contests.(races{i}).tally.(candidates{j});
    end
    % Find max votes
    [votes_max, winner] = max(votes);

    % For each candidate, including winner, compute margin
    relevant_ballots = votes_max + votes;
    margin = (votes_max-votes)./relevant_ballots;
    
    % ------ PART II ----- For each loser, compute pvalue---- 
    losers = (1:size(candidates)); 
    losers(winner) = []; % delete the winner
    
    % look at each losing candidate
    for j = losers
        % Generate winning vote distributions for each hypothesis
        CurrentTierStop = R2CurrentTier(margin(j),(1), k_in{s}(winner) + k_in{s}(j));
        CurrentTierRisk = R2CurrentTier(0,(1), k_in{s}(winner) + k_in{s}(j));
    
        %Compute p value
        [pvalue(j), LR] = p_value(margin(j), (0), (0), CurrentTierStop, ...
            CurrentTierRisk, k_in{s}(winner) + k_in{s}(j), ... 
            k_in{s}(winner), 'Athena');
            dvalue(j) = 1/LR;
            
        % Write into test structure     
        testing.evaluate_risk.(sprintf('test%d',s)).expected.(candidates{j}).passed = int8((pvalue(j) <= alpha) && (dvalue(j) <= delta)); 
        testing.evaluate_risk.(sprintf('test%d',s)).expected.(candidates{j}).pvalue = pvalue(j); 
        testing.evaluate_risk.(sprintf('test%d',s)).expected.(candidates{j}).delta = dvalue(j); 
    end
    
    % Summary p and d values
    [pvalue_max, runnerup] = max(pvalue);
    dvalue_max = max(dvalue);
    
    testing.evaluate_risk.(sprintf('test%d',s)).expected.passed = int8((pvalue_max <= alpha) && (dvalue_max <= delta)); 
    testing.evaluate_risk.(sprintf('test%d',s)).expected.pvalue = pvalue_max; 
    testing.evaluate_risk.(sprintf('test%d',s)).expected.delta = dvalue_max; 
end

% Write tests back into testing file
txt = savejson('',testing);
fname3 = '2020_montgomery_pvalue_new_tests.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

%sprintf('%s',(candidates{winner}),'*')

