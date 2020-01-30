% This script computes the parameters of a BSquare audit needed to design
% a corresponding RSquare audit. It is intended for use when time 
% is not an issue: between election results and audit. 
%
% The script generates n and kmin using function BSquareBRAVOkmin, 
% then the risk schedule using BSquareRisks. 
%
% n and the corresponding risk schedule are the only variables needed for 
% an RSquare audit. They are denoted nB2 and RiskSchedB2. 
% 
%------------
%
%Input: 
%   margin:         election margin for BSquareBRAVO and the stopping
%                       probs. 
%   alpha:          risk limit
%   N:              election size
%	audit_type:     0 (with replacement)/anything else (without)
%----------
% Output:
%   RiskValueB2
%   Row arrays of size N (without replacement) or 6*ASN (with): 
%       nB2, kminB2, RiskSchedB2 

margin = 0.1;
alpha = 0.1;
audit_type = 0;
% N is a dummy variable needed to compute other values computed by the 
% functions we call. N not needed anywhere in an audit with replacement. 
N = 14000; %anticipated election size for Defiance County

if audit_type == 0
    % Generate BSquare BRAVO audit kmins
    [kmslope, kmintercept, nB2BRAVO, kminB2BRAVO] = BSquareBRAVOkmin(margin,alpha);

    % Risk schedule of Bsquare audit, margin=0. Don't need ExpectedBallots
    % RiskValue is a sanity check. 
    [RiskSchedB2BRAVO, RiskValueB2BRAVO, ExpectedBallotsB2BRAVO] = BSquareRisks(0, N, nB2BRAVO, kminB2BRAVO, 0);
else
    % Generate BSquare BRAVOLike audit kmins
    [nB2BRAVOLike, kminB2BRAVOLike, LLR] = BSquareBRAVOkmin(margin,alpha, N);

    % Risk schedule of Bsquare audit, margin=0. Don't need ExpectedBallots
    % RiskValue is a sanity check. 
    [RiskSchedB2BRAVOLike, RiskValueB2BRAVOLike, ExpectedBallotsB2BRAVOLike] = BSquareRisks(0, N, nB2BRAVOLike, kminB2BRAVOLike, 1);

end
