 function [kmslope, kmintercept, n, kmin] = B2BRAVOkmin(margin, alpha)
    %
    % [kmslope, kmintercept, n, kmin] = B2BRAVOkmin(margin, alpha)
    %
    % Computes: 
    %       * kmin values for BRAVO and 
    %       * the slope and intercept defining the linear expression for 
    %           kmin as a function of sample size n when the BRAVO 
    %           stopping condition is examined in the log domain. 
    % Assumptions as in the original BRAVO paper:
    %       * beta = zero. 
    %       * sampling with replacement. 
    %
    % Max value of round size is 6*ASN. 
    %
    % For the equation, see Athena paper: https://arxiv.org/abs/2008.02315, 
    % section 3. 
    %
    % -----------
    %
    % Input: 
    %   margin:         fractional margin
    %   alpha:          fractional risk limit
    %
    % ----------
    %
    % Output: 
	%   kmslope:        (log 0.5 - log (1-p))/(log p - log(1-p))
	%   kmintercept:    - (log (alpha))/(log p - log(1-p)) 
    %                       where p is the fractional vote for the winner:
    %                       (1+margin)/2
    %	n:              1-D array: 
    %                       begins at smallest sample size n(1) for 
    %                       which kmin is no larger than sample size, 
    %                       kmin(1) <= n(1). Largest value of n(j) is 
    %                       6*ASN. 
    %	kmin:           1-D array of size of the array n: 
    %                       kmin(j) is the minimum number of votes for 
    %                       the announced winner required to terminate an 
    %                       audit with sample size n(j). 
    %                       kmin(j) = ceiling(kmslope*n(j) + kmintercept) 
    %                       computed for n(j) such that kmin(j) <= n(j)
    %                   
    % -----------
    %

    % p is the fractional vote for winner 
    p=(1+margin)/2;

    % For ease of computation
    logpoveroneminusp=log(p/(1-p));

    kmslope = (log(0.5/(1-p)))/logpoveroneminusp;
    kmintercept = - (log (alpha))/logpoveroneminusp;

    % To find first value of n >= kmin, solve n >= kmslope*n + kmintercept
    firstvalue = ceil(kmintercept/(1-kmslope));

    % n is an array of sample sizes, beginning at firstvalue. 
    n=[firstvalue:6*ASN(margin,alpha)];
    
    % kmin is computed using slope, intercept and n. 
    kmin=ceil(kmslope*n + kmintercept);
 end