%margin = (3365775-3321037)/(3365775+3321037);
% 155976      114648       90719
%margin = 0.01;
% 69837       51231       40702
% margin = 100/7000;
% 34249       25154       19958

margin = (1270718-978667)/(1270718+978667);
alpha = 0.1;
delta = 1.0;
StopSched_prev = (0);
RiskSched_prev = (0);
CurrentTierRisk = (1);
CurrentTierStop = (1);
n_prev=0;
percentiles = [0.9];
n_prev=0;
max_round_size = 10000;
tolerance = 0.0001;
audit_method = 'Minerva';