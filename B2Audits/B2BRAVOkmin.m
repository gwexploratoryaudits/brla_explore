 function [kmslope, kmintercept, n, kmin] = B2BRAVOkmin(margin, alpha)
    %
    % [kmslope, kmintercept, n, kmin] = B2BRAVOkmin(margin, alpha)
    % Classical BRAVO slope and intercept for linear expression for kmin 
    % in log domain; also computes kmin values. beta assumed zero as 
    % defined in original BRAVO paper. Max value of round size is 6*ASN
    % For equation, see Athena paper, section 3. 
    % -----------
    % Input: 
    %   margin:         fractional margin
    %   alpha:          fractional risk limit
    % ----------
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
    %	kmin:           1-D array of size of n: 
    %                       kmin(j) is the minimum number of votes for 
    %                       winner required to terminate an audit with 
    %                       sample size n(j). 
    %                       kmin(j) = ceiling(kmslope*n(j) + kmintercept) 
    %                       computed for n(j) such that kmin(j) <= n(j)
    %                   
    % -----------

    % p is fractional vote for winner 
    p=(1+margin)/2;

    % for ease of computation
    logpoveroneminusp=log(p/(1-p));

    kmslope = (log(0.5/(1-p)))/logpoveroneminusp;
    kmintercept = - (log (alpha))/logpoveroneminusp;

    % first value of n >= kmin; solve n >= kmslope*n + kmintercept
    firstvalue = ceil(kmintercept/(1-kmslope));

    % n is array of sample sizes, begins at this value. 
    n=[firstvalue:6*ASN(margin,alpha)];
    
    % kmin computed using slope, intercept and n. 
    kmin=ceil(kmslope*n + kmintercept);
 end