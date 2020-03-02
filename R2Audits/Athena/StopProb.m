function [n, kmin, Stopping] = StopProb(margin, alpha, delta, ...
     StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
     n_last, k_last, max_draws, audit_method)
    %
    % [n, kmin, Stopping] = StopProb(margin, alpha, delta, ...
    %   StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
    %   n_last, k_last, max_draws, audit_method)
    %
    % Computes n, kmin and Stopping probability for various round sizes. 
    % Outputs are arrays indexded by number of new ballots drawn. 
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
    %       max_draws:          maximum number of ballots that can be 
    %                               drawn in all
    %       audit_method:       one of Arlo, Athena, Minerva, Metis
    %
    % -------------------------Outputs---------------------------
    %
    %       n:                  total ballots drawn
    %       kmin:               corresponding kmin
    %       Stopping:           corresponding stopping probability
    %
    
    % assumed fraction of winner votes
    p = (1+margin)/2;

    % possible new total sample size
    n = (n_last+1:max_draws);

    % initialize probabilities to zero
    Stopping = zeros(1, max_draws-n_last);

    for j=1:max_draws-n_last
        % j is number of new ballots drawn
        NextTierStop = R2CurrentTier(margin,CurrentTierStop,j);
        NextTierRisk = R2CurrentTier(0,CurrentTierRisk,j);
    
        % Compute kmin
        if strcmp(audit_method,'Arlo')
            % R2BRAVOkmin returns first value for which round is large 
            % enough; this does not suffice for us as our round may be too 
            % small. Best compute slope and intercept to compute kmin, 
            % which could be larger than n. 
            [slope, intercept, ~, ~] = R2BRAVOkmin(margin, alpha, n(j));
                kmin(j) = ceil(slope*n(j)+intercept);
        else
            % AthenaNextkmin returns n+1 if kmin larger than n
            kmin(j) = AthenaNextkmin(margin, alpha, delta, StopSched_prev, ...
                RiskSched_prev, NextTierStop, NextTierRisk, n(j), audit_method);
        end
        if kmin(j) <= n(j)
            % Round is large enough for  non-zero stopping probability. 
            % Compute binomial cdf for kmin(j) - k_last
            Stopping(j) = 1-binocdf(kmin(j)-k_last-1,j,p);
        end
    end
end



