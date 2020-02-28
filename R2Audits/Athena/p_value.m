function p_value = p_value(margin, StopSched, RiskSched, n, k, audit_method)
    %
    % pvalue = p_value(margin, n_prev, kmin_prev, n, k, audit_method)
    % This function returns the pvalue for the current round of an audit. 
    % Obviously, don't use this for large ballot-by-ballot audits. 
    % In particular, BRAVO is not an option for audit method. 
    %
    % Input Values
    %       margin:         election margin as a fraction
    %       StopSched:      current non-cumulative stopping prob. sched; 
    %                           not needed for Arlo
    %       RiskSched:      current non-cumulative Risk Schedule; not 
    %                           needed for Arlo
    %       n:              current (single) cumulative round size
    %       k:              current (single) cumulative number of ballots 
    %                           for the winner
    %       audit_method:   string, one of: Arlo, Athena, Minerva, Metis
    %                           Athena and Minerva have the same p_values 
    %                           for the same kmins and CurrentTier, but 
    %                           their kmins are, in general, distinct for 
    %                           the same round sizes because their stopping 
    %                           conditions are distinct. 
    %
    % THIS IS CURRENTLY ONLY FOR SAMPLING WITH REPLACEMENT. 
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
    
    % Arlo does not need stopping or probability schedules
    if strcmp(audit_method,'Arlo')
        p_value = exp(-logpoverhalf*k - logqoverhalf*(n-k));
    else        
        % pvalue is defined differently for different audits: 
        if strcmp(audit_method, 'Metis')
            % p_value is the ratio of total risk to total stopping probability
            StopValues = CumDistFunc(StopSched);
            RiskValues = CumDistFunc(RiskSched);
            p_value = RiskValues(NumberRounds)/StopValues(NumberRounds);
        else
            % audit_method is either Athena or Minerva, and p_value is
            % the ratio of the risk of current round to stopping 
            % probability of current round
            p_value = RiskSched(NumberRounds)/StopSched(NumberRounds);
        end
    end
end