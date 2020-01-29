% For small audits. 
% This script compares single-round Aurror audits based on BRAVO with 
% replacement, beginning with
%       votes_1:                    votes for candidate 1
%       votes_2:                    votes for candidate 2
%       vote_total:                 total ballots cast
%       alpha:                      risk limit
%       percentile:                 target stopping probability
% Anticipated use: plan an audit, between the announcement of 
% rough election results and the audit itself. Also use to compute 
% kmin for the actual audit. 
%
% The script generates kmins, stopping probabilities and risks for many
% single-round audits. 
%
% Note: "invalid" is used to include both invalid votes and irrelevant ones. 

% Input
% For amendment contest in Mercer County, PA, 18 November 2019
votes_1=15038;
votes_2=5274;
vote_total=23662;
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

% Generate BRAVO kmin upto 6*ASN
[kmslope, kmintercept, n, kmin] = BSquareBRAVOkmin(margin,alpha);

% number of samples for BRAVO risk ranges from first possible sample 
% size for BRAVO to 4.5*ASN which might take us to 90th percentile for 
% Arlo and 99th for BRAVO, and is our value for maximum number of 
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

% Ratio should be around alpha
AlphaTest = GoalStopSched./GoalRiskSched;

% STEP TWO: Initialize all arrays for values to be computed: 
% Aurror kmins; Aurror and Arlo risk schedules and stopping probabilities; 

% Aurror kmin, stopping probabilities and risk, to be computed as a 
% function of number of ballots drawn. 
kmin_Aurror = zeros(1,num_possible);
RiskValue_Aurror = zeros(1,num_possible);
StopProb_Aurror = zeros(1,num_possible);

% Arlo stopping probabilities and risk, to be computed as a function of 
% number of ballots drawn, using BRAVO kmins.  
RiskValue_Arlo = zeros(1,num_possible);
StopProb_Arlo = zeros(1,num_possible);

% STEP THREE: for all round sizes, compute these values. 
for i=1:num_possible 
    % AURROR kmin. 
    % CDFs give sum of probabilities upto and including the argument. 
    % cdf(x) = Pr[X <=x]. InvCDF(x) hence gives y such that cdf(y) = x or
    % x = Pr[X <=y]. The tail hence is Pr[X >= y+1], and y+1 is kmin if 
    % x is 1-risk. 
    kmin_Aurror(i) = binoinv(1-GoalRiskSched(i), n_bravo(i), 0.5)+1;
    
    % AURROR risk and stopping
    % CDF(x, 'upper') is 1-CDF(x) or Pr[X >= x+1]
    % To compute the risk we compute the upper tail of the output of
    % binoinv, that is, one smaller than kmin, to get Pr[X >= kmin]
    RiskValue_Aurror(i) = binocdf(kmin_Aurror(i)-1, n_bravo(i), 0.5, 'upper');
    StopProb_Aurror(i) = binocdf(kmin_Aurror(i)-1, n_bravo(i), p, 'upper');
    
    % Arlo risk and stopping, using BRAVO kmins
    RiskValue_Arlo(i) = binocdf(kmin_bravo(i)-1, n_bravo(i), 0.5, 'upper');
    StopProb_Arlo(i) = binocdf(kmin_bravo(i)-1, n_bravo(i), p, 'upper');
end

% Ratio should be around alpha
AlphaTest_Arlo = StopProb_Arlo./RiskValue_Arlo;
AlphaTest_Aurror = StopProb_Aurror./RiskValue_Aurror;

% END: Looking at valid ballots. 
% -------------------

% To plot as a function of total ballots, including invalid ones
scale_up = 1/(1-invalid_rate);
n_bravo_scaled_up = round(scale_up*(n_bravo));

% Files to print figures to
filenames = {'Amendment_point1_kmins', 'Amendment_point1_stopping', 'Amendment_point1_risk'};

figure, plot(n_bravo_scaled_up, kmin_Aurror, 'b*-', n_bravo_scaled_up, kmin_bravo, 'ro-');
xlabel('Round size');
ylabel('(rough estimate) Minimum number of ballots for winner required to stop the audit'); 
title('Minimum number of winner votes needed to stop audit: Amendment risk limit = 0.1');
legend('AURROR', 'BRAVO', 'Location', 'northwest');
print('-djpeg90', filenames{1});

figure, plot(n_bravo_scaled_up, StopProb_Aurror, 'b*-', n_bravo_scaled_up, GoalStopSched, 'ro-', n_bravo_scaled_up, StopProb_Arlo, 'k^-');
xlabel('Round size');
ylabel('(rough estimate) Stopping Probability'); 
title('Stopping Probabilities: Amendment risk limit = 0.1');
legend('AURROR', 'BRAVO', 'Arlo?', 'Location', 'northwest');
print('-djpeg90', filenames{2});

figure, plot(n_bravo_scaled_up, RiskValue_Aurror, 'b*-', n_bravo_scaled_up, GoalRiskSched, 'ro-', n_bravo_scaled_up, RiskValue_Arlo, 'k^-');
xlabel('Round size');
ylabel('(rough estimate) Risk Expended'); 
title('Risk Expended: Amendment risk limit = 0.1');
legend('AURROR', 'BRAVO', 'Arlo?', 'Location', 'northwest');
print('-djpeg90', filenames{3});

figure, plot(n_bravo_scaled_up, AlphaTest_Aurror, 'b*-', n_bravo_scaled_up, AlphaTest, 'ro-', n_bravo_scaled_up, AlphaTest_Arlo, 'k^-');
xlabel('Round size');
ylabel('(rough estimate) Ratio of Stop Prob. to Risk Expended'); 
title('Ratio of Stop Prob to Risk Expended: Amendment risk limit = 0.1');
legend('AURROR', 'BRAVO', 'Arlo?', 'Location', 'northwest');
print('-djpeg90', filenames{3});

figure, plot(n_bravo_scaled_up, AlphaTest_Aurror, 'b*-', n_bravo_scaled_up, AlphaTest, 'ro-');
xlabel('Round size');
ylabel('(rough estimate) Ratio of Stop Prob. to Risk Expended'); 
title('Ratio of Stop Prob to Risk Expended: Amendment risk limit = 0.1');
legend('AURROR', 'BRAVO', 'Location', 'northwest');
print('-djpeg90', filenames{3});

% Number of total ballots to poll, valid and others, for required percentile 
aurror_stop_raw = n_bravo(find(StopProb_Aurror>= percentile, 1));
aurror_stop = n_bravo_scaled_up(find(StopProb_Aurror>= percentile, 1));
bravo_R2_stop_raw = n_bravo(find(StopProb_Arlo>= percentile, 1));
bravo_R2_stop = n_bravo_scaled_up(find(StopProb_Arlo >= percentile, 1));

fprintf('Announced Tally: %d, %d \n', [votes_1, votes_2])
fprintf('Announced vote total: %d \n\n', vote_total)

fprintf('Proposed Aurror round size, raw: %d \n', aurror_stop_raw)
fprintf('Proposed Aurror draws: %d \n\n', aurror_stop)

fprintf('Predicted Arlo round size, raw: %d \n', bravo_R2_stop_raw)
fprintf('Proposed Arlo draws: %d \n\n', bravo_R2_stop)