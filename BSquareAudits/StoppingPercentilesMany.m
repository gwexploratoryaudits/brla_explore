function stopping_values_Many = StoppingPercentilesMany(n_Many, StopSched_Many, percentiles)
    %
    % stopping_values_Many = StoppingPercentilesMany(n_Many, StopSched_Many, percentiles)
    % This function generates number of ballots for various 
    % specified percentiles of the stopping probabilities for many audits. 
    %------------
    %
    %Input: 
    %   n_Many:                 structured list of row vector of sample sizes
    %   StopSched_Many:         structured list of row vectors of stopping 
    %                               probabilities; jth value is stopping 
    %                               probability at n(j)th draw
    %   percentiles:            row of percentiles desired, as fractions
    %   
    %----------
    % Output:
    % stopping_values_Many:     An array of size: 
    %                           no of margins X no risk limits X no of
    %                           election sizes X no of percentiles
    
    % Initialize
    num_percentiles = size(percentiles,2);
    num_margin = size(n_Many,1);
    num_alpha = size(n_Many,2);
    num_N = size(n_Many,3);
    
    stopping_values_Many = zeros(num_margin, num_percentiles,num_alpha,num_N);
    for(i=1:num_margin)
        for(s=1:num_alpha)
            for(t=1:num_N)
                stopping_values_Many(i,:,s,t) = StoppingPercentiles(n_Many{i,s,t}, StopSched_Many{i,s,t}, percentiles);
            end
        end
    end
end