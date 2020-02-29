        % Obtain risk and stopping probability schedules assuming k=kmin for 
        % most recent round
        StopSched = R2RisksWithReplacement(margin,[n_prev n],[kmin_prev k]);
        RiskSched = R2RisksWithReplacement(0,[n_prev n],[kmin_prev k]);