n_in(2) = 332;
k_all(2) = 182;

CurrentTierStop_Arlo = R2CurrentTier(margin,CurrentTierStop_Arlo,n_in(2)-n_in(1));
CurrentTierRisk_Arlo = R2CurrentTier(0,CurrentTierRisk_Arlo,n_in(2)-n_in(1));

CurrentTierStop_Athena = R2CurrentTier(margin,CurrentTierStop_Athena,n_in(2)-n_in(1));
CurrentTierRisk_Athena = R2CurrentTier(0,CurrentTierRisk_Athena,n_in(2)-n_in(1));

CurrentTierStop_Minerva = R2CurrentTier(margin,CurrentTierStop_Minerva,n_in(2)-n_in(1));
CurrentTierRisk_Minerva = R2CurrentTier(0,CurrentTierRisk_Minerva,n_in(2)-n_in(1));

CurrentTierStop_Metis = R2CurrentTier(margin,CurrentTierStop_Metis,n_in(2)-n_in(1));
CurrentTierRisk_Metis = R2CurrentTier(0,CurrentTierRisk_Metis,n_in(2)-n_in(1));

[pArlo(2), LR_Arlo(2)] = p_value(margin, StopSched_Arlo, RiskSched_Arlo, CurrentTierStop_Arlo, CurrentTierRisk_Arlo, n_in(2), k_all(2), 'Arlo');
[pAthena(2), LR_Athena(2)] = p_value(margin, StopSched_Athena, RiskSched_Athena, CurrentTierStop_Athena, CurrentTierRisk_Athena, n_in(2), k_all(2), 'Athena');
[pMinerva(2), LR_Minerva(2)] = p_value(margin, StopSched_Minerva, RiskSched_Minerva, CurrentTierStop_Minerva, CurrentTierRisk_Minerva, n_in(2), k_all(2), 'Minerva');
[pMetis(2), LR_Metis(2)] = p_value(margin, StopSched_Metis, RiskSched_Metis, CurrentTierStop_Metis, CurrentTierRisk_Metis, n_in(2), k_all(2), 'Metis');

kmin_Athena(2) = AthenaNextkmin(margin, alpha, delta, StopSched_Athena, RiskSched_Athena, CurrentTierStop_Athena, CurrentTierRisk_Athena, n_in(2), 'Athena');
kmin_Minerva(2) = AthenaNextkmin(margin, alpha, delta, StopSched_Minerva, RiskSched_Minerva, CurrentTierStop_Minerva, CurrentTierRisk_Minerva, n_in(2), 'Minerva');
kmin_Metis(2) = AthenaNextkmin(margin, alpha, delta, StopSched_Metis, RiskSched_Metis, CurrentTierStop_Metis, CurrentTierRisk_Metis, n_in(2), 'Metis');
[~, ~, ~, kmin_Arlo(2)] = R2BRAVOkmin(margin, alpha, n_in(2));

StopSched_Arlo(2) = sum(CurrentTierStop_Arlo(kmin_Arlo(2)+1:size(CurrentTierStop_Arlo,2)));
RiskSched_Arlo(2) = sum(CurrentTierRisk_Arlo(kmin_Arlo(2)+1:size(CurrentTierRisk_Arlo,2)));

StopSched_Athena(2) = sum(CurrentTierStop_Athena(kmin_Athena(2)+1:size(CurrentTierStop_Athena,2)));
RiskSched_Athena(2) = sum(CurrentTierRisk_Athena(kmin_Athena(2)+1:size(CurrentTierRisk_Athena,2)));

StopSched_Minerva(2) = sum(CurrentTierStop_Minerva(kmin_Minerva(2)+1:size(CurrentTierStop_Minerva,2)));
RiskSched_Minerva(2) = sum(CurrentTierRisk_Athena(kmin_Minerva(2)+1:size(CurrentTierRisk_Minerva,2)));

StopSched_Metis(2) = sum(CurrentTierStop_Metis(kmin_Metis(2)+1:size(CurrentTierStop_Metis,2)));
RiskSched_Metis(2) = sum(CurrentTierRisk_Metis(kmin_Metis(2)+1:size(CurrentTierRisk_Metis,2)));

CurrentTierStop_Arlo = CurrentTierStop_Arlo(1:kmin_Arlo(2));
CurrentTierRisk_Arlo = CurrentTierRisk_Arlo(1:kmin_Arlo(2));

CurrentTierStop_Athena = CurrentTierStop_Athena(1:kmin_Athena(2));
CurrentTierRisk_Athena = CurrentTierRisk_Athena(1:kmin_Athena(2));

CurrentTierStop_Minerva = CurrentTierStop_Minerva(1:kmin_Minerva(2));
CurrentTierRisk_Minerva = CurrentTierRisk_Minerva(1:kmin_Minerva(2));

CurrentTierStop_Metis = CurrentTierStop_Metis(1:kmin_Metis(2));
CurrentTierRisk_Metis = CurrentTierRisk_Metis(1:kmin_Metis(2));

fprintf('SECOND ROUND: round size and winner ballots [%d, %d], [%d, %d] \n\n', [n_in(1), n_in(2)], [k_all(1), k_all(2)]);
fprintf('Arlo kmin, p-value and LR: [%d, %d], [%f, %f], [%f, %f] \n\n', [kmin_Arlo(1), kmin_Arlo(2)], [pArlo(1),pArlo(2)], [LR_Arlo(1), LR_Arlo(2)]);
fprintf('Athena kmin, p-value and LR: [%d, %d], [%f, %f], [%f, %f] \n\n', [kmin_Athena(1), kmin_Athena(2)], [pAthena(1), pAthena(2)], [LR_Athena(1), LR_Athena(2)]);
fprintf('Minerva kmin, p-value and LR: [%d,%d], [%f, %f], [%f, %f] \n\n', [kmin_Minerva(1), kmin_Minerva(2)], [pMinerva(1), pMinerva(2)], [LR_Minerva(1), LR_Minerva(2)]);
fprintf('Metis kmin, p-value and LR: [%d,%d], [%f, %f], [%f,%f] \n\n', [kmin_Metis(1), kmin_Metis(2)], [pMetis(1), pMetis(2)], [LR_Metis(1), LR_Metis(2)]);

