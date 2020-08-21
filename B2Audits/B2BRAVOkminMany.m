 function [n_Many, kmin_Many] = B2BRAVOkminMany(marginVector, alphaVector)
    %
	% [n_Many, kmin_Many] = B2BRAVOkminMany(marginVector, alphaVector)
    % The B2BRAVOkmin function for vector inputs, used to compute 
    % multiple audits. Does not, however, output slope and intercept as
    % does B2BRAVOkmin. Outputs classical BRAVO kmin values and 
    % corresponding vector, n, of sample sizes. 
    %
    % -----------
    %
    % Input: 
    %	marginVector:       row vector of fractional margins
    %	alphaVector:        row vector of fractional risk limits
    %
    % -----------
    %
    % Output:               two structured lists, each of size: 
    %                       no. of margin values X no. of alpha values
    %                       each list element is an array (different-sized 
    %                       arrays)
    %	n_Many:             each element of this list is a 1-D array n 
    %                       output by B2BRAVOkmin. It begins at the 
    %                       smallest sample size n(1) for which 
    %                       kmin(1) <= n(1). Last value of the array n is 
    %                       6*ASN for that margin and alpha.  
    %	kmin_Many:          each element of this list is a 1-D array kmin 
    %                       output by B2BRAVOkmin and of the same size as 
    %                       the corresponding array n above: 
    %                       kmin(j) = ceiling(kmslope*n(j) + kmintercept)
    %                       computed for the corresponding arrays n 
    %                       of n_Many. 
    %
    % ----------
    %
    %   This function does not output kmslope or kmintercept. Note beta is 
    %   assumed zero as in B2BRAVOkmin and as defined in the original 
    %   BRAVO paper. 
    % 
    
    num_margin=size(marginVector,2);
    num_alpha = size(alphaVector,2);
    
    for i=1:num_margin
        for s=1:num_alpha
            [~, ~, n_Many{i,s}, kmin_Many{i,s}] = ...
                B2BRAVOkmin(marginVector(i), alphaVector(s));
        end
    end
 end