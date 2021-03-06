function [RiskSched, CurrentTier] = R2RisksWithReplacement(margin, n, kmin)
    %
    % [RiskSched, CurrentTier] = R2RisksWithReplacement(margin, n, kmin)
    % This function returns round-by-round stopping probability 
    % (stopping probbaility schedule/risk schedule) for a round-by-round 
    % audit defined by a round schedule n and a corresponding kmin 
    % schedule kmin, applied to an election defined by margin.
    % Note that, if margin=0, it returns round-by-round risk schedule.
    % ONLY FOR AUDITING WITH REPLACEMENT.
    % USES FOURIER TRANSFORM.
    %----------
    %
    % Input Values: 
    %   margin:         announced margin as a fraction for stopping probs;
    %                   zero for risk calculations
    %   n:              row vector of cumulative sample sizes (round schedule)
    %   kmin:           row vector of same size as n
    %
    %   n and kmin are typically outputs of R2BRAVOkmin or Athenakmin 
    %   using margin (when non-zero) and alpha. the jth value of 
    %   kmin is the minimum number of votes for winner required to 
    %   terminate the audit round of size n(j). 
    %
    %----------
    %
    % Output Values
    %   RiskSched:          array of individual risk values. jth value is 
    %                           the risk (or stopping prob.) of drawing 
    %                           n(j) ballots, round-by-round.                      
    %
    %----------
    %
    % The right tail of the pdf at a round is the risk of the round, when
    % the pdf represents the underlying vote distribution. 
    % The worst case risk corresponds to a tied election, see Bayesian 
    % RLA paper. 

    % p: fractional vote count for winner
    p = (1+margin)/2;
    % NumberRounds is the size of n and kmin
    NumberRounds = size(n,2);

    % Initialize risk schedule (or stopping prob. sched when margin is not 
    % zero). 
    RiskSched = zeros(1,NumberRounds);
    
    % Initialize CurrentTier: zero ballots with probability 1. 
    CurrentTier = [1];
    current_number_ballots = 0; 

    %---------For jth audit round-----------  
    % k: number of votes for the winner
    % Suppose the audit progresses to round j, j > 1. In order to compute 
    % the new pdf resulting from drawing more votes to get a total of n(j) 
    % votes, we use CurrentTier from the previous draw and the pdf for the 
    % probabilities of the entire sample drawn next to compute the new pdf. 
    % The risk is the right tail of this newly-computed pdf, which is 
    % lopped off at kmin and above. The resulting lopped-off function is 
    % the (new) CurrentTier. 

    for j=1:NumberRounds
        new_round_draws = n(j)-current_number_ballots;
        
        % Vote distribution after drawing new_round_draws
        CurrentTier = R2CurrentTier(margin, CurrentTier, new_round_draws);
        
        % Risk for this round: 
        RiskSched(j) = sum(CurrentTier(kmin(j)+1:size(CurrentTier,2)));
        
        % Lop off at kmin: 
        CurrentTier = CurrentTier(1,1:kmin(j));
        
        % update current_number_ballots
        current_number_ballots = n(j);
    end
end