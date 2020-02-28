% This script tries out a two-round R2B2 audit based on BRAVO without 
% replacement, beginning with
%       votes_1:                    votes for candidate 1
%       votes_2:                    votes for candidate 2
%       vote_total:                 total ballots cast
%       alpha:                      risk limit
%       max_polled_ballots:         maximum number of ballots to be polled
%       first_round_size:           samples in first round
% Anticipated use: exposition on how to plan an audit, between the announcement of 
% rough election results and the audit itself. 
%
% The script generates, mainly, stopping probabilities for a given
% two-round audit. 

% Input: change plot titles if these values are changed
votes_1=17820;
votes_2=21780;
vote_total=44000;
alpha=0.1; 
max_polled_ballots=1000;
first_round_size = 400; % arbitrary, can be row vector

%------------------ Code Begins ------------------%
% Book keeping
votes_winner = max(votes_1, votes_2);
votes_loser = min(votes_1, votes_2);
margin = (votes_winner-votes_loser)/(votes_winner + votes_loser);
invalid_votes = vote_total - (votes_1+votes_2);
invalid_rate = invalid_votes/vote_total;
max_polled_ballots_voted = (1-invalid_rate)*max_polled_ballots;
first_round_voted_size = (1-invalid_rate)*first_round_size;
audit_type = 0; % with replacement

% Generate BRAVO kmin upto 6*ASN
[kmslope, kmintercept, n, kmin] = BSquareBRAVOkmin(margin,alpha);
plot(n, kmin);
xlabel('Ballots drawn')
ylabel('Minimum votes for the winner')
title('Stopping Condition, BRAVO, margin = 10%, risk limit = 10%')

% number of samples for B-square risk ranges from first possible sample 
% size for BRAVO to max_polled_ballots_voted
n_bravo = n(1:max_polled_ballots_voted-n(1)+1); 
kmin_bravo = kmin(1:max_polled_ballots_voted-n(1)+1);

% Number of possible sample sizes for first round
num_possible = size(n_bravo,2);

% B-square risk schedule for BRAVO, limited to max_voted_ballots
[RiskSched, RiskValue, ExpectedBallots] = BSquareRisks(0, vote_total, n_bravo, kmin_bravo, audit_type);
plot(n_bravo, CumDistFunc(RiskSched))
xlabel('Ballots drawn')
ylabel('Cumulative Risk')
title('Cumulative risk, BRAVO, margin = 10%, risk limit = 10%')

[StopSched, StopProb, ExpectedBallots] = BSquareRisks(margin, vote_total, n_bravo, kmin_bravo, audit_type);
plot(n_bravo, CumDistFunc(StopSched))
xlabel('Ballots drawn')
ylabel('Cumulative stopping probability')
title('Cumulative stopping probability, BRAVO, margin = 10%, risk limit = 10%')

plot(n_bravo, CumDistFunc(StopSched), n_bravo, (1/alpha)*CumDistFunc(RiskSched))
xlabel('Ballots drawn')
ylabel('Cumulative stopping probabilities')
title('Stopping probability and risk as fraction of risk limit, margin = 10%, risk limit = 10%')

% For round by round BRAVO, rounds: [first_round_voted_size, max_polled_ballots_voted];

nB2 = [first_round_voted_size, max_polled_ballots_voted]
kminB2 = [kmin_bravo(first_round_voted_size-n_bravo(1)+1), kmin_bravo(num_possible)]

[StopSchedB2, StopProbB2, ExpectedBallotsB2] = RSquareRisks(margin, vote_total, nB2, kminB2, audit_type)
[RiskSchedB2, RiskValueB2, ExpectedBallots] = RSquareRisks(0, vote_total, nB2, kminB2, audit_type)

%Initialize
% These values are temp values for computations in the for loop
GoalRiskSched = zeros(1,2);
StopSchedR2 = zeros(1,2);
RiskSchedR2 = zeros(1,2);
StopSchedB2 = zeros(1,2);
RiskSchedB2 = zeros(1,2);
% These stay beyond the loop and form the output
CStopSchedR2 = zeros(1, size(n_bravo,2));
CRiskSchedR2 = zeros(1, size(n_bravo,2));
CGoalRiskSched = zeros(1, size(n_bravo,2));
CStopSchedB2 = zeros(1, size(n_bravo,2));
CRiskSchedB2 = zeros(1, size(n_bravo,2));

% For all possible sizes for the first round
nfornow = first_round_voted_size-n_bravo(1)+1 % translate round size to index into kmin

for i = nfornow
    % Desired risk schedule for the RSquare audit
    GoalRiskSched(1) = sum(RiskSched(1,1:i));
    GoalRiskSched(2) = sum(RiskSched(1,i+1:num_possible));
    
    % kmins for the RSquare audit defined by risk schedule
    [kminR2, RiskSchedR2, RiskValueR2, ExpectedBallots] = RSquareInvRisks(0, vote_total, nB2, GoalRiskSched, audit_type);
    
    % stopping probs with this kmin
    [StopSchedR2, StopProbR2, ExpectedBallotsR2] = RSquareRisks(margin, vote_total, nB2, kminR2, audit_type);
    
    % Compute cumulative probabilities
    CStopSchedR2(i) =  StopProbR2;
    CRiskSchedR2(i) =  RiskValueR2;
    CGoalRiskSched(i) = GoalRiskSched(1)+ GoalRiskSched(2);
    CStopSchedB2(i) =  StopProbB2;
    CRiskSchedB2(i) =  RiskValueB2;
end

%Display
%plot(nB2, CStopSchedR2, nB2, CStopSchedB2);
