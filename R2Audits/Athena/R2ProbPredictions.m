function [n_next, kmin_next, StopProb, RiskValues, n_next_arlo, ...
    kmin_next_arlo, StopProb_arlo, RiskValues_arlo, n_next_bravo, ... 
    kmin_next_bravo, StopProb_bravo, RiskValues_bravo] = ...
     R2ProbPredictions(votes_1, votes_2, vote_total, alpha, delta, n, ...
        kmin, n_last, k_last, n_max, percentiles, audit_method)
% For round-by-round audits with replacement 
% This function compares values for the next round size
%
%       votes_1:                    votes for candidate 1
%       votes_2:                    votes for candidate 2
%       vote_total:                 total ballots cast
%       alpha:                      risk limit
%       delta:                      defines LR stopping condition for Athena
%                                       ignored for others
%       n:                          two-candidate round sequence so far
%       kmin:                       kmins so far
%       n_last:                     most recent cumulative round size (two 
%                                       candidate): should be last value 
%                                       of n, and zero if n is empty
%       k_last:                     winner votes in most recent draw
%       n_max:                      maximum cumulative next round size
%                                       including irrelevant votes
%       percentiles:                target stopping probability
%       audit_method:               supporting string inputs: 
%                                       'Athena', 'Minerva', 'Metis'                                     
%
% Anticipated use: Choose next audit round and corresponding kmin. 
% For planning an audit before it happens, n=[], kmin=[], n_last=k_last=0
%
% The function generates kmins, stopping probabilities and risks for 
% specified single-round audit, BRAVO and Arlo. 
%
% Output: 
% n_next:                           row of next round sizes corresponding 
%                                       to prob of stopping given k_last
% kmin_next:                        corresponding next kmins
% StopProb:                       Cumulative stopping schedule as a
%                                       function of next round size
% RiskValues:                       Cumulative risk schedule as a
%                                       function of next round size
% n_next_arlo
% kmin_next_arlo
% StopProb_arlo
% RiskValues_arlo
% n_next_bravo
% kmin_next_bravo
% StopProb_bravo
% RiskValues_bravo

% Input
% For amendment contest in Mercer County, PA, 18 November 2019
% votes_1=15038;
% votes_2=5274;
% vote_total=23662;
% alpha=0.1;
% percentile = 0.9;

% Book keeping
votes_winner = max(votes_1, votes_2);
votes_loser = min(votes_1, votes_2);
margin = (votes_winner-votes_loser)/(votes_winner + votes_loser);
p = votes_winner/(votes_winner + votes_loser);
irrelevant_votes = vote_total - (votes_1+votes_2);
irrelevant_rate = irrelevant_votes/vote_total;

% Convert n_max to expected value of two-candidate round size
n_max = n_max*(1-irrelevant_rate);

% BEGIN: Looking only at valid votes
% ----------------------------------

% STEP ONE: Generate stopping schedule so far
if (n_last > 0)
    ProbSched = R2RisksWithReplacement(margin, n, kmin);
    RiskSched = R2RisksWithReplacement(0, n, kmin);
else
    ProbSched = [];
    RiskSched = [];
end

% STEP TWO: Generate BRAVO kmins and Arlo stopping probabilities for round
% sizes

% Generate BRAVO kmin upto 6*ASN
[kmslope, kmintercept, n_bravo, ~] = B2BRAVOkmin(margin,alpha);
 
% Limit n to those values greater than most recent round and not larger 
% than n_max; compute corresponding kmin. 
n_bravo = n_bravo(n_bravo > n_last);
n_bravo = n_bravo(n_bravo <= n_max);
kmin_bravo = kmslope*n_bravo + kmintercept;

% Stopping probabilities for Arlo as a function of n_bravo
StopProb_arlo = 1-binocdf(kmin_bravo-k_last-1,n_bravo-n_last,p);

% STEP TWO: Generate Athena kmins as a function of n
if (n_last == 0) % First round
    for i = 1:n_max % All possible first round sizes
        % Find values of k that satisfy tail ratio condition
        Valid_k = find(alpha*(1-binocdf(0:i, i, p)) ...
            >= (1-binocdf(0:i, i, 0.5)));
        % kth value above corresponds to the cdf for k-1 winner votes and 
        % hence 1-cdf is the tail corresponding to winning votes >= k
        % Thus the smallest value of k that satisfies the above
        % condition, Valid_k(1), is a candidate for kmin. 
        % Check whether any values found
        if size(Valid_k,2) ~= 0 % kmins found for Minerva and Metis but Athena requires LR check
            if strcmp(audit_method,'Athena')
                % Check LR
                km = max(Valid_k(1), ceil((log(0.5/(1-p)))/(log(p/(1-p)))));
                % kmin should be larger than half round size
                kmin_Athena(i) = max(km, ceil(i/2)+1);
            else % audit types other than Athena need not check LR
                % kmin should be larger than half round size
                kmin_Athena(i) = max(Valid_k(1), ceil(i/2)+1);
            end % end if statement checking Athena LR and assigning kmins to all audits
        end % end "ratio satisfied"
    end % done for all possible round sizes
else % Schedules computed earlier are helpful because not first round
    
    
end % Is this an opening round?
    
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
scale_up = 1/(1-irrelevant_rate);
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