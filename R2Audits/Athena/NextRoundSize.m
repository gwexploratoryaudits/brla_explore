function [next_round_size, n, kmin, sprob, Stopping] = ...
    NextRoundSize(margin, alpha, delta, StopSched_prev, ...
    RiskSched_prev, CurrentTierStop, CurrentTierRisk, n_prev, k_prev, ...
    percentiles, max_round_size, tolerance)
    %
    % [next_round_size, n, kmin, sprob, Stopping] = ...
    % NextRoundSize(margin, alpha, delta, StopSched_prev, ...
    %   RiskSched_prev, CurrentTierStop, CurrentTierRisk, n_prev, k_prev, ...
    %   percentiles, max_round_size, tolerance)
    %
    % Computes next round sizes for Minerva, given percentiles, using 
    % binary search. 
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
    %       k_prev:             total number of winner votes drawn so far
    %       percentiles:        row vector of percentiles
    %       max_round_size:     maximum round size
    %       tolerance:          allowed deviation above required percentile
    %                               value
    %
    % -------------------------Outputs---------------------------
    % Each output is row vector of the size of percentiles
    %
    %       next_round_size:	next round size with stopping prob. larger
    %                               than percentile value and within
    %                               tolerance of it. 
    %       n:                  total ballots drawn
    %       kmin:               corresponding kmin
    %       sprob:              corresponding stopping probability
    %
    % -------------------------Usage------------------------------
    %
    % Use for first round sizes as follows:
    %   [next_round_size, n, kmin, sprob] = ...
    %       NextRoundSize(margin, alpha, delta, (0), (0), (1), ...
    %           (1), 0, 0, percentiles, max_round_size, tolerance)
    % 

	[n, kmin, Stopping] = StopProb(margin, alpha, delta, ...
	StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
	n_prev, k_prev, max_round_size, 'Minerva');
 
    % Find value of j0 by binary search. 
    % Beginning at (n_prev+1, max_round_size)
    % Success when: 
    % percentiles(i) <= Stopping(j0) <= percentiles(i)+tolerance
    % AND percentiles(i) > Stopping(j0-1)
    % Failure when: 
    % left == right
    % OR left and right don't change. 
    % Update keeps one end the same, and the second one as the midpoint. 
    
    % Initialize
    next_round_size = zeros(1, size(percentiles,2));
    sprob = zeros(1, size(percentiles,2));
    
    for i=1:size(percentiles,2)
        left = n_prev+1;
        right = max_round_size;
        next_round_size(i) = max_round_size+1; % if this isn't changed, the binary search failed. 
        while(left ~= right)
            mid = floor((left+right)/2);
            if (percentiles(i) <= Stopping(mid-n_prev)) && ...
                    (Stopping(mid-n_prev) <= percentiles(i) + tolerance || Stopping(mid-n_prev-1) < percentiles(i))
                next_round_size(i) = mid;
                break
            elseif Stopping(mid-n_prev) > percentiles(i)
                right = mid;
            elseif mid == left
                    break
            else
                left = mid;
            end
        end
        if next_round_size(i) == max_round_size+1
            sprob(i)=0;
        else
            sprob(i) = Stopping(next_round_size(i)-n_prev);
        end
    end
end

