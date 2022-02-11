function pvalues = SBRisks(margin, alpha, votes)
%
% pvalues = SBRisks(margin, alpha, votes)
%
% This function returns a vector of SB p-values of the same length as 
% votes. 
%
% It updates the p-value multiplying by p/0.5 for winner votes and
% (1-p)/0.5 for loser votes. Nothing for irrelevants. 

for i=1:size(votes)
    