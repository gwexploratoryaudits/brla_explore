% This script tests our code against first 5 rows of Table 1 of the BRAVO
% paper. We find that, while average ballot counts are off by a bit
% (likely because we use only a finite number of ballot draws (6*ASN)
% which will give you some differences), percentiles are very accurate. 
%
% The script generates n and kmin from function BSquareBRAVOkminMany, 
% then the risk schedule and stopping probabilities from 
% BSquareRisksMany, and, finally, the percentiles from Stopping Percentiles. 
%
%------------
%
%Input: 
%   margin:         row of fractional margins
%   percentiles:    row of percentiles as fractions
%----------
% Output:
%   An array of size:   size(margin,2) X size(percentiles,2)
%   BRAVOTable:         values of n in the BRAVO table
%   and arrays of size: size(margin,2) 
%   ExpectedBallots:    expected ballot draws
%
% Computes all kinds of other values as described in BSquareRisksMany

margins = [0.4, 0.3, 0.2, 0.16, 0.1];
percentiles = [0.25, 0.5, 0.75, 0.9, 0.99];
alpha = [0.1];
% dummy variable needed to compute other values computed by the functions
% we call. 
N = [1000];

% Generate BRAVO audit kmins
[nBRAVO, kminBRAVO] = BSquareBRAVOkminMany(margins, alpha);
% Generate stopping probabilities for the same margin. Pass alpha for 
% array sizes. 
[StopSched, StopProb, ExpectedBallots] = BSquareRisksMany(margins, alpha, N, nBRAVO, kminBRAVO, 0);
% Obtain values of n for percentiles. 
BRAVOTable = StoppingPercentiles(StopSched, nBRAVO, percentiles);



