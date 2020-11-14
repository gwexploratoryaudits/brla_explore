 function [n_out, kmin, StopSched, RiskSched, CurrentTierStop, ... 
     CurrentTierRisk] = kminFirstRoundBinary(margin, alpha, delta, n_in, audit_method)
    %
    % Testing in progress
    %
    % [n_out, kmin, StopSched, RiskSched, CurrentTierStop, ... 
    %    CurrentTierRisk] = kminFirstRoundBinary(margin, alpha, delta, n_in, audit_method)
    %
    % Athena kmin values for first round size n_in. 
    % beta = 0; sampling with replacement. 
    %
    % -----------
    %
    % Input: 
    %   margin:             fractional margin
    %   alpha:              fractional risk limit
    %   delta:              LR stopping condition for Athena
    %   n_in:               first round size
	%	audit_method:       string, one of: EoR, Athena, Minerva, Metis.
    %                           Athena and Minerva can have the same 
    %                           p_value but distinct kmins for the same  
    %                           round sizes because their stopping 
    %                           conditions are distinct. 
    %
    % THIS IS CURRENTLY ONLY FOR SAMPLING WITH REPLACEMENT.
    % Supports only the Athena class. 
    % Does not support EoR BRAVO. Use R2BRAVOkmin for EoR BRAVO. 
    %
    % ----------
    %
    % Output: 
    %   n_out:              1-D array, beginning at first value of n_in for 
    %                           which the probability ratio is large 
    %                           enough. That is, n_out begins with the 
    %                           the first value of n_in that has a non-zero
    %                           probability of stopping the audit. 
    %	kmin:               1-D array of Athena kmin corresponding to n_out; 
    %                           size of n_out
    %   StopSched:          array of individual stopping prob. values for 
    %                           election with margin. jth value is 
    %                           the stopping prob when drawing n(j) 
    %                           ballots, round-by-round.                      
    %   RiskSched:          array of individual risk values. jth value is 
    %                           the risk (stopping prob. of tied election) 
    %                           of drawing n(j) ballots, round-by-round.                      
    %
	%   CurrentTierStop:	array of individual probability values. kth 
    %                           value is the probability of having k-1 
    %                           votes for the winner in this round.
    %                           Assuming election with margin. 
    %   CurrentTierRisk:	array of individual probability values. kth 
    %                           value is the probability of having k-1 
    %                           votes for the winner in this round. 
    %                           Assuming tied election. 
    %
    % -----------
    %
    % kmin[j] = smallest integer k such that stopping conditions are met
    %               for round j. 


    %-------------Preliminaries--------------
    % p is fractional vote for winner 
    p=(1+margin)/2;
    
    % NumberRounds is the size of n_in and max size of n_out and kmin
    NumberRounds = size(n_in,2);

    % Allocate risk/ stopping prob. scheds., kmin
    RiskSched = zeros(1,NumberRounds);
    StopSched = zeros(1,NumberRounds);
    kmin = zeros(1, NumberRounds);
    
    for j=1:NumberRounds
        if j == 1
            % Initialize pdfs of winner votes
            p = (1+margin)/2;
            current_number_ballots = 0;
            CurrentTierStop = binopdf(0:n_in(j), n_in(j),p);
            CurrentTierRisk = binopdf(0:n_in(j), n_in(j),0.5);
        else
            CurrentTierStop = R2CurrentTier(margin,CurrentTierStop,n_in(j)-current_number_ballots);
            CurrentTierRisk = R2CurrentTier(0,CurrentTierRisk,n_in(j)-current_number_ballots);
        end
        kmin(j) = AthenaNextkmin(margin, alpha, delta, StopSched, ...
            RiskSched, CurrentTierStop, CurrentTierRisk, n_in(j), audit_method);
 
        if kmin(j) > n_in(j)
            % round not large enough; do not lop off, nothing happens
        else
            % Lop off at kmin:
            StopSched(j) = sum(CurrentTierStop(kmin(j)+1:size(CurrentTierStop,2)));
            RiskSched(j) = sum(CurrentTierRisk(kmin(j)+1:size(CurrentTierRisk,2)));
            CurrentTierStop = CurrentTierStop(1,1:kmin(j));
            CurrentTierRisk = CurrentTierRisk(1,1:kmin(j));
            current_number_ballots = n_in(j);
        end
    end
    
    % Remove rounds where kmin > n_in
    Invalid_n = find(kmin > n_in);
    kmin(Invalid_n) = [];
    n_in(Invalid_n) = [];
    n_out = n_in;
 end