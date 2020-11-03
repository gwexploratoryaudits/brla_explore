% This script is called from within average_next_rounds_preds
        % This is first round. Initialization parameters below are fixed
        currently_drawn_ballots = 0;
        CurrentTierStop = (1);
        CurrentTierRisk = (1);
        StopSched = (0);
        RiskSched = (0);
        this_draw = n_in;
        
        % Generate winning vote distributions for each hypothesis
        CurrentTierStop = R2CurrentTier(margin,CurrentTierStop,this_draw);
        CurrentTierRisk = R2CurrentTier(0,CurrentTierRisk,this_draw);

        % Compute kmin
        kmin = AthenaNextkmin(margin, alpha, [], StopSched, RiskSched, ...
                CurrentTierStop, CurrentTierRisk, n_in, audit_method);

        % Compute distributions for next round size and the next round
        if kmin <= n_in
            % Round is large enough for  non-zero stopping probability. Compute 
            % tails for each hypothesis at kmin. If kmin too large
            % do not change any pdfs
            StopSched = sum(CurrentTierStop(kmin+1:size(CurrentTierStop,2)));
            RiskSched = sum(CurrentTierRisk(kmin+1:size(CurrentTierRisk,2)));
            % Compute new distribution for a next round size and kmin decision
            CurrentTierStop = CurrentTierStop(1:kmin);
            CurrentTierRisk = CurrentTierRisk(1:kmin);
        end
        
        [next_round_size, next_round_kmin, next_round_sprob] = ...
                AverageNextRoundSizeGranular(margin, alpha, [], ...
                StopSched, RiskSched, CurrentTierStop, CurrentTierRisk, ...
                n_in, (0.9), 10000, 0.0001);