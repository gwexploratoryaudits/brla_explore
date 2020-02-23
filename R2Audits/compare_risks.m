margin = 0.1;
alpha = 0.1;
delta=1;
n_in = [100, 200, 300];
k_all = [67, 130, 195];

k_prev = k_all(1:2);;
n_prev = n_in(1:2);
n = n_in(3);
k = k_all(3);

% Compute kmins
[n_Arlo, kmin_Arlo] = R2BRAVOkmin(margin, alpha, n_in);
[n_Athena, kmin_Athena] = Athenakmin(margin, alpha, delta, n_in, 'Athena');
[n_Minerva, kmin_Minerva] = Athenakmin(margin, alpha, delta, n_in, 'Minerva');

kmin_Arlo_prev = kmin_Arlo(1:2);
kmin_Athena_prev = kmin_Athena(1:2);
kmin_Minerva_prev = kmin_Minerva(1:2);

% Compute pvalues
pvalues_Arlo = p_value(margin, n_prev, kmin_Arlo_prev, k_prev, n, k, 'Arlo');
pvalues_Athena = p_value(margin, n_prev, kmin_Athena_prev, k_prev, n, k, 'Athena');
pvalues_Minerva = p_value(margin, n_prev, kmin_Minerva_prev, k_prev, n, k, 'Minerva');

fprintf('Arlo rounds, kmins, k and pvalues: [%d, %d, %d], [%d, %d, %d], [%d, %d, %d], [%f, %f, %f] \n\n\n', n_Arlo, kmin_Arlo, k_all, pvalues_Arlo);
fprintf('Athena rounds, kmins, k and pvalues: [%d, %d, %d], [%d, %d, %d], [%d, %d, %d], [%f, %f, %f] \n\n\n', n_Athena, kmin_Athena, k_all, pvalues_Athena);
fprintf('Minerva rounds, kmins, k and pvalues: [%d, %d, %d], [%d, %d, %d], [%d, %d, %d], [%f, %f, %f] \n\n\n', n_Minerva, kmin_Minerva, k_all, pvalues_Minerva);

