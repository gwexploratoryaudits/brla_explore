% Generating a graph that compares the stopping probability values for
% different round sizes using the new irrelevant ballot approach. This
% graph is comparable to the Stopping.pdf in the Scripts folder.

% Load JSON file with election data
fname = '../2020_montgomery_official.json';
election_computations = loadjson(fileread(fname));
races = fieldnames(election_computations.contests);
round = 1;

names = {'d\_president','d\_congress', 'd\_senator', 'd\_cc\_1\_2\_2021', 'd\_cc\_1\_3\_2021', 'r\_10th', 'r\_senator', 'r\_42nd', 'r\_cc\_1\_2\_2021'};
colors = {'#FF7F50', 'g', '#006400', 'm', '#6495ED', 'c', 'k', 'r', 'b'};
markers = {'o', '+', '*', '>', 's', '^', 'd', 'h', 'v'};


% Compute data for each race in the election
for i=1:size(races,1)
    
    % Read candidate list
    candidates = fieldnames(election_computations.contests.(races{i}).tally);
    votes = zeros(size(candidates));
    
    for j=1:size(candidates,1)
        votes(j) = election_computations.contests.(races{i}).tally.(candidates{j});
    end
    
    % Find max votes
    [votes_max, winner] = max(votes);
    
    % list of all losing candidate (numbers)
    losers = (1:size(candidates,1)); 
    losers(winner) = []; % delete the winner
    
    % Initialization parameters below
    n_last = zeros(size(candidates));
    for j=1:size(candidates,1)
        CurrentTierStop{j} = (1);
    end
    CurrentTierRisk = CurrentTierStop;
    StopSched = zeros(size(candidates));
    RiskSched = StopSched;
    k_last = 0;
    next_rounds_max = zeros(size(candidates,1), size(percentiles,2));
    Stopping = zeros(size(candidates,1), max_ballots(round));
    
    alpha = 0.1;
    delta = 1;
    audit_method = "Athena";
    max_ballots(round) = 350;
    percentiles = [.7,.8,.9];
    
    difference_fraction = (votes_max/election_computations.total_ballots) - (votes/election_computations.total_ballots);
    irrelevant_fraction = (election_computations.total_ballots - (votes_max+votes)) / election_computations.total_ballots;
    
    % For each loser, compute stop probs for round sizes 1 to max_ballots
    for j = losers 
        
        [next_rounds_max(j,:), next_rounds_min(j,:), n, kmin, Stopping(j,:)]  = ...
        RangeNextRoundSizes_IrrelevantBallots(difference_fraction(j), alpha, delta, StopSched(j,:), ...
        RiskSched(j,:), CurrentTierStop{j}, CurrentTierRisk{j}, ...
        n_last(j,round), k_last(round), percentiles, ...
        n_last(j,round)+max_ballots(round), audit_method, irrelevant_fraction(j));
    
    end
    
    % Find largest rounds
    [largest_max_round_size, max_round_cand] = max(next_rounds_max);
    
    x = 1:max_ballots(round);
    y = Stopping(max_round_cand,:);
    color = colors{i};
    name = sprintf("%s",names{i});
    marker = markers{i};
    plot(x,y(1,:),'color',color,'DisplayName',name);
    hold on
    plot(x(1:10:350),y(1,1:10:350),marker,'color',color,'DisplayName', '');
    hold on

end
xlabel('Sample size (in total ballots, including irrelevant ones)');
ylabel('Probability of stopping');
title('Stopping Probability vs. Sample Size');
hold off
legend show



