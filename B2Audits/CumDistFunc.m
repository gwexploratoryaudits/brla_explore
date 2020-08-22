function ForwardCDF = CumDistFunc(pdf)
    %
    % ForwardCDF = CumDistFunc(pdf)
    % 
    % Computes cumulative distribution function of given pdf. 
    %
    % ----------
    %
    % Input:
    %   pdf:            row array of values whose sum desired
    %
    % ----------
    %
    % Output: 
    %   ForwardCDF:     row array of same size as input, cdf of input
    %
    % ----------
    
    % Initialize
    ForwardCDF = zeros(1, size(pdf,2));
    
    ForwardCDF(1,1) = pdf(1,1);
    
    for j=2:size(pdf,2)
        ForwardCDF(1,j) = ForwardCDF(1,j-1)+pdf(1,j);
    end       
end

