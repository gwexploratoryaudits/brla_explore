margin = 0.1;
alpha = 0.1;
delta=1;
n_in = [193, 332, 587];
k_all = [109, 182, 315];
NumberRounds=size(n_in,2);

pArlo = zeros(1,3);
pAthena = zeros(1,3);
pMinerva = zeros(1,3);
pMetis = zeros(1,3);

LR_Arlo = zeros(1,3);
LR_Athena = zeros(1,3);
LR_Minerva = zeros(1,3);
LR_Metis = zeros(1,3);

CurrentTierStop = R2CurrentTier(margin,(1),193);
CurrentTierRisk = R2CurrentTier(0,(1),193);

[p_Arlo(1), LR_Arlo(1)] = p_value(margin, (0), (0), CurrentTierStop, CurrentTierRisk, n_in(1), k_all(1), 'Arlo');
[p_Athena(1), LR_Athena(1)] = p_value(margin, (0), (0), CurrentTierStop, CurrentTierRisk, n_in(1), k_all(1), 'Athena');
[p_Minerva(1), LR_Minerva(1)] = p_value(margin, (0), (0), CurrentTierStop, CurrentTierRisk, n_in(1), k_all(1), 'Minerva');
[p_Metis(1), LR_Metis(1)] = p_value(margin, (0), (0), CurrentTierStop, CurrentTierRisk, n_in(1), k_all(1), 'Metis');

kmin_Athena = AthenaNextkmin(margin, alpha, delta, (0), (0), CurrentTierStop, ...
    CurrentTierRisk, 193, 'Athena');
kmin_Minerva = AthenaNextkmin(margin, alpha, delta, (0), (0), CurrentTierStop, ...
    CurrentTierRisk, 193, 'Minerva');
kmin_Metis = AthenaNextkmin(margin, alpha, delta, (0), (0), CurrentTierStop, ...
    CurrentTierRisk, 193, 'Metis');
[~, ~, ~, kmin_Arlo] = R2BRAVOkmin(margin, alpha, 193);
