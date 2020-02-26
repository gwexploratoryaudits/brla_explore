margin = 0.2857;
alpha = 0.1;
delta=1;
n_in = [100];
k_all = [58];

NumberRounds=size(n_in,2);

% Allocate pvalues
pvalues_Arlo = zeros(1,NumberRounds);
pvalues_Athena = zeros(1,NumberRounds);
pvalues_Minerva = zeros(1,NumberRounds);

% Compute kmins
[n_Arlo, kmin_Arlo] = R2BRAVOkmin(margin, alpha, n_in);
[n_Athena, kmin_Athena, StopSched_Athena, RiskSched_Athena] = Athenakmin(margin, alpha, delta, n_in, 'Athena');
[n_Minerva, kmin_Minerva, StopSched_Minerva, RiskSched_Minerva] = Athenakmin(margin, alpha, [], n_in, 'Minerva');

% Compute pvalues
pvalues_Arlo(1) = p_value(margin, [], [], n_Arlo(1), k_all(1), 'Arlo');
pvalues_Athena(1) = p_value(margin, [], [], n_Athena(1), k_all(1), 'Athena');
pvalues_Minerva(1) = p_value(margin, [], [], n_Minerva(1), k_all(1), 'Minerva');

if NumberRounds > 1
    for j=2:NumberRounds
        pvalues_Arlo(j) = p_value(margin, n_Arlo(1:j-1), kmin_Arlo(1:j-1), n_Arlo(j), k_all(j), 'Arlo');
        pvalues_Athena(j) = p_value(margin, n_Athena(1:j-1), kmin_Athena(1:j-1), n_Athena(j), k_all(j), 'Athena');
        pvalues_Minerva(j) = p_value(margin, n_Minerva(1:j-1), kmin_Minerva(1:j-1), n_Minerva(j), k_all(j), 'Minerva');
    end
end
fprintf('Arlo rounds and kmins: [%d, %d, %d], [%d, %d, %d]\n', n_Arlo, kmin_Arlo);
fprintf('Arlo k and pvalues: [%d, %d, %d], [%f, %f, %f] \n\n\n', k_all, pvalues_Arlo);
fprintf('Athena rounds and kmins: [%d, %d, %d], [%d, %d, %d]\n', n_Athena, kmin_Athena);
fprintf('Athena k and pvalues: [%d, %d, %d], [%f, %f, %f] \n\n\n', k_all, pvalues_Athena);
fprintf('Minerva rounds and kmins: [%d, %d, %d], [%d, %d, %d]\n', n_Minerva, kmin_Minerva);
fprintf('Minerva k and pvalues: [%d, %d, %d], [%f, %f, %f] \n\n\n', k_all, pvalues_Minerva);

