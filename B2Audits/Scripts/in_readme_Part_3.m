% This runs the examples of the read_me file in B2Audits and plots them
% Part 3: Percentiles
% RUN PART 1 FIRST, then PART 2 and then this
% The script is broken up to make the plots more manageable. 

percentiles = [0.25, 0.5, 0.75, 0.9, 0.99];
stopping_values = StoppingPercentiles(n1, StopSched1, percentiles);

% Here are the first five rows of Bravo Table 1. 
BRAVOTable = StoppingPercentilesMany(nBRAVO,StopSchedBRAVO,percentiles)
Many_ASN = ASNMany(margins,(0.1))
ExpectedBallotsCorrectBRAVO

% For comparison, BravoLike, see Tables/BRAVO-BRAVOLike 1K Table I.pdf
BRAVOLikeTable = StoppingPercentilesMany(nBRAVOLike,StopSchedBRAVOLike, percentiles)
ExpectedBallotsCorrectBRAVOLike

% The values below may be checked against: Tables/BRAVO-BRAVOLike Risks 1K Table I.pdf
risk_percentiles = alpha(1,1)*percentiles;
BRAVORiskTable = StoppingPercentilesMany(nBRAVO,RiskSchedBRAVO, risk_percentiles)
BRAVOLikeRiskTable = StoppingPercentilesMany(nBRAVOLike,RiskSchedBRAVOLike, risk_percentiles)

