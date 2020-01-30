function LogRatio = LogLikelihoodRatio(k,winnervotes,n,N)
    %
    % LogRatio = LogLikelihoodRatio(k,n,N)
    % This function generates the log-likelihood ratio for a BRAVOLike
    % audit without using the hypergeometric function. 
    % Error checking to avoid log(0) should be done outside this function. 
    %------------
    %Input: 
    %   k:              number of votes for winner
    %   n:              number of samples
    %   N:              total number of votes
    %----------
    % Output:
    % LogRatio:         log-likelihood ratio

    % The formula is: 
    % sum_{i=0}^{k-1} [log(winnervotes-i)-log(winnerhalf-i)] 
    % +
    % sum_{i=}^{n-k-1} [log(N-winnervotes-i)-log(loserhalf-i)] 
    % where winnerhalf is N/2 or (N-1)/2 and loserhalf is N/2 or (N+1)/2
    % when N is even or odd respectively.
    
    % winnerhalf is the largest number of votes the winner can obtain if
    % the election outcome is incorrect.
    winnerhalf = floor(N/2);
    
    % loserhalf is the smallest number of votes the loser can obtain if 
    % the election outcome is incorrect.
    loserhalf = N-winnerhalf; 
    
    % loservotes is the number of votes for the loser in the election
    loservotes = N-winnervotes;
    
    %Initialize
    LogRatio = 0;
    for i=0:k-1
        LogRatio = LogRatio+log(winnervotes-i)-log(winnerhalf-i);
    end
    for i=0:n-k-1
        LogRatio = LogRatio+ log(loservotes-i)-log(loserhalf-i);
    end
end


