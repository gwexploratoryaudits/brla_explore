margin = (2391-1414)/(2391+1414);
alpha = 0.1;
[Minerva_first_round, ~, ~, ~, ~] = NextRoundSize(margin, alpha, [], (0), (0), ...
            (1), (1), 0, 0, (0.9), 500, 0.0001); %109
[Minerva_first_round_2, ~, ~, ~, ~] = NextRoundSize(margin, alpha, [], (0), (0), ...
            (1), (1), 0, 0, (0.95), 500, 0.0001); %139

%--- For SB round size
[~, ~, n1, kmin1] = B2BRAVOkmin(margin, alpha);
[StopSched1, StopValue1, ExpectedBallots1] = B2Risks(margin, [], n1, kmin1, 0);
stopping_values = StoppingPercentiles(n1, StopSched1, (0.9)); % 148 + 36 percent over Minerva
stopping_values_2 = StoppingPercentiles(n1, StopSched1, (0.95)); % 197 + 33 percent over Minerva

%--- For EoR round size
[next_round_EoR, ~, sprob] = ...
           BinaryNextRoundSizeGranular(margin, alpha, 1.0, (0), (0), (1), ...
               (1), 0, (0.95), 500, 0.0001, 'EoR'); %288 more than 100% over Minerva
