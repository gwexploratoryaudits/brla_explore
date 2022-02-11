margin = (2391-1414)/(2391+1414);
alpha = 0.1;

this_draw = 140;

CurrentTierStop = binopdf(0:this_draw,this_draw, 0.5*(1+margin));
CurrentTierRisk = binopdf(0:this_draw,this_draw, 0.5);
StopSched = (0);
RiskSched = (0);
this_k=81;

[tail_ratio, LR] = p_value(margin, StopSched, ...
                RiskSched, CurrentTierStop, CurrentTierRisk, this_draw, ...
                this_k, 'Minerva');

sigma = 1/LR;
            