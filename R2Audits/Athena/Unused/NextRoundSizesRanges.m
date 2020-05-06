function [next_rounds, n, kmin, Stopping] = NextRoundSizesRanges(margin, ...
    alpha, delta, StopSched_prev, RiskSched_prev, CurrentTierStop, ...
    CurrentTierRisk, n_last, k_last, percentiles, min_draws, max_draws, ...
    audit_method)
    % Weird
    %
    % [next_rounds, n, kmin, Stopping] = NextRoundSizesRanges(margin, ...
    % alpha, delta, StopSched_prev, RiskSched_prev, CurrentTierStop, ...
    % CurrentTierRisk, n_last, k_last, percentiles, min)_draws, ...
    % max_draws, audit_method)
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
    %       min_draws:          minimum number of new draws
    %       max_draws:          maximum number of new ballots drawn
    %       audit_method:       one of Arlo, Athena, Minerva, Metis
    %
    % -------------------------Outputs---------------------------
    %
    %       next_rounds:        new draw sizes
    %       n:                  total ballots drawn
    %       kmin:               corresponding kmin
    %       Stopping:           corresponding stopping probability
    %
    
    [n, kmin, Stopping] = StopProbRanges(margin, alpha, delta, ...
     StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
     n_last, k_last, min_draws, max_draws, audit_method);
    
    p = (1+margin)/2;
    
    % Find value of j0 so that Stopping(j0) >= percentiles for all j >=j0
    for i=1:size(percentiles,2)
        for n = n_last + min_draws: n_last + max_draws
            k_max = binoinv(1-percentiles(i),n,p);
            k = k_max;
            while k 
            if 1-binocdf(k_max) == percentiles(i) && 1-binocdf(k_max,n, 0.5) > alpha*(1-bincodf(k_max,n,p))
                break
            end
            
                
        kValue = find(Stopping < percentiles(1,i));
        next_rounds(i) = kValue(size(kValue,2))+1 + min_draws-1;
    end
end



