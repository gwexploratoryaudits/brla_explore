margin = (400-100)/500;
alpha = 0.1;
delta = 1.0;
StopSched_prev = (0);
RiskSched_prev = (0);
CurrentTierRisk = (1);
CurrentTierStop = (1);
n_prev=0;
percentiles = [0.9, 0.8, 0.7];
n_prev=0;
max_round_size = 10000;
tolerance = 0.0001;
audit_method = 'Minerva';