 function [kmslope, kmintercept, n, kmin] = BSquareBRAVOkmin(margin, alpha)
% Classical BRAVO slope and intercept for kmin, as well as kmin values
%   Input: 
%       margin: fractional margin
%       alpha:  fractional risk limit
%   Output: 
%       kmslope:        (log 0.5 - log (1-p))/(log p - log(1-p))
%       kmintercept:    - (log (alpha))/(log p - log(1-p)) 
%                           where p is the fractional vote for the winner:
%                           (1+margin)/2
%       kmin:           ceiling(kmslope*n + kmintercept) computed only for values 
%                           of kmin that are nolarger than sample size n. 
%       n:              begins at smallest sample size for which kmin is 
%                           no larger than sample size, and ends at 6*ASN. 
%   Note beta assumed zero as defined in original BRAVO paper

% p is fractional vote for winner 
p=(1+margin)/2;

% for ease of computation
logpoveroneminusp=log(p/(1-p));

kmslope = (log(0.5/(1-p)))/logpoveroneminusp;
kmintercept = - (log (alpha))/logpoveroneminusp;

% first value where k <= n
firstvalue = ceil(kmintercept/(1-kmslope));

% Rewrite n
n=[firstvalue:6*ASN(margin,alpha)];

kmin=ceil(kmslope*n + kmintercept);
end

