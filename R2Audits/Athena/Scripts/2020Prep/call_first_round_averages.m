% This script is called from within average_next_rounds_preds
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
        this_draw = n_in;
        this_draw_B = n_in_B;
        
        % Generate winning vote distributions for each hypothesis
        CurrentTierStop = R2CurrentTier(margin,CurrentTierStop,this_draw);
        CurrentTierRisk = R2CurrentTier(0,CurrentTierRisk,this_draw);

        CurrentTierStop_B = R2CurrentTier(margin,CurrentTierStop_B,this_draw_B);
        CurrentTierRisk_B = R2CurrentTier(0,CurrentTierRisk_B,this_draw_B);
        
        % Compute kmin for Minerva
        kmin = AthenaNextkmin(margin, alpha, [], StopSched, RiskSched, ...
                CurrentTierStop, CurrentTierRisk, n_in, audit_method);
        
        % Compute kmin for EoR
        % for ease of computation
        % p is fractional vote for winner 
        p=(1+margin)/2;
        logpoveroneminusp=log(p/(1-p));
        kmslope = (log(0.5/(1-p)))/logpoveroneminusp;
        kmintercept = - (log (alpha))/logpoveroneminusp;
        kmin_B=ceil(kmslope*n_in + kmintercept);

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
        
        if kmin_B <= n_in_B
            % Round is large enough for  non-zero stopping probability. Compute 
            % tails for each hypothesis at kmin. If kmin too large
            % do not change any pdfs
            StopSched_B = sum(CurrentTierStop_B(kmin_B+1:size(CurrentTierStop_B,2)));
            RiskSched_B = sum(CurrentTierRisk_B(kmin_B+1:size(CurrentTierRisk_B,2)));
            % Compute new distribution for a next round size and kmin decision
            CurrentTierStop_B = CurrentTierStop_B(1:kmin_B);
            CurrentTierRisk_B = CurrentTierRisk_B(1:kmin_B);
        end
        
        [next_round_size, next_round_kmin, next_round_sprob] = ...
                AverageNextRoundSizeGranular(margin, alpha, [], ...
                StopSched, RiskSched, CurrentTierStop, CurrentTierRisk, ...
                n_in, (0.9), 10000, 0.0001, audit_method);

            [next_round_size_B, next_round_kmin_B, next_round_sprob_B] = ...
                AverageNextRoundSizeGranular(margin, alpha, [], ...
                StopSched_B, RiskSched_B, CurrentTierStop_B, CurrentTierRisk_B, ...
                n_in_B, (0.9), 10000, 0.0001, audit_method_B);
