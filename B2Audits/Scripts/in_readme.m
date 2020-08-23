[~, ~, n1, kmin1] = B2BRAVOkmin(0.4, 0.1);
plot(n1, kmin1)
[n2, kmin2, ~] = B2BRAVOLikekmin(0.4, 0.1, 200);
plot(n2, kmin2)
plot_bravos(0.4, 0.1, 200)
margins = [0.4, 0.3, 0.2, 0.16, 0.1];
alpha = (0.1);
[nBRAVO, kminBRAVO] = B2BRAVOkminMany(margins, alpha);
alpha2 = [0.1,0.05];
[nBRAVO2, kminBRAVO2] = B2BRAVOkminMany(margins, alpha2);
for i=1:size(margins,2)
    for s=1:size(alpha2,2)
        plot(nBRAVO2{i,s}, kminBRAVO2{i,s})
        hold on
    end
end
N=(1000);
[nBRAVOLike, kminBRAVOLike] = B2BRAVOLikekminMany(margins, alpha, N);
[nBRAVOLike2, kminBRAVOLike2] = B2BRAVOLikekminMany(margins, alpha2, N2);
for i=1:size(margins,2)
    for s=1:size(alpha2,2)
        for t=1:size(N2,2)
            plot(nBRAVOLike2{i,s}, kminBRAVOLike2{i,s})
            hold on
        end
    end
end
[StopSched1, StopValue1, ExpectedBallots1] = B2Risks(0.4, [], n1, kmin1, 0);
[StopSched2, StopValue2, ExpectedBallots2] = B2Risks(0.4, 200, n2, kmin2, 1);
plot(n1,StopSched1)
hold on
plot(n2,StopSched2)
[RiskSched1, RiskValue1, ExpectedBallotsInCorrect1] = B2Risks(0, [], n1, kmin1, 0);
plot(n1, RiskSched1)
hold on
plot(n1,StopSched1/10)
[StopSchedBRAVO, StopProbBRAVO, ExpectedBallotsCorrectBRAVO] = ...
    B2RisksMany(margins, [], nBRAVO, kminBRAVO, 0);
for i=1:size(margins,2)
    for s=1:size(alpha,2)
        plot(nBRAVO{i,s}, StopSchedBRAVO{i,s})
        hold on
    end
end
margin_incorrect = zeros(1,size(margins,2)); 
[RiskSchedBRAVO, RiskValueBRAVO, ExpectedBallotsInCorrectBRAVO] = ...
    B2RisksMany(margin_incorrect, N, nBRAVO, kminBRAVO, 0);
for i=1:size(margins,2)
    for s=1:size(alpha,2)
        plot(nBRAVO{i,s}, RiskSchedBRAVO{i,s})
        hold on
    end
end
[StopSchedBRAVOLike, StopProbBRAVOLike, ExpectedBallotsCorrectBRAVOLike] = ...
    B2RisksMany(margins, N, nBRAVOLike, kminBRAVOLike, 1);
for i=1:size(margins,2)
    for s=1:size(alpha,2)
        for t=1:size(N,2)
            plot(nBRAVOLike{i,s,t}, StopSchedBRAVOLike{i,s,t})
            hold on
        end
    end
end

percentiles = [0.25, 0.5, 0.75, 0.9, 0.99];
stopping_values = StoppingPercentiles(n1, StopSched1, percentiles);

% Here are the first five rows of Bravo Table 1. 
BRAVOTable = StoppingPercentilesMany(nBRAVO,StopSchedBRAVO,percentiles)
ASNMany(margins,(0.1))
ExpectedBallotsCorrectBRAVO
