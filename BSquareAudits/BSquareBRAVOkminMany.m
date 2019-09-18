 function [n, kmin] = BSquareBRAVOkminMany(margin, alpha)
% The BSquareBRAVOkmin function for vector inputs, used to compute 
% multiple audits. But does not output slope and intercept as
% BSquareBRAVOkmin did
% Classical BRAVO kmin values
%   Input: 
%       margin: vector of fractional margins
%       alpha:  vector of fractional risk limits
%   Output: lists of size: size(margin,2) X size(alpha,2)
%           each list element is an array (different-sized arrays)
%       kmin:           each element of the list is an array 
%                           ceiling(kmslope*n + kmintercept) computed only 
%                           for values of kmin that are no larger than 
%                           sample size n. 
%       n:              each element of the list is an array that begins at 
%                           smallest sample size for which kmin is no 
%                           larger than sample size and ends at 6*ASN 
%   Note beta assumed zero as defined in original BRAVO paper
    num_margin=size(margin,2);
    num_alpha = size(alpha,2);
    
    for i=1:num_margin
        % p is fractional vote for winner 
        p=(1+margin(i))/2;
        % for ease of computation
        logpoveroneminusp=log(p/(1-p));
        kmslope = (log(0.5/(1-p)))/logpoveroneminusp;
    
        for s=1:num_alpha
            kmintercept = - (log (alpha(s)))/logpoveroneminusp;
            % first value where k <= n
            firstvalue = ceil(kmintercept/(1-kmslope));
            % First n, then the values of kmin
            nvalue=[firstvalue:6*ASN(margin(i),alpha(s))];
            kminvalue=ceil(kmslope*nvalue + kmintercept);
            n{i,s}=nvalue;
            kmin{i,s}=kminvalue;
        end
    end
    %n = reshape(ntemp,num_margin,num_alpha);
    %kmin = reshape(kmintemp,num_margin,num_alpha);
 end

