% Generates graph of stopping probabilites for different round sizes for
% the r_42nd race in the Montgomery primary using both the original
% approach and the irrelevant ballot approach to see how they compare

% Load JSON file with election data
fname = '../2020_montgomery_official.json';
election_computations = loadjson(fileread(fname));
races = fieldnames(election_computations.contests);
round = 1;

candidates = fieldnames(election_computations.contests.r_42nd.tally);
votes = zeros(size(candidates));

for j=1:size(candidates,1)
    votes(j) = election_computations.contests.r_42nd.tally.(candidates{j});
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

alpha = 0.1;
delta = 1;
audit_method = "Athena";
max_ballots(round) = 350;
percentiles = [.7,.8,.9];

relevant_ballots = votes_max + votes;
margin = (votes_max-votes)./relevant_ballots;
% factor to scale up raw values
factor = election_computations.total_ballots./relevant_ballots;
    
difference_fraction = (votes_max/election_computations.total_ballots) - (votes/election_computations.total_ballots);
irrelevant_fraction = (election_computations.total_ballots - (votes_max+votes)) / election_computations.total_ballots;

% Initialize arrays that will be rewritten for each round
next_rounds_max_scaled = zeros(size(candidates,1), size(percentiles,2));
next_rounds_min_scaled = next_rounds_max_scaled;
next_rounds_max_irrelevant = next_rounds_max_scaled;
next_rounds_min_irrelevant = next_rounds_max_scaled;
next_rounds_max = next_rounds_max_scaled;
next_rounds_min = next_rounds_max_scaled;
Stopping = zeros(size(candidates,1), max_ballots(round));
Stopping_irrelevant = zeros(size(candidates,1), max_ballots(round));

% For each loser, compute stop probs for round sizes 1 to max_ballots
for j = losers 
        
    [next_rounds_max_irrelevant(j,:), next_rounds_min_irrelevant(j,:), n, kmin, Stopping_irrelevant(j,:)]  = ...
        RangeNextRoundSizes_IrrelevantBallots(difference_fraction(j), alpha, delta, StopSched(j,:), ...
        RiskSched(j,:), CurrentTierStop{j}, CurrentTierRisk{j}, ...
        n_last(j,round), k_last(round), percentiles, ...
        n_last(j,round)+max_ballots(round), audit_method, irrelevant_fraction(j));
    
    [next_rounds_max(j,:), next_rounds_min(j,:), n, kmin, Stopping]  = ...
        RangeNextRoundSizes(margin(j), alpha, delta, StopSched(j,:), ...
        RiskSched(j,:), CurrentTierStop{j}, CurrentTierRisk{j}, ...
        n_last(j,round), k_last(round), percentiles, ...
        n_last(j,round)+floor(max_ballots(round)/factor(j)), audit_method);
    
    next_rounds_max_scaled(j,:) = ceil(factor(j)*next_rounds_max(j,:));
    next_rounds_min_scaled(j,:) = ceil(factor(j)*next_rounds_min(j,:));
    
end

% Find largest rounds
[largest_max_round_size, max_round_cand] = max(next_rounds_max_scaled);
[largest_max_round_size_irrelevant, max_round_cand_irrelevant] = max(next_rounds_max_irrelevant);

x1 = n.*factor(max_round_cand);
y1 = Stopping(max_round_cand,:);
x2 = 1:max_ballots(round);
y2 = Stopping_irrelevant(max_round_cand_irrelevant,:);

a = plot(x1(1,:),y1(1,:),'color','r','DisplayName', 'Original Approach');
hold on
b = plot(x2,y2(1,:),'color','b','DisplayName', 'New Approach');
yline(0.1,'-.k');
yline(0.2,'-.k');
yline(0.3,'-.k');
yline(0.4,'-.k');
yline(0.5,'-.k');
yline(0.6,'-.k');
yline(0.7,'-.k');
yline(0.8,'-.k');
yline(0.9,'-.k');
hold off;
legend([a b],'Location','East');
xlabel('Sample size');
ylabel('Probability of stopping');
title('Stopping Probability vs. Round Sizes (r\_42nd)');

