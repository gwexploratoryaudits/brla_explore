% This script was used to check values in 
% https://github.com/filipzz/athena/blob/master/code/athena/test_athena.json
% They check out, for both values of margin
% NOTE the term "Arlo" IS NOW REPLACED BY "EoR" in the code. 
margin = 0.1;
% margin = 0.2903;
alpha = 0.1;
delta=1;
n_in = [193, 332, 587];
NumberRounds=size(n_in,2);

% Compute kmins
[~, ~, n_Arlo, kmin_Arlo] = R2BRAVOkmin(margin, alpha, n_in);
[RiskSched_Arlo, ~] = R2RisksWithReplacement(0, n_Arlo, kmin_Arlo);
[n_Athena, kmin_Athena, StopSched_Athena, RiskSched_Athena, ...
    ~, ~] = Athenakmin(margin, alpha, delta, n_in, 'Athena');
[n_Minerva, kmin_Minerva, StopSched_Minerva, RiskSched_Minerva, ...
    ~, ~] = Athenakmin(margin, alpha, [], n_in, 'Minerva');
[n_Metis, kmin_Metis, StopSched_Metis, RiskSched_Metis, ...
    ~, ~] = Athenakmin(margin, alpha, [], n_in, 'Metis');

CRiskSched_Arlo = CumDistFunc(RiskSched_Arlo);
CRiskSched_Athena = CumDistFunc(RiskSched_Athena);
CRiskSched_Minerva = CumDistFunc(RiskSched_Minerva);
CRiskSched_Metis = CumDistFunc(RiskSched_Metis);

fprintf('Arlo rounds and kmins: [%d, %d, %d], [%d, %d, %d]\n', n_Arlo, kmin_Arlo);
fprintf('Arlo RiskSched: [%f, %f, %f] \n\n\n', CRiskSched_Arlo);
fprintf('Athena rounds and kmins: [%d, %d, %d], [%d, %d, %d]\n', n_Athena, kmin_Athena);
fprintf('Athena RiskSched: [%f, %f, %f] \n\n\n', CRiskSched_Athena);
fprintf('Minerva rounds and kmins: [%d, %d, %d], [%d, %d, %d]\n', n_Minerva, kmin_Minerva);
fprintf('Minerva RiskSched: [%f, %f, %f] \n\n\n', CRiskSched_Minerva);
fprintf('Metis rounds and kmins: [%d, %d, %d], [%d, %d, %d]\n', n_Metis, kmin_Metis);
fprintf('Metis RiskSched: [%f, %f, %f] \n\n\n', CRiskSched_Metis);


