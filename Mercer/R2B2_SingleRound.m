% This script compares single-round R2B2 audits based on BRAVO without 
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

% We use test input from 2017 elections in Mercer County, CA. 
% Ballots Cast: 19,821
% CONSTITUTIONAL AMENDMENT
% YES	8,193
% NO	8,611

% THOMAS G. SAYLOR RETENTION
% YES	11,183
% NO	4,744

% DEBRA TODD RETENTION
% YES	10,951
% NO	4,809

% JACQUELINE O. SHOGAN RETENTION
% YES	11,035
% NO	4,683

% Input
% votes_1=8193;
% votes_2=8611;
votes_1 = 11183;
votes_2 = 4744;

vote_total=19821;
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

% Looking only at valid votes
% Generate BRAVO kmin upto 6*ASN
[kmslope, kmintercept, n, kmin] = BSquareBRAVOkmin(margin,alpha);

% number of samples for B-square risk ranges from first possible sample 
% size for BRAVO to 4.5*ASN which might take us to 90th percentile for 
% R2 BRAVO and 99th for B2 BRAVO
max_polled_ballots_voted = ceil(4.5*ASN(margin,alpha)); 
n_bravo = n(1:max_polled_ballots_voted-n(1)+1); 
kmin_bravo = kmin(1:max_polled_ballots_voted-n(1)+1);
num_possible = size(n_bravo,2);

% B-square risk schedule for BRAVO, limited to max_polled_ballots_voted
[RiskSched, RiskValue, ExpectedBallots] = BSquareRisks(0, vote_total, n_bravo, kmin_bravo, audit_type);
GoalRiskSched = CumDistFunc(RiskSched);

[StopSched, StopProb, ExpectedBallots] = BSquareRisks(margin, vote_total, n_bravo, kmin_bravo, audit_type);
GoalStopSched = CumDistFunc(StopSched);

% Initialize
kmin_oneround_R2 = zeros(1,num_possible);
RiskValue_one_round_R2 = zeros(1,num_possible);
StopProb_one_round_R2 = zeros(1,num_possible);
RiskValue_one_round_B2 = zeros(1,num_possible);
StopProb_one_round_B2 = zeros(1,num_possible);

% For the following sample size indices
sample_size_indices = (10:10:num_possible);

% One round audit
for i=sample_size_indices 
    % R-square
    kmin_oneround_R2(i) = binoinv(1-GoalRiskSched(i), n_bravo(i), 0.5);
    RiskValue_one_round_R2(i) = binocdf(kmin_oneround_R2(i), n_bravo(i), 0.5, 'upper');
    StopProb_one_round_R2(i) = binocdf(kmin_oneround_R2(i), n_bravo(i), p, 'upper');
    RiskValue_one_round_B2(i) = binocdf(kmin_bravo(i), n_bravo(i), 0.5, 'upper');
    StopProb_one_round_B2(i) = binocdf(kmin_bravo(i), n_bravo(i), p, 'upper');
end

% Plot as a function of total ballots, including invalid ones
scale_up = 1/(1-invalid_rate);
n_bravo_scaled_up = round(scale_up*(n_bravo));

% Files to print figures to
filenames = {'Saylor_point1_kmins', 'Saylor_point1_stopping', 'Saylor_point1_risk'};

figure, plot(n_bravo_scaled_up(sample_size_indices), kmin_oneround_R2(sample_size_indices), 'b*', n_bravo_scaled_up(sample_size_indices), kmin_bravo(sample_size_indices), 'ro');
xlabel('Round size');
ylabel('(rough estimate) Minimum number of ballots for winner required to stop the audit'); 
title('Minimum number of winner votes needed to stop audit: Saylor Retention: risk limit = 0.1');
legend('TUNERR', 'BRAVO', 'Location', 'northwest');
print('-djpeg90', filenames{1});

figure, plot(n_bravo_scaled_up(sample_size_indices), StopProb_one_round_R2(sample_size_indices), 'b*', n_bravo_scaled_up(sample_size_indices), GoalStopSched(sample_size_indices), 'ro', n_bravo_scaled_up(sample_size_indices), StopProb_one_round_B2(sample_size_indices), 'k^');
xlabel('Round size');
ylabel('(rough estimate) Stopping Probability'); 
title('Stopping Probabilities: Saylor Retention: risk limit = 0.1');
legend('TUNERR', 'B2 BRAVO', 'R2 BRAVO', 'Location', 'northwest');
print('-djpeg90', filenames{2});

figure, plot(n_bravo_scaled_up(sample_size_indices), RiskValue_one_round_R2(sample_size_indices), 'b*', n_bravo_scaled_up(sample_size_indices), GoalRiskSched(sample_size_indices), 'ro', n_bravo_scaled_up(sample_size_indices), RiskValue_one_round_B2(sample_size_indices), 'k^');
xlabel('Round size');
ylabel('(rough estimate) Risk Expended'); 
title('Risk Expended: Saylor Retention question: risk limit = 0.1');
legend('TUNERR', 'B2 BRAVO', 'R2 BRAVO', 'Location', 'northwest');
print('-djpeg90', filenames{3});

% Number of total ballots to poll, including invalid ones. 
tunerr_stop = n_bravo_scaled_up(sample_size_indices(InverseCDF(StopProb_one_round_R2(sample_size_indices), percentile)))
bravo_stop = n_bravo_scaled_up(sample_size_indices(InverseCDF(GoalStopSched(sample_size_indices), percentile)))
bravo_R2_stop = n_bravo_scaled_up(sample_size_indices(InverseCDF(StopProb_one_round_B2(sample_size_indices), percentile)))