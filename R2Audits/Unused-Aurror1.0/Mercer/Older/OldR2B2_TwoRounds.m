% This script compares two-round R2B2 audits based on BRAVO without 
% replacement, beginning with
%       votes_1:                    votes for candidate 1
%       votes_2:                    votes for candidate 2
%       vote_total:                 total ballots cast
%       alpha:                      risk limit
%       max_polled_ballots:         maximum number of ballots to be polled
%       first_round_size:           row vector of samples in first round
% Anticipated use: plan an audit, between the announcement of 
% rough election results and the audit itself. 
%
% The script generates, mainly, stopping probabilities for many
% two-round audits. 

% Input
votes_1=17820;
votes_2=21780;
vote_total=44000;
alpha=0.1;
max_polled_ballots=800;
first_round_size = [100:100:max_polled_ballots-100]; % arbitrary

% Book keeping
votes_winner = max(votes_1, votes_2);
votes_loser = min(votes_1, votes_2);
margin = (votes_winner-votes_loser)/(votes_winner + votes_loser);
p = votes_winner/(votes_winner + votes_loser);
invalid_votes = vote_total - (votes_1+votes_2);
invalid_rate = invalid_votes/vote_total;
max_polled_ballots_voted = (1-invalid_rate)*max_polled_ballots;
first_round_voted_size = (1-invalid_rate)*first_round_size;
audit_type = 0; % with replacement

% Generate BRAVO kmin upto 6*ASN
[kmslope, kmintercept, n, kmin] = BSquareBRAVOkmin(margin,alpha);

% number of samples for B-square risk ranges from first possible sample 
% size for BRAVO to max_polled_ballots_voted
n_bravo = n(1:max_polled_ballots_voted-n(1)+1); 
kmin_bravo = kmin(1:max_polled_ballots_voted-n(1)+1);

% Number of possible sample sizes for first round
num_possible = size(n_bravo,2);

% B-square risk schedule for BRAVO, limited to max_polled_ballots_voted
[RiskSched, RiskValue, ExpectedBallots] = BSquareRisks(0, vote_total, n_bravo, kmin_bravo, audit_type);

[StopSched, StopProb, ExpectedBallots] = BSquareRisks(margin, vote_total, n_bravo, kmin_bravo, audit_type);

% One round audit for comparison
kmin_one_round = binoinv(1-RiskValue, max_polled_ballots_voted, 0.5)+1;
RiskValue_one_round = binocdf(kmin_one_round-1, max_polled_ballots_voted, 0.5, 'upper');
StopProb_one_round = binocdf(kmin_one_round-1, max_polled_ballots_voted, p, 'upper');

%Initialize
% These values are temp values for computations in the for loop
GoalRiskSched = zeros(1,2);
GoalStopSched = zeros(1,2);
StopSchedR2 = zeros(1,2);
RiskSchedR2 = zeros(1,2);
StopSchedB2 = zeros(1,2);
RiskSchedB2 = zeros(1,2);
% These stay beyond the loop and form the output
CStopSchedR2 = zeros(1, size(n_bravo,2));
CRiskSchedR2 = zeros(1, size(n_bravo,2));
FirstStopProbR2 = zeros(1, size(n_bravo,2));
CGoalRiskSched = zeros(1, size(n_bravo,2));
CGoalStopSched = zeros(1, size(n_bravo,2));
CStopSchedB2 = zeros(1, size(n_bravo,2));
CRiskSchedB2 = zeros(1, size(n_bravo,2));
FirstStopProbB2 = zeros(1, size(n_bravo,2));

% For all possible sizes for the first round
nfornow = first_round_voted_size-n_bravo(1)+1; % translate round size to index into kmin

for i = nfornow
    % For round by round BRAVO, rounds: [first_round_voted_size, max_voted_ballots];
    nB2 = [n_bravo(i), max_polled_ballots_voted];
    kminB2 = [kmin_bravo(i), kmin_bravo(num_possible)];
    [StopSchedB2, StopProbB2, ExpectedBallotsB2] = RSquareRisks(margin, vote_total, nB2, kminB2, audit_type);
    [RiskSchedB2, RiskValueB2, ExpectedBallots] = RSquareRisks(0, vote_total, nB2, kminB2, audit_type);

    % Desired risk schedule for the RSquare audit
    GoalRiskSched(1) = sum(RiskSched(1,1:i));
    GoalRiskSched(2) = sum(RiskSched(1,i+1:num_possible));
    
    % Stopping probs for comparison 
    GoalStopSched(1) = sum(StopSched(1,1:i));
    GoalStopSched(2) = sum(StopSched(1,i+1:num_possible));
    
    % kmins for the RSquare audit defined by risk schedule
    [kminR2, RiskSchedR2, RiskValueR2, ExpectedBallots] = RSquareInvRisks(0, vote_total, nB2, GoalRiskSched, audit_type);
    
    % stopping probs with this kmin
    [StopSchedR2, StopProbR2, ExpectedBallotsR2] = RSquareRisks(margin, vote_total, nB2, kminR2, audit_type);
    
    % Compute cumulative probabilities
    CStopSchedR2(i) =  StopProbR2;
    CRiskSchedR2(i) =  RiskValueR2;
    CGoalRiskSched(i) = GoalRiskSched(1)+ GoalRiskSched(2);
    CGoalStopSched(i) = GoalStopSched(1)+ GoalStopSched(2);
    CStopSchedB2(i) =  StopProbB2;
    CRiskSchedB2(i) =  RiskValueB2;
    % First round stopping
    FirstStopProbR2(i) = StopSchedR2(1);
    FirstStopProbB2(i) = StopSchedB2(1);
end

%Display
% plot(first_round_size, CStopSchedR2(nfornow), 'b*', first_round_size, CStopSchedB2(nfornow), 'r+', first_round_voted_size, StopProb_one_round, 'm^',first_round_size, CGoalStopSched(nfornow), 'o');
plot(first_round_size, CStopSchedR2(nfornow), 'b*', first_round_size, FirstStopProbR2(nfornow), 'r+', first_round_voted_size, StopProb_one_round, 'm^');
% plot(first_round_size, CRiskSchedR2(nfornow), 'b*', first_round_size, CRiskSchedB2(nfornow), 'r+', first_round_size, RiskValue_one_round, 'm^',first_round_size, CGoalRiskSched(nfornow), 'o');