function p_value = p_value(margin, StopSched_prev, RiskSched_prev, ...
    CurrentTierStop, CurrentTierRisk, n, k, audit_method)
    %
    % pvalue = p_value(margin, n_prev, kmin_prev, n, k, audit_method)
    % This function returns the pvalue for the current round of an audit. 
    % Obviously, don't use this for large ballot-by-ballot audits. 
    % In particular, BRAVO is not an option for audit method. 
    %
    % Input Values
    %       margin:             election margin as a fraction; needed only 
    %                               for Arlo
    %       StopSched_prev:     previous non-cumulative stopping prob. 
    %                               sched; needed only for Metis
    %       RiskSched_prev:     previous non-cumulative Risk Schedule; 
    %                               needed only for Metis
    %       CurrentTierStop:	current winner vote distribution for p; not
    %                               needed for Arlo
    %       CurrentTierRisk:	current winner vote distribution for tied 
    %                               election; not needed for Arlo
    %       n:                  current (single) cumulative round size
    %       k:                  current (single) cumulative number of 
    %                               ballots for the winner
    %       audit_method:   string, one of: Arlo, Athena, Minerva, Metis
    %                           Athena and Minerva have the same p_values 
    %                           for the same kmins and CurrentTier, but 
    %                           their kmins are, in general, distinct for 
    %                           the same round sizes because their stopping 
    %                           conditions are distinct. 
    %
    %
    %----------
    %
    % Output Values
    %   pvalue:             p-value for most recent round, corresponding 
    %                           to a tied election for the null
    %
    %----------
    
    % Book keeping
    % p: fractional vote count for winner
    p = (1+margin)/2;
    logpoverhalf = log(p/0.5);
    logqoverhalf = log((1-p)/0.5);
    NumberRounds = size(StopSched,2);
    
    % Arlo does not need stopping or probability schedules. 
    if strcmp(audit_method,'Arlo')
        % Compute p value in log domain first. 
        p_value = exp(-logpoverhalf*k - logqoverhalf*(n-k));
    else        
        % pvalue is defined differently for different audits, but all 
        % except Arlo need computation of the tails for this round. 
        TailStop = sum(CurrentTierStop(k+1:size(CurrentTierStop,2)));
        TailRisk = sum(CurrentTierRisk(k+1:size(CurrentTierRisk,2)));
        if strcmp(audit_method, 'Metis')
            % p_value is the ratio of total risk to total stopping 
            % probability for all rounds. 
            StopValue = sum(StopSched_prev)+TailStop;
            RiskValue = sum(RiskSched_prev)+TailRisk;
            p_value = RiskValue/StopValue;
        else
            % audit_method is either Athena or Minerva, and p_value is
            % the ratio of the risk tail to the stopping probability tail
            % for current round only. 
            p_value = TailRisk/TailStop;
        end
    end
end