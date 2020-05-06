 function nkmin = Athena_normalized_kmin(margin, alpha, delta, ...
     resolution, audit_method)
    % Intentional, we haven't yet incorporated resolution into this. 
    % nkmin = Athena_normalized_kmin(margin, alpha, delta, ...
    %   resolution, audit_method)
    % Athena normalized kmin values at resolution. 
    % beta = 0; sampling with replacement. 
    % -----------
    % Input: 
    %   margin:         row vector of fractional margins
    %   alpha:          row vector of fractional risk limits
    %   delta:          LR stopping condition for Athena
    %   resolution:     normalized kmins are accurate upto resolution. 
    %   audit_method:   string, one of: Athena, Minerva, Metis
    %                       Athena and Minerva have the same p_values for 
    %                       the same kmins, but their kmins are, in 
    %                       general, distinct for the same round sizes
    %                       because their stopping conditions are distinct.
    %                       delta is needed only for Athena. 
    %
    % THIS IS CURRENTLY ONLY FOR SAMPLING WITH REPLACEMENT.
    % Does not support Arlo. Use R2BRAVOkmin for Arlo. 
    %
    % ----------
    % Output: 
    %	nkmin:          2-D array of normalized kmins, of size
    %                       size(margin,2) X size(alpha, 2). 
    %                       nkmin(i,j) = nkmin(margin(i), alpha(j))
    %                           
    % -----------
    %
    % nkmin(i,j) = smallest normalized value k such that stopping conditions 
    %                   are met for alpha(i), margin(j) and given delta. 
    %

    %-------------Preliminaries--------------
    % p is fractional vote for winner 
    p=(1+margin)/2;
    
    % NumberRounds is the size of n_in and max size of n_out and kmin
    NumberRounds = size(n_in,2);

    % Allocate risk/ stopping prob. scheds., kmin
    RiskSched = zeros(1,NumberRounds);
    StopSched = zeros(1,NumberRounds);
    kmin = zeros(1, NumberRounds);
    CurrentTierStop = (1);
    CurrentTierRisk = (1);
    current_number_ballots = 0;
    
    for j=1:NumberRounds
        CurrentTierStop = R2CurrentTier(margin,CurrentTierStop,n_in(j)-current_number_ballots);
        CurrentTierRisk = R2CurrentTier(0,CurrentTierRisk,n_in(j)-current_number_ballots);
        kmin(j) = AthenaNextkmin(margin, alpha, delta, StopSched, ...
                    RiskSched, CurrentTierStop, CurrentTierRisk, ...
                    n_in(j), audit_method);
 
        if kmin(j) > n_in(j)
            % round not large enough; do not lop off, nothing happens
        else
            % Lop off at kmin:
            StopSched(j) = sum(CurrentTierStop(kmin(j)+1:size(CurrentTierStop,2)));
            RiskSched(j) = sum(CurrentTierRisk(kmin(j)+1:size(CurrentTierRisk,2)));
            CurrentTierStop = CurrentTierStop(1,1:kmin(j));
            CurrentTierRisk = CurrentTierRisk(1,1:kmin(j));
            current_number_ballots = n_in(j);
        end
    end
    
    % Remove rounds where kmin > n_in
    Invalid_n = find(kmin > n_in);
    kmin(Invalid_n) = [];
    n_in(Invalid_n) = [];
    n_out = n_in;
 end


    