function [n_out, kmin, LLR] = RSquareBRAVOLikekmin(margin, alpha, N, n_in)
    % 
    % [n_out, kmin, LLR] = RSquareBRAVOLikekmin(margin, alpha, N, n_in)
    % Generates kmin for a R-square (ballot-by-ballot) BRAVO-like (BRAVO 
    % without replacement) audit with given round schedule. 
    %----------
    % Input: 
    %   margin:         fractional margin
    %   alpha:          fractional risk limit
    %   N:              votes cast for two candidates
    %   n_in:           (cumulative) round schedule
    %----------
    % Output:
    %   n_out:          1-D array of sample sizes, subset of given n_in, 
    %                       beginning with the first sample size where 
    %                       it is possible to stop the audit: 
    %                       n_out(j)>=kmin(j).
    %   kmin:           1-D array of minimum values of k; jth value is the 
    %                       minimum number of votes for winner required to 
    %                       terminate an audit with sample size n(j). 
    %   LLR:            array of values of the log-likelihood ratio (LLR), 
    %                       sanity check. 

    % HalfN is maximum votes for announced winner if the election outcome 
    % is incorrect. That is, half the total votes if N is even, and a 
    % losing margin of one if N is odd.
    HalfN = floor(N/2);
    
    LogAlpha = log(alpha); % log of the risk limit;
    
    p = (1+margin)/2; % fractional vote count for winner
    
    WinnerTally = ceil(p*N); % number of votes obtained by winner
    
    LoserTally = N-WinnerTally; % number of votes obtained by loser

    %--------------------
    % We compute the LLR and compare it to -LogAlpha
    % k: array of number of votes for winner in samples
    % j: array of sample sizes
    % LLR: array of actual LLR for the kmin (sanity check, 
    %           differs from prescribed values because kmin is integer, but  
    %           LLR should not be smaller than -LogAlpha). 

    % For sample j, for each possible value of k beginning at 
    % kmin(j-1), denoted kminprev here to accommodate j=1, we determine 
    % the LLR. We stop when it is not smaller than -LogAlpha. 
    % This gives us kmin(j).

    %----------Initialization----------%
    
    num_rounds = size(n_in,2); % number of rounds, size of n_in
    kminprev = zeros(1,num_rounds+1); % includes a first kmin value
    kmin = zeros(1,num_rounds);
    LLR = zeros(1,num_rounds);
    kminprev(1,1)=1;

    % We use startat to remember the first value of j when the LLR
    % exceeds -LogAlpha for a value of k <= j
    startat = 0;
    
    % We use endat to remember the first value of kmin that is HalfN + 1, 
    % which is a winning tally. Once kmin hits HalfN+1, it need not 
    % increase. 
    endat=0;

    for j=1:num_rounds
        for k=kminprev(1,j):n_in(1,j)
            if n_in(1,j)-k > LoserTally
                % Value of k is small enough that the number of votes for 
                % the loser is too large for this margin and hence the 
                % probability in the likelihood ratio numerator is zero 
                % and hence the LLR is negative infinity. But as the LLR is
                % zero, it is small enough to not be larger than 
                % -LogAlpha, which will always be positive as LogAlpha 
                % is negative because alpha always strictly smaller than 
                % one. We move on to the next value of k, till the LR is
                % large enough. 
                ThisLLR=0; 
            elseif k > HalfN
                % The winner has won because we have sampled a sufficient
                % number of votes for the winner. For this and all larger 
                % sample sizes, kmin=HalfN+1. We need not see any more 
                % values of k, so we break. We need not see any more 
                % values of j either, so we note that we have ended at j. 
                kmin(1,j:num_rounds)=HalfN+1;
                endat=j;
                break
            else
                % The value of k is both small enough and large enough 
                % that no term in the numerator or denominator of the LLR
                % is zero, so we can take logs of all terms. Because we 
                % ensure that the number of votes for the winner in the 
                % sample is smaller than HalfN + 1, it is also smaller 
                % than WinnerTally. Because we ensure that the number of 
                % votes for the loser in the sample is smaller than 
                % LoserTally, it is also smaller than HalfN. 
                ThisLLR = LogLikelihoodRatio(k,WinnerTally,n_in(j),N);
            end
            %if LikelihoodRatio > OneOverAlpha
            if ThisLLR > -LogAlpha
                % We have achieved the required minimum value of the LLR
                % in the Waldian sequential ratio test and need not see 
                % any more values of k for this value of j. 
                break
            end
        end
        if endat > 0
            % We have reached the value of kmin corresponding to winning
            % the election, and do not wish to further examine larger 
            % rounds (larger values of j). 
            break
        else
            % We have either achieved the minimum required value of the 
            % LLR or have exhausted all of the sample without reaching 
            % it (sample size too small). In any case we record the last
            % computed value of k for this sample size. 
            kmin(1,j) = k;
            kminprev(1,j+1)=k;
            LLR(1,j) = ThisLLR;
            if ThisLLR > -LogAlpha && startat == 0
                % If we did achieve the required LLR value but the value 
                % of startat does not reflect that, this is the first time 
                % we reached the value and the sample size was large enough. 
                startat = j;
            end
        end
    end

    % We now define the vector n_out of sample sizes so that the 
    % first entry is the first instance when ratio is large enough. 
    n_out = n_in([startat:num_rounds]);
    kmin = kmin([startat:num_rounds]);
    LLR = LLR([startat:num_rounds]);
end
