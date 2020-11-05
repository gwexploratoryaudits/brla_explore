% This script is called from within first_round_preds
        % This is first round. Initialization parameters below are fixed
        currently_drawn_ballots = 0;
        currently_drawn_ballots_B = 0;
        CurrentTierStop = (1);
        CurrentTierRisk = (1);
        CurrentTierStop_B = (1);
        CurrentTierRisk_B = (1);
        StopSched = (0);
        RiskSched = (0);
        StopSched_B = (0);
        RiskSched_B = (0);
        
        [next_round_size, next_round_kmin, next_round_sprob] = ...
                AverageNextRoundSizeGranular(margin, alpha, [], ...
                StopSched, RiskSched, CurrentTierStop, CurrentTierRisk, ...
                0, (0.8), 10000, 0.0001, audit_method);

            [next_round_size_B, next_round_kmin_B, next_round_sprob_B] = ...
                AverageNextRoundSizeGranular(margin, alpha, [], ...
                StopSched_B, RiskSched_B, CurrentTierStop_B, CurrentTierRisk_B, ...
                0, (0.8), 10000, 0.0001, audit_method_B);
