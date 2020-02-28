function ratio = BravoLikeLR(k,winnervotes,n,N)
    %
    % ratio = BravoLikeLR(k,n,N)
    % This function generates the likelihood ratio for a BRAVOLike
    % audit without using the hypergeometric function.
    % We don't use it because it does not work well for a large
    % election. Use the log likelihood ration from BravoLikeLLR instead. 
    %------------
    %Input: 
    %   k:              number of votes for winner
    %   n:              number of samples
    %   N:              total number of votes
    %----------
    % Output:
    % ratio:            likelihood ratio

    % The formula is: 
    % product_{i=0}^{k-1} (winnervotes-i)/(winnerhalf-i) 
    % times
    % product_{i=0}^{n-k-1} (N-winnervotes-i)/(loserhalf-i) 
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
    ratio = 1;
    
    for i=0:k-1
        ratio = ratio*((winnervotes-i)/(winnerhalf-i));
    end
    for i=0:n-k-1
        ratio = ratio*((loservotes-i)/(loserhalf-i));
    end
end


