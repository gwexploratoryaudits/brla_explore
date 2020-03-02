function next_rounds = NextRoundSizes(margin, alpha, delta, ...
     StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
     n_last, k_last, percentiles, max_draws, audit_method)
    % WIP
    %
    % next_rounds = NextRoundSizes(margin, alpha, delta, ...
    % StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
    % n_last, k_last, percentiles, max_draws, audit_method)
    %
    % Computes next round sizes for given percentiles. 
    %
    % ---------------------------Inputs------------------------
    %
    %       margin:             fractional margin
    %       alpha:              fractional risk limit
    %       delta:              minimum value for Athena LR; not needed for 
    %                               other audit types
    %       StopSched_prev:     most recent Stop_Sched
    %       RiskSched_prev:     most recent RiskSched 
    %       CurrentTierStop:	most recent winner vote distribution for 
    %                               election with margin
    %       CurrentTierRisk:    most recent winner vote distribution for 
    %                               tied election
    %       n_last:             total number of ballots drawn so far
    %       k_last:             total number of winner votes drawn so far
    %       percentiles:        row vector of percentiles
    %       max_draws:          maximum number of ballots that can be 
    %                               drawn in all
    %       audit_method:       one of Arlo, Athena, Minerva, Metis
    %
    % -------------------------Outputs---------------------------
    %
    %       next_rounds:        new draw sizes
    %
    
    [n, ~, Stopping] = StopProb(margin, alpha, delta, ...
     StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
     n_last, k_last, max_draws, audit_method);
 
    % Find value of n(j) so that Stopping(j) >= percentiles for all i >=j
    
    
end



