 function [n_out, kmin] = Athenakmin(margin, alpha, n_in)
    % IN PROGRESS
    % [n_out, kmin] = Athenakmin(margin, alpha, n_in)
    % Athena kmin values for valid values in given n_in. 
    % beta assumed zero. sampling assumed with replacement. 
    % -----------
    % Input: 
    %   margin:         fractional margin
    %   alpha:          fractional risk limit
    %   n_in:           row vector of cumulative round sizes, assumed to be
    %                       increasing
    % ----------
    % Output: 
    %   n_out:          1-D array, beginning at first value of n_in for 
    %                           which the probability ratio is large 
    %                           enough. That is, the first value of sample
    %                           size with a non-zero probability of making
    %                           a decision. 
    %	kmin:           1-D array of Athena kmin corresponding to n_out; 
    %                           size of n_out
    % -----------
    %
    % kmin[i] = smallest integer k such that 
    % pdf tail for declared election margins | previous kmins 
    %           <= alpha * pdf tail for tie | previous kmins

    %-------------Preliminaries--------------
    % p is fractional vote for winner 
    p=(1+margin)/2;
    
    % NumberRounds is the size of n_in and max size of n_out and kmin
    NumberRounds = size(n_in,2);

    % Initialize risk and stopping prob. scheds.
    RiskSched = zeros(1,NumberRounds);
    StopSched = zeros(1,NumberRounds);

    %---------For jth audit round-----------
    %
    % For j=1 the stop prob./risk is straightforward: 
    % right tail of the corresponding binomial distribution. 

    % Right tail is 1-left tail, and left tail is the cdf. 
    RiskSched(1) = 1-binocdf([0:n_in(1)], n_in(1), p);
    StopSched(1) = 1-binocdf([0:n_in(1)], n_in(1), 0.5);
    
    
    
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
        % all these contributions. 
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
                    % at least k-ThisRoundSize; it also needs to be non-
                    % negative. 
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
                    % passed to hygepdf make sense. In any case, hygepdf 
                    % will return zeroes if not. 
                    CurrentTier(1,k+1) = CurrentTier(1,k+1) + PreviousTier(1,PreviousVotes+1)*hygepdf(k-PreviousVotes,N-n(j-1),WinnerVotes-PreviousVotes,ThisRoundSize);
                end
            end
        end
        RiskSched(j) = sum(CurrentTier(1,kmin(j)+1:size(CurrentTier,2)));
        CurrentTier=CurrentTier(1,1:kmin(j));
    end
    RiskValue = sum(RiskSched(1:NumberRounds));
    ExpectedBallots = dot(RiskSched,n) + ((1-RiskValue)*N);
end
    
    % first value of sample size >= kmin; solve n >= kmslope*n + kmintercept
    firstvalue = ceil(kmintercept/(1-kmslope));
    
    % values of n_in that are not smaller than first value, return 1, 
    % others return 0
    valid_values = n_in >= firstvalue;
    
    % Value and first position of the maximum, in this case a "1"
    [a, b] = max(valid_values);
    
    if a == 0
        % None of the proposed sample sizes in n_in is a valid one
        n_out = [];
    else
        n_out = n_in(b:size(n_in,2));
    end
    
    % kmin computed using slope, intercept and n.
    kmin=ceil(kmslope*n_out + kmintercept);
 end