function [kmin, ActualRiskSched, ActualRiskValue, ExpectedBallots] = RSquareInvRisks(margin, N, n, RiskSched, audit_type)
    %
    % [kmin, ActualRiskSched, ActualRiskValue, ExpectedBallots] = RSquareInvRisks(margin, N, n, RiskSched, audit_type)
    % This function returns:
    %       kmin values    
    % for a round-by-round audit defined by a round schedule n and a 
    % corresponding risk schedule RiskSched, applied to an election defined 
    % by margin and total size N.    
    %----------
    % Input Values: 
    %   margin:         announced margin as a fraction for stopping probs;
    %                   zero for risk calculations
    %   N:              votes cast for two candidates; 
    %   n:              row vector of cumulative sample sizes (round schedule)
    %                       last round size no larger than N for audits 
    %                       without replacement
    %   RiskSched:           row vector of same size as n 
    %   audit_type:     0 for with, or 1 for without, replacement
    %
    %   n is typically the output of RSquareBravoLikekmin or 
    %   RSquareBRAVOkmin using margin, alpha (and N) when margin is not 
    %   zero. One way to obtain RiskSched is to add B-square risk for the 
    %   rounds in n. B-Square risk may be the output of BSquareRisks. 
    %----------
    % Output Values
    %   kmin:               array of kmins corresponding to n
    %	ActualRiskSched:	array of individual risk values corresponding 
    %                           to kmin.                      
    %   ActualRiskValue:	the actual risk computed as the sum of all 
    %                           values of the actual risk sched.
    %   ExpectedBallots:	expected number of ballots examined
    %                           should be larger than (1-risk-limit)*N 
    %                           for zero margin.
    %----------

    % The right tail of the pdf at a round is the risk of the round, when
    % the pdf represents the underlying vote distribution. 
    % The worst case risk corresponds to a tied election (for even N) or 
    % one where the winner lost by a single vote (for odd N), see Bayesian 
    % RLA paper. 

    % p: fractional vote count for winner
    p = (1+margin)/2;
    % WinnerVotes: number of votes won by the winner
    WinnerVotes = floor(p*N);
    % NumberRounds is the size of n, RiskSched and kmin
    NumberRounds = size(n,2);

    % Initialize actual risk schedule (or stopping prob. sched when 
    % margin is not zero). 
    ActualRiskSched = zeros(1,NumberRounds);
    kmin = zeros(1, NumberRounds);

    %---------For jth audit round-----------   
    % For j=1 the risk is straightforward: 
    % risk = right tail of the hypergeometric pmf (without replacement) for
    % a tied election.
    % risk = right tail of binomial distribution (with replacement) for a
    % tied election. 
    % Similarly, stopping probability is the right tail of the distribution 
    % when the election is correct. 
    % Right tail is 1-left tail, and left tail is the cdf. 
    if audit_type==0
        kmin(1) = binoinv(1-RiskSched(1), n(1), p)+1;
    else
        kmin(1) = hygeinv(1-RiskSched(1), N, WinnerVotes, n(1))+1;
    end
    
    % Now compute the actual risk schedule and update the desired RiskSched
    % with the difference. 
    if audit_type==0
        ActualRiskSched(1,1) = 1-binocdf(kmin(1)-1, n(1), p);
    else
        ActualRiskSched(1,1) = 1-hygecdf(kmin(1)-1, N, WinnerVotes, n(1));
    end
    
    %Update
    RiskSched(2) = RiskSched(2) + RiskSched(1)-ActualRiskSched(1,1);
    % We now need to compute the pdf for smaller values of winner votes in 
    % the current sample, so we can compute the pdf for winner votes after 
    % drawing the next set of votes. 
    %                   
    % CurrentTier: array of size kmin(j) to store the non-zero 
    %               probabilities for winner votes in the interval 
    %               [0, kmin(j)-1] going into the next draw. Note that 
    %               there is zero probability of winner votes being 
    %               kmin(j) or larger. 
    %               For j=1, hence, the CurrentTier is the hypergeometric 
    %               pdf (without replacement) or the binomial pdf (with
    %               replacement) lopped off at kmin(1). 

    if audit_type==0
        CurrentTier=binopdf(0:kmin(1)-1, n(1), p);
    else
        CurrentTier=hygepdf(0:kmin(1)-1, N, WinnerVotes, n(1));
    end
    
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
        if audit_type==0
            % With replacement
            CurrentTier = zeros(1,kmin(j-1)-1+ThisRoundSize+1);
        else
            % Without replacement, k also cannot exceed the total number of 
            % votes we assume for the winner in the election. 
            CurrentTier = zeros(1,min(kmin(j-1)-1+ThisRoundSize,WinnerVotes)+1);
        end
        % We now construct CurrentTier for all values of k by assuming a
        % value of PreviousVotes for the winner and computing the prob. 
        % of the number that need to be drawn in the new sample. We add 
        % all these contributions and stop when we hit RiskSched(j). 
        if audit_type==0
            % With replacement. 
            for k=0:kmin(j-1)-1+ThisRoundSize
                CurrentTier(1,k+1)=0;
                for PreviousVotes=max(0,k-ThisRoundSize):min(kmin(j-1)-1,k)
                    % For each possible value of PreviousVotes, find the
                    % number needed in the new draw that would add up to k. 
                    % PreviousVotes will be no larger than kmin(j-1)-1. 
                    % Also, we will not need more PreviousVotes than k. 
                    % On the other hand, we can draw at most ThisRoundSize
                    % votes for the winner, so PreviousVotes needs to be 
                    % at least k-ThisRoundSize. 
                    % 
                    % Number of votes needed for winner to make k votes 
                    % in all is k-PreviousVotes
                    % Number of votes drawn is ThisRoundSize
                    % Our limits in this for loop ensure that we pass 
                    % valid values to binopdf. In particular, that 
                    % k - PreviousVotes <= ThisRoundSize, and 
                    % k-PreviousVotes >= 0
                    % binopdf itself returns zeroes for values that are 
                    % negative or with a larger number of "good" values 
                    % than sample size. 
                    CurrentTier(1,k+1) = CurrentTier(1,k+1) + PreviousTier(1,PreviousVotes+1)*binopdf(k-PreviousVotes,ThisRoundSize, p);
                end
            end
        else
            % Without replacement
            for k=0:min(kmin(j-1)-1+ThisRoundSize,WinnerVotes)
            CurrentTier(1,k+1)=0;
                for PreviousVotes=max([0,k-ThisRoundSize, n(j-1)-(N-WinnerVotes)]):min(kmin(j-1)-1,k)
                    % PreviousVotes cannot be so small that it is not as
                    % large as the previous number of sample ballots drawn 
                    % less all the loser's ballots in the entire election.
                    % 
                    % Total number of ballots to draw from is N-n(j-1). 
                    % Total number of ballots for winner still in the 
                    % election is WinnerVotes-PreviousVotes.
                    % Our limits for this for loop should ensure values
                    % passed to hygepdf make sense. In nay case, hygepdf 
                    % will return zeroes if not. 
                    CurrentTier(1,k+1) = CurrentTier(1,k+1) + PreviousTier(1,PreviousVotes+1)*hygepdf(k-PreviousVotes,N-n(j-1),WinnerVotes-PreviousVotes,ThisRoundSize);
                end
            end
        end
        i=kmin(j-1)+1;
        CurrentRisk = sum(CurrentTier(1,i+1:size(CurrentTier,2)));
        while CurrentRisk > RiskSched(j)
            CurrentRisk = CurrentRisk - CurrentTier(1,i+1);
            i=i+1;
        end
        kmin(j) = i;
        ActualRiskSched(j) = sum(CurrentTier(1,kmin(j)+1:size(CurrentTier,2)));
        CurrentTier=CurrentTier(1,1:kmin(j));
        if j <= NumberRounds-1
            % Rollover excess unspent risk
            RiskSched(j+1) = RiskSched(j+1) + RiskSched(j)-ActualRiskSched(1,j);
        end
    end
    ActualRiskValue = sum(ActualRiskSched(1:NumberRounds));
    ExpectedBallots = dot(ActualRiskSched,n) + (1-ActualRiskValue)*N;
end