function Average_Ballots_Many = ASN_Many(marginVector, alphaVector)
    %
    % Average_Ballots_Many = ASNMany(marginVector, alphaVector)
    % outputs many values of ASN as described in BRAVO paper, eqn(5)
    % This code runs ASN.m many times, for many values of margin and alpha
    %----------
    % Input: 
    %   marginVector:             row vector of fractional margins
    %   alphaVector:              row vector of fractional risk limits
    %----------
    % Output: 
    %   Average_Ballots_Many:	matrix of ASN values, 
    %                           size(margin, 2) X size(alpha,2)
    %                           That is, size of the matrix is 
    %                           no. values of margin X no. values of alpha
    %----------
    
    num_margin = size(marginVector,2);
    num_alpha = size(alphaVector,2);
    
    % Initialize
    Average_Ballots_Many = zeros(num_margin, num_alpha);
    
    for i=1:num_margin
        for s=1:num_alpha         
            Average_Ballots_Many(i,s) = ASN(marginVector(i), alphaVector(s));
        end
    end
end