 function [n_Many, kmin_Many] = BSquareBRAVOkminMany(marginVector, alphaVector)
	% [n_Many, kmin_Many] = BSquareBRAVOkminMany(marginVector, alphaVector)
    % The BSquareBRAVOkmin function for vector inputs, used to compute 
    % multiple audits. Does not, however, output slope and intercept as
    % does BSquareBRAVOkmin. Outputs classical BRAVO kmin values and 
    % corresponding vector, n, of sample sizes. 
    % -----------
    % Input: 
    %	marginVector:       row vector of fractional margins
    %	alphaVector:        row vector of fractional risk limits
    % -----------
    % Output:               two structured lists, each of size: 
    %                       no. of margin values X no. of alpha values
    %                       each list element is an array (different-sized 
    %                       arrays)
    %	n_Many:             each element of this list is a 1-D array n from 
    %                       BSquareBRAVOkmin. It begins at the smallest 
    %                       sample size for which kmin is no larger than  
    %                       sample size and ends at 6*ASN.  
    %	kmin_Many:          each element of this list is a 1-D array kmin 
    %                       from BSquareBRAVOkmin: 
    %                       kmin = ceiling(kmslope*n + kmintercept)
    %                       computed for the corresponding arrays of n_Many
    % ----------
    %   Note beta assumed zero as in BSquareBRAVOkmin and as defined in 
    %   original BRAVO paper. 
    %   
    num_margin=size(marginVector,2);
    num_alpha = size(alphaVector,2);
    
    for i=1:num_margin
        for s=1:num_alpha
            [kmslope, kmintercept, n_Many{i,s}, kmin_Many{i,s}] = BSquareBRAVOkmin(marginVector(i), alphaVector(s));
        end
    end
 end