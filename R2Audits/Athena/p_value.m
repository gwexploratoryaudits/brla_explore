function [p_value, LR] = p_value(margin, StopSched_prev, RiskSched_prev, ...
    CurrentTierStop, CurrentTierRisk, n, k, audit_method)
    %
    % [p_value, LR] = p_value(margin, StopSched_prev, RiskSched_prev, ...
    %           CurrentTierStop, CurrentTierRisk, n, k, audit_method)
    %
    % This function returns the pvalue and the likelihood ratio for the 
    % current round of an audit. Likelihood ratio is the inverse of the 
    % `delta-value' used for Athena. This function returns LR for 
    % all audit methods. Note that LR depends only on margin, n and k; 
    % that is, only on variables needed for BRAVO p-values. It is the 
    % ratio tested for the BRAVO stopping condition. 
    %
    % Input Values
    %       margin:             election margin as a fraction; needed only 
    %                               for EoR BRAVO
    %       StopSched_prev:     previous non-cumulative stopping prob. 
    %                               sched; needed only for Metis
    %       RiskSched_prev:     previous non-cumulative Risk Schedule; 
    %                               needed only for Metis
    %       CurrentTierStop:	current winner vote distribution for 
    %                               margin; not needed for EoR
    %       CurrentTierRisk:	current winner vote distribution for tied 
    %                               election; not needed for EoR
    %       n:                  current (single) cumulative round size
    %       k:                  current (single) cumulative number of 
    %                               ballots for the winner
    %       audit_method:   string, one of: EoR, Athena, Minerva, Metis.
    %                           Athena and Minerva have the same p_values 
    %                           for the same kmins and CurrentTier, but 
    %                           their kmins are, in general, distinct for 
    %                           the same round sizes because their stopping 
    %                           conditions are distinct. Here, their 
    %                           p_values will be the same if n, k and both 
    %                           CurrentTiers are the same. That is, if 
    %                           their histories are the same. However, 
    %                           the stopping decisions might still differ
    %                           because the LR needs to be tested as well 
    %                           for Athena. 
    %
    %----------
    %
    % Output Values
    %   pvalue:             p-value for most recent round, corresponding 
    %                           to a tied election for the null
    %   LR:                 likelihood ratio
    %
    %----------
    
    % Book keeping
    NumberRounds = size(StopSched_prev,2);
	
    % Compute LR value in log domain first.
	LR = exp(log(1+margin)*k + log(1-margin)*(n-k));
    
    % Arlo does not need stopping or probability schedules. 
    if strcmp(audit_method,'Arlo')
        p_value = 1/LR;
    else        
        % pvalue is defined differently for different audits, but all 
        % except Arlo need computation of the tails for this particular 
        % round. 
        TailStop = sum(CurrentTierStop(k+1:size(CurrentTierStop,2)));
        TailRisk = sum(CurrentTierRisk(k+1:size(CurrentTierRisk,2)));
        if strcmp(audit_method, 'Metis')
            % p_value is the ratio of total risk over all rounds to total 
            % stopping probability for all rounds. 
            p_value = (sum(RiskSched_prev)+TailRisk)/...
                (sum(StopSched_prev)+TailStop);
        else
            % audit_method is either Athena or Minerva, and p_value is
            % the ratio of the risk tail to the stopping probability tail
            % for current round only. 
            p_value = TailRisk/TailStop;
        end
    end
end