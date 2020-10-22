function values = InverseCDF(cdf, percentiles)
    %
    % values = InverseCDF(cdf, percentiles)
    %
    % Given cumulative distribution function cdf and a row vector of 
    % percentiles, this function finds the position of the first element 
    % in cdf whose value is not smaller than the element in the row vector. 
    % values(j) = k where cdf(k) is the first element in cdf that is 
    % not smaller than percentiles(j). 
    %
    % ----------
    %
    % Input:
    %   cdf:            row array of non-decreasing values
    %   percentiles:    row array of fractional percentiles
    %
    % ----------
    %
    % Output: 
    %   values:         row array of size of percentiles, identifies
    %                       index into CDF which marks the first element
    %                       whose value is not smaller than the
    %                       corresponding value of percentiles
    %
    % ----------
    %
    
    for j=1:size(percentiles,2)
        x = find(cdf >= percentiles(j),1);
        if size(x,2) == 0
            values(j) = size(cdf,2);
        else
            values(j) = x;
        end
    end       
end

