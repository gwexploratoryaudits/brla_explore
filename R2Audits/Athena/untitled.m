        % Obtain risk and stopping probability schedules assuming k=kmin for 
        % most recent round
        StopSched = R2RisksWithReplacement(margin,[n_prev n],[kmin_prev k]);
        RiskSched = R2RisksWithReplacement(0,[n_prev n],[kmin_prev k]);
        
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




