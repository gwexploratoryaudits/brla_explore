function kmin_next = AthenaNextkmin(margin, alpha, delta, StopSched_prev, ...
     RiskSched_prev, CurrentTierStop, CurrentTierRisk, n_next, audit_method)
    % Testing in progress
    %
    % kmin_next = AthenaNextkmin(margin, alpha, delta, StopSched_prev, ...
    % RiskSched_prev, CurrentTierStop, CurrentTierRisk, n_next, audit_method)
    %
    % Athena next kmin value for given (single) cumulative n_next. 
    % beta = 0; sampling may be with or without replacement as CurrentTier, 
    % StopSched and RiskSched capture that information. 
    % Neither Arlo nor Bravo is an option for audit_method. R2BRAVOkmin 
    % should be used instead. 
    %
    % -----------
    %
    % Input: 
    %	margin:             fractional margin; needed only for Athena
    %   alpha:              fractional risk limit
    %   delta:              LR stopping condition; needed only for Athena
    %	StopSched_prev:     previous non-cumulative stopping prob. 
    %                               sched; needed only for Metis
    %	RiskSched_prev:     previous non-cumulative Risk Schedule; 
    %                               needed only for Metis
    %	CurrentTierStop:	current winner vote distribution for margin; 
    %	CurrentTierRisk:	current winner vote distribution for tied 
    %                               election; 
    %   n_next:             single cumulative round size
    %   audit_method:       string, one of: Athena, Minerva, Metis
    %                       Athena and Minerva have the same p_values for 
    %                       the same kmins, but their kmins are, in 
    %                       general, distinct for the same round sizes
    %                       because their stopping conditions are distinct.
    %                       delta is needed only for Athena. 
    %
    % ----------
    %
    % Output: 
    %	kmin_next:          single Athena kmin value corresponding to 
    %                           n_next. kmin_next = n_next+1 implies 
    %                           n_next not large enough and kmin_next not 
    %                           found. 
    %
    
    % --------- Allocate arrays for tails -----------%
    TailStop = zeros(1, size(CurrentTierStop-1, 2));
    TailRisk = zeros(1, size(CurrentTierRisk-1, 2));
    
    % ----------Compute tails --------%
    % MATLAB indexes arrays beginning at 1. Thus CurrentTier(k+1) 
    % corresponds to the probability of k votes. 
    for k=1:size(TailStop,2)
        TailStop(k) = sum(CurrentTierStop(k+1:size(CurrentTierStop,2)));
        TailRisk(k) = sum(CurrentTierRisk(k+1:size(CurrentTierRisk,2)));
    end
    
    % ----------------- kmin computations -------------------%
    if strcmp(audit_method,'Athena') || strcmp(audit_method,'Minerva') 
        % Athena/Minerva p-value check is identical for a given distribution 
        % and value of k: the ratio of the right tails of the stopping 
        % probability and risk distributions. 
        Valid_k = find(alpha*(TailStop) >= (TailRisk));
        % The kth value above tests the ratio of the right tails for 
        % kmin = k
        
        if size(Valid_k,2) == 0 % no value of k works
            kmin_next=n_next + 1;
            break
        else
            % there is a value of k that works. Ensure it is larger than 
            % ceil(n_next/2)
            kmin_next = max(Valid_k(1), ceil(n_next/2)+1);
            % kmin_next done for Minerva
            
            % If Athena, check LR
            if strcmp(audit_method,'Athena') && ...
                klog(1+margin)+(n-k)log(1-margin) < -log(delta) 
                % Audit type is Athena but LR condition not satisfied
                kmin_next = n_next+1;
                break
            end
            % kmin_next satisfies Athena/Minerva
        end
    else % this is Metis
        % Test only Metis p-value, no LR test for Metis. 
        % Metis test compares the sums of right tails, including right 
        % tails from previous rounds
        Valid_k = find(alpha*(sum(StopSched_prev)+ TailStop) ...
            >= (sum(RiskSched_prev) + TailRisk));
        
        if size(Valid_k,2) == 0 % Metis condition not satisfied
            kmin_next=n_next+1;
            break
        else
            % Metis condition met
            % kmin must be larger than ceil(n_prev/2)
            kmin_next = max(Valid_k(1), ceil(n_prev/2)+1);
        end
        
    end 
end

    