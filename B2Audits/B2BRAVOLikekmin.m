function [n, kmin, LLR] = B2BRAVOLikekmin(margin, alpha, N)
    % 
    % [n, kmin, LLR] = B2BRAVOLikekmin(margin, alpha, N)
    % Generates kmin for a B2 (ballot-by-ballot) BRAVO-like (BRAVO 
    % without replacement) audit
    %
    %----------
    %
    % Input: 
    %   margin:         fractional margin
    %   alpha:          fractional risk limit
    %   N:              votes cast for two candidates
    %
    %----------
    %
    % Output:
    %   n:              1-D array of sample sizes, beginning with the first 
    %                       sample size where it is possible to stop the 
    %                       audit. That is, n(1) is the smallest value of 
    %                       n such that n(j) >= kmin(j).
    %   kmin:           1-D array of minimum values of winner votes k 
    %                       required to stop the audit; the size of this 
    %                       array is the size of the array n. kmin(j) is the 
    %                       minimum number of votes for the winner required 
    %                       to terminate an audit with sample size n(j). We 
    %                       do not allow kmin(j) to exceed the minimum 
    %                       number of ballots required to win the election. 
    %   LLR:            1-D array of values of the log-likelihood ratio, a
    %                       sanity check. 
    %
    %----------
    %
    
    % Computed values.
    % HalfN:            Maximum votes for the announced winner if the 
    %                       election outcome is incorrect. That is, half 
    %                       the total votes if N is even, and a losing 
    %                       margin of one if N is odd.
    % LogAlpha:         Log of the risk limit; is used repeatedly
    % p:                Fractional vote count for the winner
    % WinnerTally:      Number of votes obtained by the winner

    HalfN = floor(N/2);
    LogAlpha = log(alpha);
    p = (1+margin)/2;
    WinnerTally = floor(p*N);
    LoserTally = N-WinnerTally;

    % 
    % We compute the LLR and compare it to -LogAlpha
    % k: array of number of votes for the winner in the samples
    % j: array of sample sizes
    % LLR: array of actual LLR for the kmin (a sanity check, 
    %           differs from -LogAlpha because kmin is an integer, 
    %           but the LLR should not be smaller than -LogAlpha). 

    % For sample j, for each possible value of k beginning at the 
    % previous kmin, kmin(j-1), denoted kminprev here to accommodate j=1, 
    % we determine the LLR. We stop when it is not smaller than -LogAlpha. 
    % This gives us kmin(j).

    %----------Initialization----------%
    kminprev = zeros(1,N+1); % kmin for draws 0 through N. 
    kmin = zeros(1,N);
    LLR = zeros(1,N);
    kminprev(1,1)=1; % kmin for draw 0. 

    % We use startat to remember the first value of j when the LLR
    % exceeds -LogAlpha for a value of k <= j
    startat = 0;
    
    % We use endat to remember the first value of kmin that is HalfN + 1, 
    % which is a winning tally. 
    endat=0;

    for j=1:N
        for k=kminprev(1,j):j
            if j-k > LoserTally
                % Value of k is small enough that the number of votes left 
                % over in the sample of size j is larger than the total 
                % tally for the loser. Hence the probability in the 
                % likelihood ratio numerator is zero and the LLR is
                % negative infinity. We zero it so that it is small 
                % enough to never be larger than -LogAlpha, which will 
                % always be positive (Alpha always strictly smaller than 
                % one). We move on to the next value of k, till its value
                % is large enough. 
                ThisLLR=0; 
            elseif k > HalfN
                % The winner has won because we have sampled a sufficient
                % number of votes for the winner. For this and all larger 
                % sample sizes, kmin=HalfN+1.
                kmin(1,j:N)=HalfN+1;
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
                ThisLLR = BravoLikeLLR(k,WinnerTally,j,N);
            end
            %if LikelihoodRatio > OneOverAlpha
            if ThisLLR > -LogAlpha
                % We have achieved the required minimum value of the LLR
                % in the SPRT. 
                break
            end
        end
        if endat > 0
            % We have reached the value of kmin corresponding to winning
            % the election, and do not wish to further compute kmin. 
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
                % we reached the required LLR value and the sample size 
                % was large enough. 
                startat = j;
            end
        end
    end

    % We now define the vector n of sample sizes so that the 
    % first entry is the first instance when ratio is large enough. 
    n = (startat:N);
    kmin = kmin(1,startat:N);
    LLR = LLR(1,startat:N);
end
