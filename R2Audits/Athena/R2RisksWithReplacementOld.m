function RiskSched = R2RisksWithReplacement(margin, n, kmin)
    %
    % RiskSched = R2RisksWithReplacement(margin, n, kmin)
    % This function returns round-by-round stopping probability 
    % for a round-by-round audit defined by a round schedule n and a 
    % corresponding kmin schedule kmin, applied to an election defined 
    % by margin.
    % Note that, if margin=0, it returns round-by-round risk schedule
    % ONLY FOR AUDITING WITH REPLACEMENT
    % USES FOURIER TRANSFORM
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

    %---------For jth audit round-----------   
    % For j=1 the risk is straightforward: 
    % risk = right tail of binomial distribution (with replacement) for a
    % tied election. 
    % Similarly, stopping probability is the right tail of the distribution 
    % when the election is correct. 
    % Right tail is 1-cdf. 
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
        % Pad PreviousTier to make it the length of the new expected 
        % Current Tier. 
        % The max number of winner votes in the collection: kmin(j-1)-1
        % cannot be incremented by more than ThisRoundSize. 
        % MATLAB indexes arrays beginning at 1. Thus CurrentTier(1,k)
        % corresponds to the probability of k-1 votes. 
        PreviousTier=[CurrentTier zeros(1,ThisRoundSize)];
        clear CurrentTier;
        
        % We now construct the new CurrentTier as the convolution of 
        % PreviousTier and the binomial function using the fft. Padding 
        % before fft is necessary, see, for example, 
        % https://www.mathworks.com/help/signal/ug/linear-and-circular-convolution.html
        % Padding ballot probability vector for the new draw
        NewBallots = [binopdf(0:ThisRoundSize,ThisRoundSize, p) zeros(1,kmin(j-1)-1)];
        
        % CurrentTier is convolution of the two
        CurrentTier=ifft(fft(PreviousTier).*fft(NewBallots));
        
        % Risk for this round: 
        RiskSched(j) = sum(CurrentTier(kmin(j)+1:kmin(j-1)+ThisRoundSize));
        
        % Lop off at kmin: 
        CurrentTier = CurrentTier(1,1:kmin(j));
    end
end