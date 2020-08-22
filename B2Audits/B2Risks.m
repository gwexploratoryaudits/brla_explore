function [RiskSched, RiskValue, ExpectedBallots, CurrentTier] = B2Risks(margin, N, n, kmin, audit_type)
    %
    % [RiskSched, RiskValue, ExpectedBallots] = B2Risks(margin, N, n, kmin, audit_type)
    % This function returns:
    %       ballot-by-ballot stopping probability 
    %       total stopping probability 
    %       number of expected ballots drawn
    % for a ballot-by-ballot audit defined by an array of kmin values, 
    % applied to an election defined by margin.
    % Note that, if margin=0, it returns: 
    %       ballot-by-ballot risk schedule
    %       total risk
    %       number of expected ballots drawn (for this case, a sanity check)
    %
    %----------
    %
    % Input Values: 
    %   margin:             announced margin as a fraction for stopping 
    %                           probs; zero for risk calculations.
    %   N:                  votes cast for two candidates; used to 
    %                           compute pdfs when sampling is without 
    %                           replacement. Not used at all for sampling
    %                           with replacement. 
    %   n:                  row vector of sample sizes.
    %   kmin:               row vector of same size as n. 
    %   audit_type:         0 for with, or 1 for without, replacement.
    %
    %   n and kmin could be outputs of B2BravoLikekmin or B2BRAVOkmin 
    %   using a non-zero margin, alpha (and N). The jth value of kmin 
    %   is the minimum number of announced-winner votes required to 
    %   terminate the audit round of size n(j). 
    %
    %   If using your own values of kmin and n: n begins with a positive 
    %   integer which is then incremented by one; kmin is a non-decreasing 
    %   array (row vector) of integers. 
    %
    %   This code implements an approach described in the long Athena
    %   paper, https://arxiv.org/abs/2008.02315
    %
    %----------
    %
    % Output Values
    %   RiskSched:          array of individual risk values. jth value is 
    %                           the risk (or stopping prob.) of drawing 
    %                           n(j) ballots, ballot-by-ballot.                      
    %   RiskValue:          the risk computed as the sum of all values of 
    %                           the risk sched.
    %   ExpectedBallots:	expected number of ballots examined
    %                           should be larger than (1-risk-limit)*N 
    %                           for zero margin.
    %
    %----------
    %

    % The right tail of the pdf, beginning at kmin, is the risk of the 
    % round, when the pdf represents the underlying vote distribution. 
    % The worst case risk corresponds to a tied election (for even N) or 
    % one where the winner lost by a single vote (for odd N), see the
    % Bayesian RLA paper. 

    % p: fractional vote count for winner
    p = (1+margin)/2;
    % NumberDraws is the size of n and kmin
    NumberDraws = size(n,2);

    % Initialize risk schedule (or stopping prob. sched when margin is not 
    % zero). 
    RiskSched = zeros(1,NumberDraws);
    RiskValue = 0;

    %---------For jth audit round-----------   
    % For j=1 the risk is straightforward: 
    % risk = right tail of the hypergeometric pmf (without replacement) for
    % a tied election.
    % risk = right tail of binomial distribution (with replacement) for a
    % tied election. 
    % Similarly, stopping probability is the right tail of the distribution 
    % when the election is as announced. 
    % Right tail is 1-left tail, and left tail is the cdf. 
    % Because functions are discrete, left tail ends at kmin-1. 
    
    % For first sample size where the probability of stopping is non-zero, 
    % n(1):
    if audit_type==0 % with replacement
        RiskSched(1) = 1-binocdf(kmin(1)-1, n(1), p);
    else
        % WinnerVotes: number of votes won by the winner
        WinnerVotes = floor(p*N);
        RiskSched(1) = 1-hygecdf(kmin(1)-1, N, WinnerVotes, n(1));
    end
    
    % We now compute the pdf of announced-winner votes in the current 
    % sample after the decision to stop (or not). 
    %                   
    % CurrentTier: array of size kmin(j) to store the non-zero 
    %               probabilities for announced-winner votes in the 
    %               interval [0, kmin(j)-1], going into the next draw. 
    %               Note that there is zero probability of winner votes 
    %               being kmin(j) or larger. 
    %               For j=1, hence, the CurrentTier is the hypergeometric 
    %               pdf (without replacement) or the binomial pdf (with
    %               replacement) with zeroes for values kmin(1) and larger. 

    if audit_type==0
        CurrentTier{1}=binopdf(0:kmin(1)-1, n(1), p);
    else
        CurrentTier{1}=hygepdf(0:kmin(1)-1, N, WinnerVotes, n(1));
    end
    
    % k: number of votes for the winner
    % If the audit progresses to the jth draw, j > 1, to compute the new 
    % pdf after drawing a total of n(j) votes, we use CurrentTier from the  
    % previous draw and a simple expression for the probabilities of the 
    % single ballot drawn next. The risk is the right tail of this 
    % newly-computed pdf, which is zeroed for kmin(j) and above and then 
    % becomes the (new) CurrentTier. 
    
    for j=2:NumberDraws
        PreviousTier=CurrentTier{j-1};
        % clear CurrentTier;
        % We now construct Current tier from the first possible element up. 
        % k=0 is possible only if the jth draw is for the loser, and all 
        % previous ones were too. 
        % PreviousTier(1,1) is the probability of zero votes for the winner 
        % before this draw. 
        % In this case: 
        if audit_type == 0
            % with replacement: prob of draw for loser is 1-p
            % matlab begins indexing at 1, so CurrentTier(1,k+1) is the 
            % pdf for k announced-winner ballots. 
            % k=0
            CurrentTier{j}(1,1)=PreviousTier(1,1)*(1-p);
        else
            % without replacement: 
            % Total number of ballots to draw from is N-n(j-1). 
            % Total number of ballots for loser still in the election is:
            %       original number, N-WinnerVotes
            %       less those drawn, n(j-1), which were all for the loser.
            %       
            CurrentTier{j}(1,1)=PreviousTier(1,1)*max(((N-WinnerVotes)-n(j-1))/(N-n(j-1)),0);
        end
        % Now for other elements of CurrentTier, which obtain contributions
        % for both possible ballot draws: for winner and for loser. 
        for k=1:kmin(j-1)-1 % k = number of announced-winner ballots
            if audit_type == 0
               CurrentTier{j}(1,k+1)=PreviousTier(1,k+1)*(1-p) + ...
                   PreviousTier(1,k)*p; 
            else
                CurrentTier{j}(1,k+1)=PreviousTier(1,k+1)*max(((N-WinnerVotes)-(n(j-1)-k))/(N-n(j-1)),0) + ...
                    PreviousTier(1,k)*max((WinnerVotes-(k-1))/(N-n(j-1)),0);
            end
        end
        
        % Finally adding one to the length of PreviousTier
        % to obtain k = kmin(j-1), which is only possible if the jth draw 
        % is a ballot for the announced winner. 
        if audit_type == 0
            CurrentTier{j}(1,kmin(j-1)+1)= PreviousTier(1,kmin(j-1))*p;
        else
            CurrentTier{j}(1,kmin(j-1)+1)= PreviousTier(1,kmin(j-1))*max((WinnerVotes-(kmin(j-1)-1))/(N-n(j-1)),0);
        end
        
        % kmin for this round might be larger than kmin(j-1)
        if kmin(j) > kmin(j-1)
            CurrentTier{j}(1, kmin(j-1)+2:kmin(j)+1)=0;
        end
        
        % kmin increases by at most 1, hence RiskSched value is one value
        RiskSched(j) = CurrentTier{j}(1,kmin(j)+1);
        CurrentTier{j}=CurrentTier{j}(1,1:kmin(j));
    end
    RiskValue = sum(RiskSched(1:NumberDraws));
    ExpectedBallots = dot(RiskSched,n) + (1-RiskValue)*n(1,NumberDraws);
end