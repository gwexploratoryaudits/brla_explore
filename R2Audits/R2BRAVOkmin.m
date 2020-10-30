 function [kmslope, kmintercept, n_out, kmin] = R2BRAVOkmin(margin, alpha, n_in)
    %
    % [kmslope, kmintercept, n_out, kmin] = R2BRAVOkmin(margin, alpha, n_in)
    %
    % Computes, for given round schedule n_in: 
    %       * EoR BRAVO kmin values and 
    %       * the slope and intercept defining the linear expression for 
    %           kmin as a function of sample size n when the BRAVO 
    %           stopping condition is examined in the log domain. 
    % Assumptions as in the original BRAVO paper:
    %       * beta = zero. 
    %       * sampling with replacement. 
    %
    % BRAVO applied at end-of-round.
    %
    % For the equation, see Athena paper: https://arxiv.org/abs/2008.02315, 
    % section 3. 
    %
    % -----------
    %
    % Input: 
    %   margin:         fractional margin
    %   alpha:          fractional risk limit
    %   n_in:           row vector of round sizes, assumed to be
    %                       non-decreasing
    %
    % ----------
    %
    % Output: 
	%   kmslope:        (log 0.5 - log (1-p))/(log p - log(1-p))
	%	kmintercept:    - (log (alpha))/(log p - log(1-p)) 
    %                           where p is the fractional vote for the winner:
    %                           (1+margin)/2
    %   n_out:          1_D array, beginning at first value of n_in for 
    %                           which the likelihood ratio is large 
    %                           enough. That is, the first value of sample
    %                           size with a non-zero probability of making
    %                           a decision. 
	%	kmin:           1-D array of size of n_out: 
    %                   ceiling(kmslope*n_out + kmintercept) 
    %
    % -----------

    % p is fractional vote for winner 
    p=(1+margin)/2;

    % for ease of computation
    logpoveroneminusp=log(p/(1-p));

    kmslope = (log(0.5/(1-p)))/logpoveroneminusp;
    kmintercept = - (log (alpha))/logpoveroneminusp;

    % first value of sample size >= kmin; solve n >= kmslope*n + kmintercept
    firstvalue = ceil(kmintercept/(1-kmslope));
    
    % values of n_in that are not smaller than first value, return 1, 
    % others return 0
    valid_values = n_in >= firstvalue;
    
    % Value and first position of the maximum, in this case a "1"
    [a, b] = max(valid_values);
    
    if a == 0
        % None of the proposed sample sizes in n_in is a valid one
        n_out = [];
    else
        n_out = n_in(b:size(n_in,2));
    end
    
    % kmin computed using slope, intercept and n.
    kmin=ceil(kmslope*n_out + kmintercept);
 end