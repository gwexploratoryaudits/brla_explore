 function [n_out, kmin, StopSched, RiskSched, CurrentTierStop, ... 
     CurrentTierRisk] = Athenakmin(margin, alpha, delta, n_in, audit_method)
    % Testing in progress
    % [n_out, kmin, StopSched, RiskSched] = Athenakmin(margin, alpha, delta, n_in, audit_method)
    % Athena kmin values for valid round sizes among given n_in. 
    % beta = 0; sampling with replacement. 
    % -----------
    % Input: 
    %   margin:         fractional margin
    %   alpha:          fractional risk limit
    %   delta:          LR stopping condition for Athena
    %   n_in:           row vector of cumulative round sizes, assumed to be
    %                       increasing
	%   audit_method:   string, one of: Athena, Minerva, Metis
    %                       Athena and Minerva have the same p_values for 
    %                       the same kmins, but their kmins are, in 
    %                       general, distinct for the same round sizes
    %                       because their stopping conditions are distinct.
    %                       delta is needed only for Athena. 
    %
    % THIS IS CURRENTLY ONLY FOR SAMPLING WITH REPLACEMENT.
    % Does not support Arlo. Use R2BRAVOkmin for Arlo. 
    %
    % ----------
    % Output: 
    %   n_out:          1-D array, beginning at first value of n_in for 
    %                           which the probability ratio is large 
    %                           enough. That is, n_out begins with the 
    %                           the first value of n_in that has a non-zero
    %                           probability of stopping the audit. 
    %	kmin:           1-D array of Athena kmin corresponding to n_out; 
    %                           size of n_out
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
    CurrentTierStop = (1);
    CurrentTierRisk = (1);
    current_number_ballots = 0;
    
    for j=1:NumberRounds
        CurrentTierStop = R2CurrentTier(margin,CurrentTierStop,n_in(j)-current_number_ballots);
        CurrentTierRisk = R2CurrentTier(0,CurrentTierRisk,n_in(j)-current_number_ballots);
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


    