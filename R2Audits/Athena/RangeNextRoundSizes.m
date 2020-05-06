function [next_rounds_max, next_rounds_min, n, kmin, Stopping] = RangeNextRoundSizes(margin, alpha, delta, ...
     StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
     n_last, k_last, percentiles, max_draws, audit_method)
    % Done. Begin tests. 
    %
    % next_rounds = FurthestNextRoundSizes(margin, alpha, delta, ...
    % StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
    % n_last, k_last, percentiles, max_draws, audit_method)
    %
    % Computes range of next round sizes for given percentiles. 
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
    %       next_rounds_max:	max new draw sizes: one larger than largest 
    %                               size with stopping prob. smaller than 
    %                               percentile value
    %       next_rounds_min:	min new draw sizes: smallest size with 
    %                               stopping prob. smaller than percentile 
    %                               value
    %       n:                  total ballots drawn
    %       kmin:               corresponding kmin
    %       Stopping:           corresponding row vector of stopping 
    %                               probability
    %
    % -------------------------Usage------------------------------
    % Use for first round sizes as follows:
    %   [next_rounds_max, next_rounds_min, n, kmin, Stopping] = ...
    %       RangeNextRoundSizes(margin, alpha, delta, (0), (0), (1), ...
    %           (1), 0, 0, percentiles, max_draws, audit_method)
    % 
    
    [n, kmin, Stopping] = StopProb(margin, alpha, delta, ...
     StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
     n_last, k_last, max_draws, audit_method);
 
    % Find value of j0 so that Stopping(j0) >= percentiles for all j >=j0
    for i=1:size(percentiles,2)
        kValuemax = find(Stopping < percentiles(1,i));
        next_rounds_max(i) = kValuemax(size(kValuemax,2))+1;
        kValuemin = find(Stopping >= percentiles(1,i));
        next_rounds_min(i) = kValuemin(1,1);
    end
end



