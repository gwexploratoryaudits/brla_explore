function p_value = p_value(margin, n_prev, kmin_prev, n, k, audit_method)
    %
    % pvalue = p_value(margin, n_prev, kmin_prev, n, k, audit_method)
    % This function returns the pvalue for the last round of an audit. 
    % Obviously, don't use this for large ballot-by-ballot audits. 
    % In particular, BRAVO is not an option for audit method. 
    %
    % Input Values
    %       margin: election margin as a fraction
    %       n_prev: prior cumulative round schedule
    %       kmin_prev: kmins corresponding to n_prev
    %       k_prev: sequence of (cumulative) number of ballots for the 
    %               winner in previous rounds corresponding to n_prev
    %       n: current (single) cumulative round size
    %       k: current (single) cumulative number of ballots for the winner
    %       audit_method: string, one of: Arlo, Athena, Minerva, Metis
    %                       Athena and Minerva have the same p_values for 
    %                       the same kmins, but their kmins are, in 
    %                       general, distinct for the same round sizes
    %                       because their stopping conditions are distinct. 
    %
    % THIS IS CURRENTLY ONLY FOR SAMPLING WITH REPLACEMENT. 
    %
    %----------
    %
    % Output Values
    %   pvalue:    p-value for last round, corresponding to a tied 
    %                       election as the null
    %
    %----------

    % p: fractional vote count for winner
    p = (1+margin)/2;
    logpoverhalf = log(p/0.5);
    logqoverhalf = log((1-p)/0.5);
    NumberRounds = size(n_prev,2)+1;
    
    % Arlo does not need stopping or probability schedules
    if strcmp(audit_method,'Arlo')
        p_value = exp(-logpoverhalf*k - logqoverhalf*(n-k));
    else        
        % Obtain risk and stopping probability schedules assuming k=kmin for 
        % most recent round
        StopSched = R2RisksWithReplacement(margin,[n_prev n],[kmin_prev k]);
        RiskSched = R2RisksWithReplacement(0,[n_prev n],[kmin_prev k]);

        % pvalue is defined differently for different audits: 
        if strcmp(audit_method, 'Metis')
            % p_value is the ratio of total risk to total stopping probability
            StopValues = CumDistFunc(StopSched);
            RiskValues = CumDistFunc(RiskSched);
            p_value = RiskValues(NumberRounds)/StopValues(NumberRounds);
        else % audit_method is either Athena or Minerva
            p_value = RiskSched(NumberRounds)/StopSched(NumberRounds);
        end
    end
end