margin = 0.2903;
alpha = 0.1;
delta=1;
n_in = 193; 
CurrentTierStop = R2CurrentTier(margin,(1),193);
CurrentTierRisk = R2CurrentTier(0,(1),193);
kmin = AthenaNextkmin(margin, alpha, delta, (0), ...
     (0), CurrentTierStop, CurrentTierRisk, 193, 'Athena')