function [n, kmin, Stopping] = StopProbRanges(margin, alpha, delta, ...
     StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
     n_last, k_last, min_draws, max_draws, audit_method)
    %
    % [n, kmin, Stopping] = StopProbRanges(margin, alpha, delta, ...
    %   StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
    %   n_last, k_last, min_draws, max_draws, audit_method)
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
    %       min_draws:          minimum number of new draws
    %       max_draws:          maximum number of new draws
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
    n = (n_last+min_draws:n_last+max_draws);
    
    % allocate kmin
    kmin = zeros(1, size(n,2));

    % allocate and initialize probabilities to zero
    Stopping = zeros(1, size(n,2));
    
    if strcmp(audit_method,'Arlo')
        % ---------------Compute kmin ------------------%
        % Do not need current tier probabilities to compute kmin. 
        % R2BRAVOkmin returns first value for which round is large 
        % enough; but we prefer to compute for all rounds, so get 
        % only slope and intercept.
        [slope, intercept, ~, ~] = R2BRAVOkmin(margin, alpha, n);
        kmin = ceil(slope*n + intercept);
        
        %---------------Compute Stopping----------------%
        for j=1:size(n,2) % j is index
            if kmin(j) <= n(j)
                % Round is large enough for  non-zero stopping probability. 
                % Compute binomial cdf for kmin(j) - k_last
                Stopping(j) = 1-binocdf(kmin(j)-k_last-1,n(j)-n_last,p);
            end % Found Stopping(j)
        end
        
    else % not Arlo
        for j=1:size(n,2) % j is index
            %--------------Compute kmin(j)----------------%
            if n_last == 0 % Not Arlo, but first round. Do not need convolutions. 
                NextTierStop = binopdf(0:n(j),n(j),p);
                NextTierRisk = binopdf(0:n(j),n(j),0.5);
            else % Not Arlo and not first round, need convolution
                NextTierStop = R2CurrentTier(margin,CurrentTierStop,n(j)-n_last);
                NextTierRisk = R2CurrentTier(0,CurrentTierRisk,n(j)-n_last);
            end
            
            % Now that we have the stopping and tied election 
            % distributions, find a single kmin value for a new draw of 
            % j ballots. AthenaNextkmin returns n+1 if kmin larger 
            % than n
            kmin(j) = AthenaNextkmin(margin, alpha, delta, StopSched_prev, ...
                RiskSched_prev, NextTierStop, NextTierRisk, n(j), audit_method);
            
            %---------------Compute Stopping----------------%
            if kmin(j) <= n(j)
                % Round is large enough for  non-zero stopping probability. 
                % Compute binomial cdf for kmin(j) - k_last for a draw of 
                % j ballots. 
                Stopping(j) = 1-binocdf(kmin(j)-k_last-1,n(j)-n_last,p);
            end % Found Stopping(j)
            
        end % Done with draw of j ballots
        
    end % Done audit type
    
end



