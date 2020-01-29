% CURRENTLY WORKS ONLY FOR ONE RISK LIMIT AND ONE VALUE OF N
% Given margins, risk limits and values of N, this script generates the 
% total risk and risk schedule of various B-square audits, each represented 
% by an array of sample sizes, and an array of kmin of the same length. 
% The script also generates the schedule of stopping probabilities 
% assuming an underlying election of the given margin. 
%
% Currently the two types of B-square audits are BRAVO and BRAVO-like 
% (BRAVO without replacement). The script generates arrays of n and 
% corresponding kmin using functions BSquareBRAVOkminMany and 
% BSquareBRAVOLikekminMany, and then the risk schedule and stopping 
% probabilities from BSquareRisksMany. These functions, in turn, call 
% BSquareBRAVOkmin, BSquareBRAVOLikekmin and BSquareRisks many times. 
% Types of audits: BRAVO and BRAVO-like, with BRAVO being output first. 
%
% Output BRAVOTable may be compared to the corresponding values in Table 1
% of the BRAVO paper. ASNMany may be used to compute the last column of 
% the table. It is not computed by this script. To compute only the 
% BRAVO Table and not compare it with BRAVOLike, use
% BSquareBRAVOTestScript. 
% The input values for the first five rows of the BRAVO Table are: 
% margins = [0.4, 0.3, 0.2, 0.16, 0.1];
% alpha = [0.1];
% percentiles = [0.25, 0.5, 0.75, 0.9, 0.99];
% N = [1000];
% For the next five, margins changes to [0.08, 0.06, 0.04, 0.02, 0.01]
% other values are the same. May take too long to run all small margins
% at once. Perhaps run it for 0.08 and 0.06 together and smaller ones 
% individually. 
%
% Also computed is a similar RiskTable to compute the percentile of allowed
% risk. Thus the 25th percentile for a risk limit of 0.1 is the no. of 
% samples drawn, ballot-by-ballot, to reach a risk of 0.25*0.1  or 0.025, 
% i.e. 2.5%. 
%------------
%
% Input: 
%   margins:        row array of fractional margins; low margins take long
%   alpha:          fractional risk limit
%   N:              total votes cast for two candidates
%   percentiles:	row array of percentiles desired, such as in BRAVO
%                       Table. 
%----------
%
% Output: ("Z" refers to the type of audit)
%
% Each output below is an array of size: 
%               no of margin values X no of percentiles
%
%   ZTable:                     array listing percentiles
%   ZRiskTable:                 risk percentile
%
%   Each output below is an array of size: 
%       no. of margin values X no. of alpha values X no of N values
% 
%	RiskValueZ:                 the total risk
%	StopProbZ:                  the total stopping probability, should 
%                                   be one for BRAVOLike
%	ExpectedBallotsIncorrectZ:	expected number of ballots examined when 
%                                   outcome is incorrect. Sanity check. 
%                                   Should be larger than (1-risk-limit)*N 
%   ExpectedBallotsCorrectZ:	expected number of ballots for given 
%                                   margin when outcome is correct. 
%
%   Also outputs two lists (for each type of audit) of size 
%       no. of margin values X no. of alpha values X no of N values
%   each list element is an array of the size of the corresponding array n
%   RiskSchedZ_Many:            the risk schedules, corresponding to the 
%                                   array entry in variable "RiskValueZ" 
%                                   above.
%   StopSchedZ_Many:            the schedule of stopping probabilities, 
%                                   corresponding to the array entry in 
%                                   variable "StopProbZ" above.
%
%
% Towards the above ends, the script also generates: three structured 
% lists, each of size: 
%       no. of margin values X no. of alpha values X no of N values
% each list element is an array (different-sized arrays):
%	nZ_Many:         each element of this list is a 1-D array n from 
%                       BSquareBRAVOLikekmin. It begins at the smallest 
%                       sample size for which a kmin no larger than 
%                       sample size gives a large enough likelihood 
%                       ratio and ends at the corresponding value of N. 
%	kminZ_Many:      each element of this list is a 1-D array kmin from
%                       BSquareBRAVOLike kmin; jth value is the minimum 
%                       number of votes for winner required to terminate 
%                       an audit with sample size n(j).
%
%--------

margins = [0.01];
alpha = [0.1];
percentiles = [0.25, 0.5, 0.75, 0.9, 0.99];
N = [10000];

% margin_incorrect is the zero margin required to compute the max risk 
margin_incorrect = zeros(1,size(margins,2));

% risk percentiles are percentiles of total risk limit. 
risk_percentiles = alpha(1,1)*percentiles;

%--------------BRAVO------------%
[nBRAVO, kminBRAVO] = BSquareBRAVOkminMany(margins, alpha);
[StopSchedBRAVO, StopProbBRAVO, ExpectedBallotsCorrectBRAVO] = BSquareRisksMany(margins, N, nBRAVO, kminBRAVO, 0);
[RiskSchedBRAVO, RiskValueBRAVO, ExpectedBallotsInCorrectBRAVO] = BSquareRisksMany(margin_incorrect, N, nBRAVO, kminBRAVO, 0);

%--------------BRAVOLike------------%
[nBRAVOLike, kminBRAVOLike] = BSquareBRAVOLikekminMany(margins, alpha, N);
[StopSchedBRAVOLike, StopProbBRAVOLike, ExpectedBallotsCorrectBRAVOLike] = BSquareRisksMany(margins, N, nBRAVOLike, kminBRAVOLike, 1);
[RiskSchedBRAVOLike, RiskValueBRAVOLike, ExpectedBallotsInCorrectBRAVOLike] = BSquareRisksMany(margin_incorrect, N, nBRAVOLike, kminBRAVOLike, 1);

%--------------Stopping Percentiles-----------%
BRAVOTable = StoppingPercentilesMany(nBRAVO,StopSchedBRAVO,percentiles);
BRAVOLikeTable = StoppingPercentilesMany(nBRAVOLike,StopSchedBRAVOLike, percentiles);

%--------------Risk Percentiles---------------%
BRAVORiskTable = StoppingPercentilesMany(nBRAVO,RiskSchedBRAVO, risk_percentiles);
BRAVOLikeRiskTable = StoppingPercentilesMany(nBRAVOLike,RiskSchedBRAVOLike, risk_percentiles);

