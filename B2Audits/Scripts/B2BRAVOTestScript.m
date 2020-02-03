% This script tests our code against Table 1 of the BRAVO paper.
% We find that, while average ballot counts are off very slightly
% (likely in part because we use only a finite number of ballot draws 
% (6*ASN) which will give you some differences), percentiles are very 
% accurate for larger margins. For smaller margins, percentiles are also 
% slightly off; we do not yet have an explanation for this other than 
% that perhaps the number of simulations performed is not sufficient to 
% expect a perfect match. Expected ballots differ from ASN in part, we 
% believe, because the likelihood ratio takes on discrete values and 
% is not continuously evaluated. That is also the reason for the risk 
% limit not being achieved. 
%
% The script generates n and kmin from function B2BRAVOkminMany, 
% then the stopping probability schedule and total stopping probabilities 
% from B2RisksMany, and, finally, the percentiles from 
% StoppingPercentilesMany.  
% 
% IT MAY TAKE TOO LONG TO DO ALL MARGINS AT ONCE. SEE NOTE IN SCRIPT.  
%------------
%
%Input: 
%   marginVector:	row of fractional margins
%   percentiles:    row of percentiles as fractions
%----------
% Output:
%   An array of size no. of margins X no. of percentiles:
%   BRAVOTable:         values of n in the BRAVO table
%
%   and two arrays of size no. of margins
%   ExpectedBallots:    expected ballot draws
%   ASNValues:          the theoretical values of expected ballot draws
%
% Computes all kinds of other values as described in B2RisksMany

% Compute margins in smaller batches: the first five together, then the 
% next two, and the last three individually. 
% margins = [0.4, 0.3, 0.2, 0.16, 0.1, 0.08, 0.06, 0.04, 0.02, 0.01];
marginVector = [0.01];
percentiles = [0.25, 0.5, 0.75, 0.9, 0.99];
alpha = [0.1];
% N is a dummy variable needed to compute other values computed by the 
% functions we call. N not needed anywhere in an audit with replacement. 
N = [1000];

% Generate BRAVO audit kmins
% nBRAVO_Many and kminBRAVO_Many are structured lists of the same size. 
% Each element of each list is an array corresponding to that value of 
% margin. nBRAVO is a list of arrays of sample sizes, beginning at the 
% first one of consequence. kminBRAVO is the list of corresponding arrays 
% of kmins. 
[nBRAVO_Many, kminBRAVO_Many] = B2BRAVOkminMany(marginVector, alpha);

% Generate stopping scheds and total probabilities for the same margins. 
% ``0'' is used to indicate an audit with replacement. 
[StopSched_Many, StopProb_Many, ExpectedBallots_Many] = B2RisksMany(marginVector, N, nBRAVO_Many, kminBRAVO_Many, 0);

% Obtain sample sizes for percentiles. 
BRAVOTable = StoppingPercentilesMany(nBRAVO_Many, StopSched_Many, percentiles);

% ASN Values
ASNValues = ASNMany(marginVector,alpha);