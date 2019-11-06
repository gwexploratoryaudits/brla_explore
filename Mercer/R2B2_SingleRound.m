% This script compares single-round R2B2 audits based on BRAVO with 
% replacement, beginning with
%       votes_1:                    votes for candidate 1
%       votes_2:                    votes for candidate 2
%       vote_total:                 total ballots cast
%       alpha:                      risk limit
%       percentile:                 target stopping probability
% Anticipated use: plan an audit, between the announcement of 
% rough election results and the audit itself. 
%
% The script generates stopping probabilities and risks for many
% single-round audits. 
%
% Note: "invalid" is used to include both invalid votes and irrelevant ones. 

% Input
% For amendment
% votes_1=14970;
% votes_2=5257;

% Superior court judge
votes_1=8050;
votes_2=11435;

% Court of Common Pleas
% votes_1=10160;
% votes_2=11838;

% County Commissioner
% votes_1=10238;
% votes_2=11949;
 
vote_total=23563;
alpha=0.1;
percentile = 0.9;

% Book keeping
votes_winner = max(votes_1, votes_2);
votes_loser = min(votes_1, votes_2);
margin = (votes_winner-votes_loser)/(votes_winner + votes_loser);
p = votes_winner/(votes_winner + votes_loser);
invalid_votes = vote_total - (votes_1+votes_2);
invalid_rate = invalid_votes/vote_total;
audit_type = 0; % with replacement

% BEGIN: Looking only at valid votes
% ----------------------------------

% STEP ONE: Generate BRAVO kmins, risk schedule and stopping schedule

% Generate B2 BRAVO kmin upto 6*ASN
[kmslope, kmintercept, n, kmin] = BSquareBRAVOkmin(margin,alpha);

% number of samples for B2 risk ranges from first possible sample 
% size for BRAVO to 4.5*ASN which might take us to 90th percentile for 
% R2 BRAVO and 99th for B2 BRAVO, and is our value for maximum number of 
% valid ballots that will be drawn in the polling audit. We could have
% stayed with 6*ASN, but this step dominates the complexity, and any 
% reduction has impact. 
Average_Sample_Number = ASN(margin,alpha);
max_polled_ballots_voted = ceil(4.5*Average_Sample_Number); 
n_bravo = n(1:max_polled_ballots_voted-n(1)+1); 
kmin_bravo = kmin(1:max_polled_ballots_voted-n(1)+1);
num_possible = size(n_bravo,2);

% Risk schedule for BRAVO, limited to max_polled_ballots_voted. 
% Note that vote_total is needed only to compute average number of ballots 
% drawn in audits with replacement. 
[RiskSched, RiskValue, ExpectedBallots] = BSquareRisks(0, vote_total, n_bravo, kmin_bravo, audit_type);

% Cumulative BRAVO risk schedule
GoalRiskSched = CumDistFunc(RiskSched);

% Stopping schedule for BRAVO
[StopSched, StopProb, ExpectedBallots] = BSquareRisks(margin, vote_total, n_bravo, kmin_bravo, audit_type);

% Cumulative BRAVO stopping schedule
GoalStopSched = CumDistFunc(StopSched);

% STEP TWO: Initialize all arrays for values to be computed: 
% AURROR kmins; AURROR and Arlo risk schedules and stopping probabilities; 
% Use-up-all-risk-in-one-round values if desired. 

% AURROR kmin, stopping probabilities and risk, to be computed as a 
% function of number of ballots drawn. 
kmin_oneround_R2 = zeros(1,num_possible);
RiskValue_one_round_R2 = zeros(1,num_possible);
StopProb_one_round_R2 = zeros(1,num_possible);

% Arlo stopping probabilities and risk, to be computed as a function of 
% number of ballots drawn, using B2 BRAVO kmins.  
RiskValue_one_round_B2 = zeros(1,num_possible);
StopProb_one_round_B2 = zeros(1,num_possible);

% Use following if wish to use up all risk in one round. 
% kmin_oneround_all_risk = zeros(1,num_possible);
% RiskValue_one_round_all_risk = zeros(1,num_possible);
% StopProb_one_round_all_risk = zeros(1,num_possible);

% STEP THREE: for coarsely chosen round sizes, compute these values. 

% For the following sample size indices
% Change this for finer or coarser sampling. Right now this gives us about
% 18 samples. 
sample_size_indices = (ceil(Average_Sample_Number/4):ceil(Average_Sample_Number/4):num_possible);

% For the one round audits
for i=sample_size_indices 
    % AURROR kmin
    kmin_oneround_R2(i) = binoinv(1-GoalRiskSched(i), n_bravo(i), 0.5);
    
    % Use-up-all-risk kmin
    % kmin_oneround_all_risk(i) = binoinv(1-alpha, n_bravo(i), 0.5);
    
    % AURROR risk and stopping
    RiskValue_one_round_R2(i) = binocdf(kmin_oneround_R2(i), n_bravo(i), 0.5, 'upper');
    StopProb_one_round_R2(i) = binocdf(kmin_oneround_R2(i), n_bravo(i), p, 'upper');
    
    % Use-up-all-risk risk and stopping
    % RiskValue_one_round_all_risk(i) = binocdf(kmin_oneround_all_risk(i), n_bravo(i), 0.5, 'upper');
    % StopProb_one_round_all_risk(i) = binocdf(kmin_oneround_all_risk(i), n_bravo(i), p, 'upper');
    
    % Arlo risk and stopping, using BRAVO kmins
    RiskValue_one_round_B2(i) = binocdf(kmin_bravo(i), n_bravo(i), 0.5, 'upper');
    StopProb_one_round_B2(i) = binocdf(kmin_bravo(i), n_bravo(i), p, 'upper');
end

% END: Looking at valid ballots. 
% -------------------

% To plot as a function of total ballots, including invalid ones
scale_up = 1/(1-invalid_rate);
n_bravo_scaled_up = round(scale_up*(n_bravo));

% Files to print figures to
% filenames = {'Amendment_point1_kmins', 'Amendment_point1_stopping', 'Amendment_point1_risk'};
filenames = {'Superior_point1_kmins', 'Superior_point1_stopping', 'Superior_point1_risk'};
% filenames = {'Common_point1_kmins', 'Common_point1_stopping', 'Common_point1_risk'};
% filenames = {'Commissioner_point4_kmins', 'Commissioner_point4_stopping', 'Commissioner_point4_risk'};

figure, plot(n_bravo_scaled_up(sample_size_indices), kmin_oneround_R2(sample_size_indices), 'b*', n_bravo_scaled_up(sample_size_indices), kmin_bravo(sample_size_indices), 'ro');
xlabel('Round size');
ylabel('(rough estimate) Minimum number of ballots for winner required to stop the audit'); 
% title('Minimum number of winner votes needed to stop audit: Amendment risk limit = 0.1');
title('Minimum number of winner votes needed to stop audit: Superior Court risk limit = 0.1');
% title('Minimum number of winner votes needed to stop audit: Common Pleas risk limit = 0.1');
% title('Minimum number of winner votes needed to stop audit: County Commissioner risk limit = 0.4');
legend('AURROR', 'BRAVO', 'Location', 'northwest');
print('-djpeg90', filenames{1});

figure, plot(n_bravo_scaled_up(sample_size_indices), StopProb_one_round_R2(sample_size_indices), 'b*', n_bravo_scaled_up(sample_size_indices), GoalStopSched(sample_size_indices), 'ro', n_bravo_scaled_up(sample_size_indices), StopProb_one_round_B2(sample_size_indices), 'k^');
xlabel('Round size');
ylabel('(rough estimate) Stopping Probability'); 
% title('Stopping Probabilities: Amendment risk limit = 0.1');
title('Stopping Probabilities: Superior Court risk limit = 0.1');
% title('Stopping Probabilities: Common Pleas risk limit = 0.1');
% title('Stopping Probabilities: County Commissioner risk limit = 0.4');
legend('AURROR', 'BRAVO', 'Arlo?', 'Location', 'northwest');
print('-djpeg90', filenames{2});

figure, plot(n_bravo_scaled_up(sample_size_indices), RiskValue_one_round_R2(sample_size_indices), 'b*', n_bravo_scaled_up(sample_size_indices), GoalRiskSched(sample_size_indices), 'ro', n_bravo_scaled_up(sample_size_indices), RiskValue_one_round_B2(sample_size_indices), 'k^');
xlabel('Round size');
ylabel('(rough estimate) Risk Expended'); 
% title('Risk Expended: Amendment risk limit = 0.1');
title('Risk Expended: Superior Court risk limit = 0.1');
% title('Risk Expended: Common Pleas risk limit = 0.1');
% title('Risk Expended: County Commissioner risk limit = 0.4');
legend('AURROR', 'BRAVO', 'Arlo?', 'Location', 'northwest');
print('-djpeg90', filenames{3});

% Number of total ballots to poll, valid and others, for required percentile 
aurror_stop_raw = n_bravo(sample_size_indices(InverseCDF(StopProb_one_round_R2(sample_size_indices), percentile)));
aurror_stop = n_bravo_scaled_up(sample_size_indices(InverseCDF(StopProb_one_round_R2(sample_size_indices), percentile)))
bravo_stop_raw = n_bravo(sample_size_indices(InverseCDF(GoalStopSched(sample_size_indices), percentile)));
bravo_stop = n_bravo_scaled_up(sample_size_indices(InverseCDF(GoalStopSched(sample_size_indices), percentile)))
bravo_R2_stop_raw = n_bravo(sample_size_indices(InverseCDF(StopProb_one_round_B2(sample_size_indices), percentile)));
bravo_R2_stop = n_bravo_scaled_up(sample_size_indices(InverseCDF(StopProb_one_round_B2(sample_size_indices), percentile)))

% Embarassment Probabilities for these sample sizes: using valid ballot
% numbers
aurror_embarassment = binocdf(ceil(aurror_stop_raw/2), aurror_stop_raw, p)
arlo_embarassment = binocdf(ceil(bravo_R2_stop_raw/2), bravo_R2_stop_raw, p)

% If wish to include use-all-risk-in-one-round:
% all_risk_stop = n_bravo_scaled_up(sample_size_indices(InverseCDF(StopProb_one_round_all_risk(sample_size_indices), percentile)))