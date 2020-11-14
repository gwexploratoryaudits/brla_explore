ballots=4905022; 
alpha = 0.1;
delta = 1.0;
tally=[1613896 1270718 978667 323518 135745 106552 94201 51513 44849 44231 40266 36114 35354 28617 26311 17922 15269 14614 13280 13253];
margins(1,:) = (tally(1)-tally(3:20))./(tally(1)+tally(3:20));
margins(2,:) = (tally(2)-tally(3:20))./(tally(2)+tally(3:20));
sample = [384, 276, 234, 71, 40, 23, 16, 18, 11, 9, 13, 9, 8, 5, 4, 6, 5, 4, 4, 8, 0];
for j=1:2
    for i=1:size(margins,2)
        currently_drawn_ballots = 0;
        n_in(j, i) = sample(j)+sample(i+2);
        this_draw = n_in(j,i)-currently_drawn_ballots;
        CurrentTierStop = binopdf(0:this_draw,this_draw, 0.5*(1+margins(j,i)));
        CurrentTierRisk = binopdf(0:this_draw,this_draw, 0.5);
        StopSched = (0);
        RiskSched = (0);
        [pvalue(j,i), LR(j,i)] = p_value(margins(j,i), StopSched, RiskSched, ...
    CurrentTierStop, CurrentTierRisk, n_in(j,i), sample(j), 'Minerva');
    end
end