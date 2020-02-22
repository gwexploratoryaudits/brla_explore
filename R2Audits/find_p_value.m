function [Metis_pvalues, Athena_pvalues, Arlo_pvalues, stopping] = find_p_values(margin, alpha, n_prev, kmin_prev, n, k, delta)
    %
    % [pvalues, dvalues, stopping] = find_p_values(margin, alpha, n_prev, kmin_prev, n, k, delta)
    % This function returns the pvalues, dvalues and whether the audit 
    % should stop for a round-by-round audit.
    %
    % Input Values
    %       margin: election margin as a fraction
    %       alpha: risk limit as a fraction
    %       n_prev: prior cumulative round schedule
    %       kmin_prev: kmins corresponding to n_prev
    %       n: current (single) cumulative round size
    %       k: sequence of (cumulative) number of ballots for the winner
    %       delta: inverse of delta is the minimum acceptable likelihood 
    %               ratio; alpha <= delta <= infinity
    %
    % THIS IS CURRENTLY ONLY FOR SAMPLING WITH REPLACEMENT. 
    %
    % Note that: 
    % a ballot-by-ballot round schedule gives exactly the BRAVO audit
    %       independent of delta
    % a round schedule that is not ballot by ballot gives you: 
    %       Arlo if delta = alpha
    %       an Athena variation else, which is assured to be a 
    %       max-likelihood estimate if delta <= 1 (ML ratio >= 1)
    % The larger delta is, the greater the benefit of Athena 
    %       standard use is with delta = 1 for an ML estimate that
    %       maximizes the benefit of Athena
    %       Minerva is defined as Athena with delta = infinity
    %
    %----------
    %
    % Output Values
    %   pvalues:        p-values for each round, corresponding to a tied 
    %                       election as the null
    %   dvalues:        inverse of the LR for each round
    %   stopping:       'Done' if audit is done; 'Draw more ballots' else. 
    %   stopping condition is pvalue <= alpha AND dvalue <= delta
    %
    %----------

    % p: fractional vote count for winner
    p = (1+margin)/2;

    % Obtain risk and stopping probability schedules assuming k=kmin for 
    % most recent round
    [RiskSched, RiskValue] = R2RisksWithReplacement(margin,[n_prev n],[kmin_prev k]);
    [StopSched, StopValue] = R2RisksWithReplacement(0,[n_prev n],[kmin_prev k]);

    % pvalue is the ratio of total risk to total stopping probability
    if StopValue == 0
        error('pvalue infinitely large');
    else
        pvalue = RiskValue/StopValue;
    end
    
    % stop if pvalue not larger than alpha
    if pvalue <= alpha
        stopping = 'Done'; 
    else
        stopping = 'Draw more ballots';
    end
end