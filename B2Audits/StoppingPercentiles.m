function stopping_values = StoppingPercentiles(n, StopSched, percentiles)
    %
    % stopping_values = StoppingPercentiles(n, StopSched, percentiles)
    % This function generates number of ballots for various 
    % specified percentiles of the stopping probabilities. 
    %------------
    %
    %Input: 
    %   n:              row vector of sample sizes
    %   StopSched:      row vector of stopping probabilities; jth value is 
    %                       stopping probability at n(j)th draw
    %   percentiles:    row of percentiles desired, as fractions
    %   Use kmin-generating-modules to generate n and B2Risks modules 
    %   to generate StopSched. 
    %----------
    % Output:
    % stopping_values:	A row array of size of percentiles

    CDF = CumDistFunc(StopSched);
    stopping_values = InverseCDF(CDF,percentiles);
    
    % We correct stopping_values because n(1,1) is not 1
    stopping_values = stopping_values + (n(1,1)-1)*ones(1,size(percentiles,2));
end