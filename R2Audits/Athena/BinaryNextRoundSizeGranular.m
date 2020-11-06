function [next_round_size, kmin_stopping, sprob] = ...
    BinaryNextRoundSizeGranular(margin, alpha, delta, StopSched_prev, ...
    RiskSched_prev, CurrentTierStop, CurrentTierRisk, n_prev, ...
    percentiles, max_round_size, tolerance, audit_method)
    %
    % [next_round_size, n, kmin, sprob] = ...
    % NextRoundSizeGranular(margin, alpha, delta, StopSched_prev, ...
    %   RiskSched_prev, CurrentTierStop, CurrentTierRisk, n_prev, ...
    %   percentiles, max_round_size, tolerance, audit_method)
    %
    % Computes next round sizes for Minerva, given percentiles, using 
    % binary search. Does not compute entire stopping probability curve,
    % but only values required by search. Additionally, independent of 
    % the number of winner votes in the sample. 
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
    %       n_prev:             total number of ballots drawn so far
    %       percentiles:        row vector of percentiles
    %       max_round_size:     maximum round size
    %       tolerance:          allowed deviation above required percentile
    %                               value
    %       audit_method:       string 'Minerva' or 'EoR'
    %
    % -------------------------Outputs---------------------------
    % Each output is row vector of the size of percentiles
    %
    %       next_round_size:    next round size with stopping prob. larger
    %                               than percentile value and within
    %                               tolerance of it. 
    %       kmin_stopping:               corresponding kmin
    %       sprob:              corresponding stopping probability
    %
    % -------------------------Usage------------------------------
    %
    % Use for first round sizes as follows:
    %   [next_round_size, kmin_stopping, sprob] = ...
    %       NextRoundSizeGranular(margin, alpha, delta, (0), (0), (1), ...
    %           (1), 0, percentiles, max_round_size, tolerance, audit_method)
    % 
 
    % Find value of j0 by binary search. 
    % Beginning at (n_prev+1, max_round_size)
    % Success when: 
    % percentiles(i) <= Stopping(j0) 
    % AND percentiles(i) > Stopping(j0-1) or Stopping(j0) <= percentiles(i)+tolerance
    % Failure when: 
    % left == right
    % OR left and right don't change. 
    % Update keeps one end the same, and the second one as the midpoint. 
    
    % Initialize
    next_round_size = zeros(1, size(percentiles,2));
    sprob = zeros(1, size(percentiles,2));
    kmin_stopping = zeros(1, size(percentiles,2));
    
    for i=1:size(percentiles,2)
        flag=0;
        left = n_prev+1;
        right = max_round_size;
        next_round_size(i) = max_round_size+1;
        while (flag==0) && (max_round_size < 5000000)
            if right > n_prev
                [~, pstop_right, ~] = Single_Average_Stopping(margin, ... 
                    alpha, StopSched_prev, RiskSched_prev, CurrentTierStop, ...
                    CurrentTierRisk, n_prev, right, audit_method);  
            else
                pstop_right = 0;
            end
            while(left < right) && (percentiles(i) <= pstop_right)
                flag = 1;
                mid = floor((left+right)/2);
                [kmin, pstop] = Single_Binary_Stopping(margin, ... 
                    alpha, StopSched_prev, RiskSched_prev, CurrentTierStop, ...
                    CurrentTierRisk, n_prev, mid, audit_method);
                %if (percentiles(i) <= pstop) && ...
                    %(pstop <= percentiles(i) + tolerance || pstop_minus_1 < percentiles(i))
                    %(pstop <= percentiles(i) + tolerance || pstop_minus_1 < percentiles(i))
                if pstop > percentiles(i)
                    right = mid;
                elseif mid == left
                    break
                else
                    left = mid;
                end
            end
            if flag == 0
                left = max(max_round_size, left);
                max_round_size = 2*max_round_size;
                right = max_round_size;
                next_round_size(i) = max_round_size+1;
            else
                next_round_size(i) = mid;
            end
        end
        if next_round_size(i) == max_round_size+1
            sprob(i)=0;
            kmin_stopping(i) = max_round_size+1;
        else
            sprob(i) = pstop;
            kmin_stopping(i) = kmin;
        end
    end
end

