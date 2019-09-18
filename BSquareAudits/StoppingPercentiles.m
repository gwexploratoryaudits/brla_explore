function values = StoppingPercentiles(StopSched, n, percentiles)
% This function generates number of ballots for various 
% specified percentiles of the stopping probabilities. 
%------------
%
%Input: 
%   n:              many rows, one column, list of different-length arrays
%   StopSched:      structured list, one-to-one correspondence with n
%   percentiles:    row of percentiles desired, in fraction
%   Use kmin generating modules for n and BSquareRisks modules for StopSched. 
%----------
% Output:
% values:           An array of size: size(n,1) X size(percentiles, 2)
% Computes all kinds of other values as described in BSquareRisksMany

    for i=1:size(n,1)
        % ith array, of same size as corresponding element of n
        stopping = StopSched{i,1};
        nvalue = n{i,1};
        for j=1:size(percentiles,2)
            % Binary search for first value of sample size for which 
            % cumulative stopping prob exceeds the percentile, note 
            % cumulative prob. may not be equal to percentile, and 
            % percentile might lie between two values of the cdf, 
            % in which case we choose the higher value
            upper=size(nvalue,2);
            lower=1;
            while upper > lower + 1
                guess = ceil((upper+lower)/2);
                if percentiles(j) < sum(stopping(1:guess))
                    upper = guess;
                elseif percentiles(j) == sum(stopping(1:guess))
                    upper = guess;
                    lower = guess;
                else
                    lower = guess;
                end
            end
            % In the very rare case that we get exactly the percentile
            % we want to check that a lower value is also not at that 
            % percentile. 
            if percentiles(j) == sum(stopping(1:upper))
                while percentiles(j) == sum(stopping(1:upper))
                upper = upper-1;
                end
                upper=upper+1;
            end
            values(i,j) = upper+nvalue(1)-1;
        end       
    end
end


