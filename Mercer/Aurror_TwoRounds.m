% This script computes a two-round Aurror audit based on BRAVO without 
% replacement, beginning with
%       votes_1:        votes for candidate 1
%       votes_2:        votes for candidate 2
%       vote_total:     total ballots cast
%       alpha:          risk limit
%       n2:            total number of valid ballots to be polled
%       n1:            valid samples in first round
%       k2:            real values drawn in second round
%       k1:            real values drawn in first round
% Anticipated use: plan an audit, between the announcement of rough 
% election results and the audit itself; compute kmins for real round sizes
% drawn; compute risk for real number of ballots drawn.  
%
% The script generates: kmins, stopping probabilities and risk projections
% for a given choice of two round sample sizes. It also computes real 
% risk of given draws. 

% Input for Ammendment contest, MercerCounty, PA, 20 November 2019. 
votes_1=15038;
votes_2=5274;
vote_total=23662;
alpha=0.1;
n1 = 34;
n2 = 57;
k1 = 21;
k2 = 36;

% Book keeping
votes_winner = max(votes_1, votes_2);
votes_loser = min(votes_1, votes_2);
margin = (votes_winner-votes_loser)/(votes_winner + votes_loser);
p = votes_winner/(votes_winner + votes_loser);
invalid_votes = vote_total - (votes_1+votes_2);
invalid_rate = invalid_votes/vote_total;
audit_type = 0; % with replacement

% Now dealing only with valid votes. 
% ----------------------------------
% Generate BRAVO kmin upto 6*ASN
[kmslope, kmintercept, n, kmin] = BSquareBRAVOkmin(margin,alpha);

% number of samples for risk ranges from first possible sample 
% size for BRAVO to max_polled_ballots_voted
n_bravo = n(1:n2-n(1)+1); 
kmin_bravo = kmin(1:n2-n(1)+1);

% Number of possible sample sizes (valid ballots) for first round
num_possible = size(n_bravo,2);

% Risk schedule for BRAVO, limited to max_polled_ballots_voted
[RiskSched, RiskValue, ExpectedBallots] = BSquareRisks(0, vote_total, n_bravo, kmin_bravo, audit_type);

[StopSched, StopProb, ExpectedBallots] = BSquareRisks(margin, vote_total, n_bravo, kmin_bravo, audit_type);

% Translate round size to index into kmin
i = n1-n_bravo(1)+1; % 

% Risk schedule for Arlo
n_Arlo = [n1, n2];
kmin_Arlo = [kmin_bravo(i), kmin_bravo(num_possible)];
[StopSched_Arlo, StopProb_Arlo, ExpectedBallots_Arlo] = RSquareRisks(margin, vote_total, n_Arlo, kmin_Arlo, audit_type);
[RiskSched_Arlo, RiskValue_Arlo, ExpectedBallots] = RSquareRisks(0, vote_total, n_Arlo, kmin_Arlo, audit_type);

% Desired risk schedule for Aurror
GoalRiskSched(1) = sum(RiskSched(1:i)); 
GoalRiskSched(2) = sum(RiskSched(i+1:num_possible));
CGoalRiskSched = GoalRiskSched(1)+ GoalRiskSched(2);

% Stopping probs for comparison 
GoalStopSched(1) = sum(StopSched(1,1:i));
GoalStopSched(2) = sum(StopSched(1,i+1:num_possible));
CGoalStopSched = GoalStopSched(1)+ GoalStopSched(2);

% kmins for Aurror
[kmin_Aurror, RiskSched_Aurror, RiskValue_Aurror, ExpectedBallots] = RSquareInvRisks(0, vote_total, n_Arlo, GoalRiskSched, audit_type);
   
% stopping probs with this kmin for Aurror
[StopSched_Aurror, StopProb_Aurror, ExpectedBallots_Aurror] = RSquareRisks(margin, vote_total, n_Arlo, kmin_Aurror, audit_type);
    
% Compute risk for a given set of k1 and k2 of actual ballots drawn
% for the winner. 

% First compute a hypothetical third and final round that uses up all 
% remaining risk in a final round of size 6.5*ASN
% Compute goal cumulative risks and stopping probabilities
n_Arlo_larger2 = horzcat(n_Arlo, n(size(n,2)));
GoalRiskSched_larger2 = horzcat(GoalRiskSched, alpha-CGoalRiskSched);

% Compute kmin for this round, and related risk
[kmin_Aurror_Risk2, RiskSched_Aurror_Risk2, RiskValue_Aurror_Risk2, ExpectedBallots_Risk] = RSquareInvRisks(0, vote_total, n_Arlo_larger2, GoalRiskSched_larger2, audit_type);
CRisk_Aurror_Risk2 = [RiskSched_Aurror_Risk2(1), RiskSched_Aurror_Risk2(1)+ RiskSched_Aurror_Risk2(2), RiskSched_Aurror_Risk2(1)+ RiskSched_Aurror_Risk2(2)+RiskSched_Aurror_Risk2(3)]; 

% Next compute a hypothetical second round that uses up all remaining 
% risk after first round. 
n_Arlo_larger1 = [n_Arlo(1), n(size(n,2))];
GoalRiskSched_larger1 = [GoalRiskSched(1), alpha-GoalRiskSched(1)];

% Compute kmin for this round, and related risk
[kmin_Aurror_Risk1, RiskSched_Aurror_Risk1, RiskValue_Aurror_Risk1, ExpectedBallots_Risk] = RSquareInvRisks(0, vote_total, n_Arlo_larger1, GoalRiskSched_larger1, audit_type);
CRisk_Aurror_Risk1 = [RiskSched_Aurror_Risk1(1), RiskSched_Aurror_Risk1(1)+ RiskSched_Aurror_Risk1(2)]; 

% To compute the risk corresponding to a specific value of drawn k, 
% compute three values of the risk and choose the smallest. 
k_One_Round_Risk = [k1, kmin_Aurror_Risk2(2), kmin_Aurror_Risk2(3)];
k_Second_Round_Risk = [kmin_Aurror_Risk2(1), k2, kmin_Aurror_Risk2(3)];
k_One_Round_Risk_One = [k1, kmin_Aurror_Risk1(2)];

% Compute the risks corresponding to each
[RiskSched_Aurror_One_Round, RiskValue_Aurror_One_Round, ExpectedBallots] = RSquareRisks(0, vote_total, n_Arlo_larger2, k_One_Round_Risk, audit_type);
CRisk_One_Round = [RiskSched_Aurror_One_Round(1), RiskSched_Aurror_One_Round(1) + RiskSched_Aurror_One_Round(2), RiskSched_Aurror_One_Round(1) + RiskSched_Aurror_One_Round(2)+ RiskSched_Aurror_One_Round(3)]; 

[RiskSched_Aurror_Second_Round, RiskValue_Aurror_Second_Round, ExpectedBallots] = RSquareRisks(0, vote_total, n_Arlo_larger2, k_Second_Round_Risk, audit_type);
CRisk_Second_Round = [RiskSched_Aurror_Second_Round(1), RiskSched_Aurror_Second_Round(1) + RiskSched_Aurror_Second_Round(2), RiskSched_Aurror_Second_Round(1) + RiskSched_Aurror_Second_Round(2)+ RiskSched_Aurror_Second_Round(3)]; 

[RiskSched_Aurror_Only_One, RiskValue_Aurror_Only_One, ExpectedBallots] = RSquareRisks(0, vote_total, n_Arlo_larger1, k_One_Round_Risk_One, audit_type);
CRisk_Only_One = [RiskSched_Aurror_Only_One(1), RiskSched_Aurror_Only_One(1) + RiskSched_Aurror_Only_One(2)]; 

measured_risk = min([RiskValue_Aurror_Second_Round, RiskValue_Aurror_Only_One]);

% Output 
fprintf('Announced Tally: %d, %d \n', [votes_1, votes_2])
fprintf('Round schedule in valid votes: [%d, %d] \n\n', n_Arlo)
fprintf('------------------Bravo------------------\n')
fprintf('BRAVO kmins: [%d, %d] \n', kmin_Arlo)
fprintf('BRAVO risks: [%f, %f] \n', [GoalRiskSched(1), CGoalRiskSched])
fprintf('BRAVO stopping probabilities: [%f, %f] \n\n', [GoalStopSched(1), CGoalStopSched])
fprintf('------------------Arlo------------------\n')
fprintf('Arlo kmins: [%d, %d] \n', kmin_Arlo)
fprintf('Arlo risks: [%f, %f] \n', [RiskSched_Arlo(1), RiskValue_Arlo])
fprintf('Arlo stopping probabilities: [%f, %f] \n\n', [StopSched_Arlo(1), StopProb_Arlo])
fprintf('------------------Aurror------------------\n')
fprintf('Aurror kmins: [%d, %d] \n', kmin_Aurror)
fprintf('Aurror risks: [%f, %f] \n', [RiskSched_Aurror(1), RiskValue_Aurror])
fprintf('Aurror stopping probabilities: [%f, %f] \n\n', [StopSched_Aurror(1), StopProb_Aurror])
fprintf('------------------For Aurror Risk Evaluation: Two Rounds------------------\n')
fprintf('Three-Round schedule in valid votes: [%d, %d, %d] \n', n_Arlo_larger2)
fprintf('kmins for risk evaluation: [%d, %d, %d] \n', kmin_Aurror_Risk2)
fprintf('risks for risk evaluation: [%f, %f, %f] \n', CRisk_Aurror_Risk2)
fprintf('two-round measured risk: [%f, %f, %f] \n\n', CRisk_Second_Round)
fprintf('------------------For Aurror Risk Evaluation: One Round------------------\n')
fprintf('Two-Round schedule in valid votes: [%d, %d] \n', n_Arlo_larger1)
fprintf('kmins for risk evaluation: [%d, %d] \n', kmin_Aurror_Risk1)
fprintf('risks for risk evaluation: [%f, %f] \n', CRisk_Aurror_Risk1)
fprintf('first round measured risk: [%f, %f] \n\n', CRisk_Only_One)
fprintf('------------------Measured Risk------------------\n')
fprintf('Measured risk: %f \n\n\n', measured_risk)