 function [n_out_Many, kmin_Many] = R2BRAVOkminMany(marginVector, alphaVector, n_in_Many)
	% [n_out_Many, kmin_Many] = R2BRAVOkminMany(marginVector, alphaVector, n_in_Many)
    % The R2BRAVOkmin function for vector inputs, used to compute 
    % multiple audits. Does not, however, output slope and intercept as
    % does R2BRAVOkmin. Outputs classical BRAVO kmin values and 
    % corresponding vector, n_out_Many, of sample sizes. 
    % -----------
    % Input: 
    %	marginVector:       row vector of fractional margins
    %	alphaVector:        row vector of fractional risk limits
    %   n_in_Many:          list of round schedules; each schedule a row 
    %                           vector. Schedules may be of different
    %                           sizes. i, s th round schedule corresponds 
    %                           to ith margin and sth value of alpha
    % -----------
    % Output:               two structured lists, each of size: 
    %                       no. of margin values X no. of alpha values
    %                       each list element is an array (different-sized 
    %                       arrays)
    %	n_out_Many:         each element of this list is a 1-D array n_out 
    %                       from R2BRAVOkmin, beginning at the smallest 
    %                       sample size in the corresponding n_in for  
    %                       which kmin is no larger than sample size.  
    %	kmin_Many:          each element of this list is a 1-D array kmin 
    %                       from R2BRAVOkmin: 
    %                       kmin = ceiling(kmslope*n_out + kmintercept)
    %                       computed for the corresponding arrays of 
    %                       n_in_Many
    % ----------
    %   Note beta assumed zero as in B2BRAVOkmin and as defined in 
    %   original BRAVO paper. 
    %   
    num_margin=size(marginVector,2);
    num_alpha = size(alphaVector,2);
    
    for i=1:num_margin
        for s=1:num_alpha
            [n_out_Many{i,s}, kmin_Many{i,s}] = RSquareBRAVOkmin(marginVector(i), alphaVector(s), n_in_Many{i,s});
        end
    end
 end