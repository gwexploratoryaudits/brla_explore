function [RiskSched, RiskValue] = R2RisksWithFFT(margin, n, kmin)
    %
    % [RiskSched, RiskValue] = R2RisksWithFFT(margin, n, kmin)
    % This function uses the FFT to return:
    %       round-by-round stopping probability 
    %       total stopping probability 
    %       number of expected ballots drawn 
    % for a round-by-round audit defined by a round schedule n and a 
    % corresponding kmin schedule kmin, applied to an election defined 
    % by margin.
    % ONLY FOR SAMPLING WITH REPLACEMENT. 
    % Note that, if margin=0, it returns: 
    %       round-by-round risk schedule
    %       total risk
    %       number of expected ballots drawn (for this case, a sanity check)
    %
    %----------
    %
    % Input Values: 
    %   margin:         announced margin as a fraction for stopping probs;
    %                   zero for risk calculations
    %   n:              row vector of cumulative sample sizes (round schedule)
    %   kmin:           row vector of same size as n
    %
    %   n and kmin are typically outputs of R2BRAVOkmin using 
    %   alpha and margin when it is non-zero. The jth value of kmin 
    %   is the minimum number of votes for 
    %   winner required to terminate the audit round of size n(j). 
    %
    %----------
    %
    % Output Values
    %   RiskSched:          array of individual risk values. jth value is 
    %                           the risk (or stopping prob.) of drawing 
    %                           n(j) ballots, round-by-round.                      
    %   RiskValue:          the risk computed as the sum of all values of 
    %                           the risk sched.
    %
    %----------
    %
    % See also R2Risks for auditing without replacement. 
    %
    %----------

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

    %---------For jth audit round-----------   
    % For j=1 the risk is straightforward: 
    % risk = right tail of binomial distribution for a tied election. 
    % Similarly, stopping probability is the right tail of the distribution 
    % when the election is correct. 
    % Right tail is 1-left tail, and left tail is the cdf. 
    RiskSched(1) = 1-binocdf(kmin(1)-1, n(1), p);
    
    % We now need to compute the pdf for smaller values of winner votes in 
    % the current sample, so we can compute the pdf for winner votes after 
    % drawing the next set of votes. 
    %                   
    % CurrentTier: array of size kmin(j) to store the non-zero 
    %               probabilities for winner votes in the interval 
    %               [0, kmin(j)-1] going into the next draw. Note that 
    %               there is zero probability of winner votes being 
    %               kmin(j) or larger. 
    %               For j=1, hence, the CurrentTier is the binomial pdf 
    %               lopped off at kmin(1). 
    CurrentTier=binopdf(0:kmin(1)-1, n(1), p);
        
    % k: number of votes for the winner
    % Suppose the audit progresses to round j, j > 1. In order to compute 
    % the new pdf resulting from drawing more votes to get a total of n(j) 
    % votes, we use CurrentTier from the previous draw and the pdf for the 
    % probabilities of the entire sample drawn next to compute the new pdf. 
    % The risk is the right tail of this newly-computed pdf, which is 
    % lopped off and then becomes the (new) CurrentTier. 
    for j=2:NumberRounds
        ThisRoundSize = n(j)-n(j-1);
        PreviousTier=CurrentTier;
        clear CurrentTier;
        % Initialize the new CurrentTier for round j. 
        % The max number of winner votes in the collection: kmin(j-1)-1
        % cannot be incremented by more than ThisRoundSize. 
        % MATLAB indexes arrays beginning at 1. Thus CurrentTier(1,k)
        % corresponds to the probability of k-1 votes. 
        CurrentTier = zeros(1,kmin(j-1)-1+ThisRoundSize+1);

        % We now construct CurrentTier by the convolution of 
        % PreviousVotes with the distribution of the new draw. 
        CurrentTier = PreviousTier conv binopdf(0:ThisRoundSize,ThisRoundSize, p);
        
        RiskSched(j) = sum(CurrentTier(1,kmin(j)+1:size(CurrentTier,2)));
        CurrentTier=CurrentTier(1,1:kmin(j));
    end
    
    RiskValue = sum(RiskSched(1:NumberRounds));
    
end