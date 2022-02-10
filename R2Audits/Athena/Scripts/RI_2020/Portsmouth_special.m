margin = (2391-1414)/(2391+1414);
alpha = 0.1;
[Minerva_first_round, ~, ~, ~, ~] = NextRoundSize(margin, alpha, [], (0), (0), ...
            (1), (1), 0, 0, (0.9), 500, 0.0001); %109
        
%--- For SB round size
[~, ~, n1, kmin1] = B2BRAVOkmin(margin, alpha);
[StopSched1, StopValue1, ExpectedBallots1] = B2Risks(margin, [], n1, kmin1, 0);
stopping_values = StoppingPercentiles(n1, StopSched1, (0.9)); % 148 + 36 percent over Minerva