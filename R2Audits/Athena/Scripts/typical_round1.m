margin = 0.1;
alpha = 0.1;
delta=1;
n_in(1) = 193;
% 587
k_all(1) = 109
% 315

CurrentTierStop = R2CurrentTier(margin,(1),193);
CurrentTierRisk = R2CurrentTier(0,(1),193);

[pArlo(1), LR_Arlo(1)] = p_value(margin, (0), (0), CurrentTierStop, CurrentTierRisk, n_in(1), k_all(1), 'Arlo');
[pAthena(1), LR_Athena(1)] = p_value(margin, (0), (0), CurrentTierStop, CurrentTierRisk, n_in(1), k_all(1), 'Athena');
[pMinerva(1), LR_Minerva(1)] = p_value(margin, (0), (0), CurrentTierStop, CurrentTierRisk, n_in(1), k_all(1), 'Minerva');
[pMetis(1), LR_Metis(1)] = p_value(margin, (0), (0), CurrentTierStop, CurrentTierRisk, n_in(1), k_all(1), 'Metis');

kmin_Athena(1) = AthenaNextkmin(margin, alpha, delta, (0), (0), CurrentTierStop, ...
    CurrentTierRisk, 193, 'Athena');
kmin_Minerva(1) = AthenaNextkmin(margin, alpha, delta, (0), (0), CurrentTierStop, ...
    CurrentTierRisk, 193, 'Minerva');
kmin_Metis(1) = AthenaNextkmin(margin, alpha, delta, (0), (0), CurrentTierStop, ...
    CurrentTierRisk, 193, 'Metis');
[~, ~, ~, kmin_Arlo(1)] = R2BRAVOkmin(margin, alpha, 193);

CurrentTierStop_Arlo = CurrentTierStop;
CurrentTierStop_Athena = CurrentTierStop;
CurrentTierStop_Minerva = CurrentTierStop;
CurrentTierStop_Metis = CurrentTierStop;

CurrentTierRisk_Arlo = CurrentTierRisk;
CurrentTierRisk_Athena = CurrentTierRisk;
CurrentTierRisk_Minerva = CurrentTierRisk;
CurrentTierRisk_Metis = CurrentTierRisk;

StopSched_Arlo(1) = sum(CurrentTierStop_Arlo(kmin_Arlo(1)+1:size(CurrentTierStop_Arlo,2)));
RiskSched_Arlo(1) = sum(CurrentTierRisk_Arlo(kmin_Arlo(1)+1:size(CurrentTierRisk_Arlo,2)));

StopSched_Athena(1) = sum(CurrentTierStop_Athena(kmin_Athena(1)+1:size(CurrentTierStop_Athena,2)));
RiskSched_Athena(1) = sum(CurrentTierRisk_Athena(kmin_Athena(1)+1:size(CurrentTierRisk_Athena,2)));

StopSched_Minerva(1) = sum(CurrentTierStop_Minerva(kmin_Minerva(1)+1:size(CurrentTierStop_Minerva,2)));
RiskSched_Minerva(1) = sum(CurrentTierRisk_Athena(kmin_Minerva(1)+1:size(CurrentTierRisk_Minerva,2)));

StopSched_Metis(1) = sum(CurrentTierStop_Metis(kmin_Metis(1)+1:size(CurrentTierStop_Metis,2)));
RiskSched_Metis(1) = sum(CurrentTierRisk_Metis(kmin_Metis(1)+1:size(CurrentTierRisk_Metis,2)));

CurrentTierStop_Arlo = CurrentTierStop_Arlo(1:kmin_Arlo(1));
CurrentTierRisk_Arlo = CurrentTierRisk_Arlo(1:kmin_Arlo(1));

CurrentTierStop_Athena = CurrentTierStop_Athena(1:kmin_Athena(1));
CurrentTierRisk_Athena = CurrentTierRisk_Athena(1:kmin_Athena(1));

CurrentTierStop_Minerva = CurrentTierStop_Minerva(1:kmin_Minerva(1));
CurrentTierRisk_Minerva = CurrentTierRisk_Minerva(1:kmin_Minerva(1));

CurrentTierStop_Metis = CurrentTierStop_Metis(1:kmin_Metis(1));
CurrentTierRisk_Metis = CurrentTierRisk_Metis(1:kmin_Metis(1));

fprintf('FIRST ROUND: round size and winner ballots %d, %d \n\n', n_in(1), k_all(1));
fprintf('Arlo kmin, p-value and LR: %d, %f, %f \n\n', kmin_Arlo(1), pArlo(1), LR_Arlo(1));
fprintf('Athena kmin, p-value and LR: %d, %f, %f \n\n', kmin_Athena(1), pAthena(1), LR_Athena(1));
fprintf('Minerva kmin, p-value and LR: %d, %f, %f \n\n', kmin_Minerva(1), pMinerva(1), LR_Minerva(1));
fprintf('Metis kmin, p-value and LR: %d, %f, %f \n\n', kmin_Metis(1), pMetis(1), LR_Metis(1));

