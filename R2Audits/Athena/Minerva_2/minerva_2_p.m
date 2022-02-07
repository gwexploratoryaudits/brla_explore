%function [p_value, LR, next_round] = minerva_2_p(alpha, margin, n, k, prob)
    %
    % [p_value, LR, next_draw] = minerva_2_p(margin, n, k, prob)
    %
    % This function returns the Minerva 2.0 pvalue and the likelihood 
    % ratio for the current round of an audit, and the size of the next draw. 
    % Likelihood ratio is the inverse of the BRAVO p-value. 
    %
    % Input Values
    %       alpha:              risk limit
    %       margin:             election margin as a fraction
    %       n:                  vector of cumulative round sizes
    %       k:                  vector of cumulative number of 
    %                               ballots for the winner
    %       prob:               desired next round stopping probability
    %----------
    %
    % Output Values
    %   pvalue:             p-value for most recent round, corresponding 
    %                           to a tied election for the null
    %   LR:                 likelihood ratio
    %
    %----------
    
    % Book keeping
	current_k = k(size(n,2));
    current_n = n(size(n,2));
    p = (1+margin)/2;
    
    % Compute LR value in log domain first.
	LR = exp(log(1+margin)*current_k + log(1-margin)*(current_n-current_k));
    
    if size(n) == 1 % First round p-value is simply the ratio of the tails 
        p_value = binocdf(k(1)-1,n(1),0.5,'upper')/binocdf(k(1)-1,n(1),p,'upper');
    else % Bravo ratio of previous rounds X tail ratio of current round
        tail_ratio = binocdf(k(size(n,2))-k(size(n,2)-1)-1,....
            n(size(n,2))-n(size(n,2)-1),0.5,'upper')/....
            binocdf(k(size(n,2))-k(size(n,2)-1)-1,....
            n(size(n,2))-n(size(n,2)-1),p,'upper');
        p_value = tail_ratio/(exp(log(1+margin)*k(size(n,2)-1) + ...
            log(1-margin)*(n(size(n,2)-1)-k(size(n,2)-1))));
    end
    
    [next_round_size, n, kmin, sprob] = ...
        NextRoundSize(margin, alpha, delta, (0), (0), (1), ...
        (1), 0, 0, percentiles, max_round_size, tolerance)
end