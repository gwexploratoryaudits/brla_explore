 function [n_out, kmin, StopSched, RiskSched] = ...
     Athenakmin(margin, alpha, delta, n_in, audit_method)
    % Testing in progress
    % [n_out, kmin, StopSched, RiskSched] = Athenakmin(margin, alpha, delta, n_in, audit_method)
    % Athena kmin values for valid round sizes among given n_in. 
    % beta = 0; sampling with replacement. 
    % -----------
    % Input: 
    %   margin:         fractional margin
    %   alpha:          fractional risk limit
    %   delta:          LR stopping condition for Athena
    %   n_in:           row vector of cumulative round sizes, assumed to be
    %                       increasing
	%   audit_method:   string, one of: Athena, Minerva, Metis
    %                       Athena and Minerva have the same p_values for 
    %                       the same kmins, but their kmins are, in 
    %                       general, distinct for the same round sizes
    %                       because their stopping conditions are distinct.
    %                       delta is needed only for Athena. 
    %
    % THIS IS CURRENTLY ONLY FOR SAMPLING WITH REPLACEMENT. 
    %
    % ----------
    % Output: 
    %   n_out:          1-D array, beginning at first value of n_in for 
    %                           which the probability ratio is large 
    %                           enough. That is, n_out begins with the 
    %                           the first value of n_in that has a non-zero
    %                           probability of stopping the audit. 
    %	kmin:           1-D array of Athena kmin corresponding to n_out; 
    %                           size of n_out
    % -----------
    %
    % kmin[j] = smallest integer k such that stopping conditions are met
    %               for round j. 


    %-------------Preliminaries--------------
    % p is fractional vote for winner 
    p=(1+margin)/2;
    
    % NumberRounds is the size of n_in and max size of n_out and kmin
    NumberRounds = size(n_in,2);

    % Allocate risk/ stopping prob. scheds., kmin
    RiskSched = zeros(1,NumberRounds);
    StopSched = zeros(1,NumberRounds);
    kmin = zeros(1, NumberRounds);
    
    % Compute BRAVO kmins for alpha = delta 
    % Needed for Athena LR check
    if strcmp(audit_method,'Athena')
        [slope, intercept, ~, ~] = ...
            R2BRAVOkminWithSlope(margin, delta, n_in);
    end % end "if audit_method is Athena"
    
    % Initialize values to begin looking for first round where it is 
    % possible to satisfy stopping condition(s) (i.e. possible to stop 
    % audit). Some early round sizes might be too small for it to be at 
    % all possible to stop. 
    startat=0;  % a first round that one can stop at is not found yet
    jcurrent=1;	% current round in hunt for first round that could stop audit
    
    %-----Find first round with non-zero probability of stopping audit----%
    %
    % For round jcurrent the stop prob and risk are straightforward: 
    % right tails of the corresponding binomial distribution. 
    % They are the same for Athena, Minerva and Metis:
    % Right tail is 1-cdf. 
    %
    % Compute ratios of tails for all values of k, and find first ratio to 
    % cross 1/alpha. This is kmin(jcurrent) for Minerva and Metis. 
    % Athena requires one more check, LR >= 1/delta, which is 
    % represented by BRAVO kmins for risk limit = delta. Thus Athena kmin 
    % is the larger of the two kmins: Minerva with risk limit alpha and 
    % BRAVO with risk limit delta. 
    %
    % If stopping conditions are not satisfied for any value of k for 
    % the jcurrent round, try again with the next round size, 
    % n_in(jcurrent+1), and so on. Continue till you find a round size, 
    % n_in(jcurrent), for which the stopping condition(s) is (are) 
    % satisfied, or you run out of rounds. 
    %
    % Note the value of jcurrent in startat if you do find a k for which
    % the stopping condition is satisfied (as opposed to running out of 
    % rounds). Thus startat is zero if the stopping condition is currently 
    % not satisfied. 
    % 
    while startat == 0 && jcurrent <= NumberRounds
        % Find values of k that satisfy tail ratio condition
        Valid_k = find(alpha*(1-binocdf(0:n_in(jcurrent), n_in(jcurrent), p)) ...
            >= (1-binocdf(0:n_in(jcurrent), n_in(jcurrent), 0.5)));
        % kth value above corresponds to the cdf for k-1 winner votes and 
        % hence 1-cdf is the tail corresponding to winning votes >= k
        % Thus the smallest value of k that satisfies the above
        % condition, Valid_k(1), is a candidate for kmin. 
        % Check whether any values found
        if size(Valid_k,2) == 0 % None found
            jcurrent=jcurrent+1; % Go to next round size
        else % kmins found for Minerva and Metis but Athena requires LR check
            if strcmp(audit_method,'Athena')
                % Check LR
                km = max(Valid_k(1), ceil(slope*n_in(jcurrent) + intercept));
                if km > n_in(jcurrent) 
                    % This round not large enough for LR check
                    jcurrent = jcurrent+1; % Go to next round size
                else % Athena kmin found
                    % kmin should be larger than half round size
                    kmin(jcurrent) = max(km, ceil(n_in(jcurrent)/2)+1);
                    startat = jcurrent; % Note first round for audit
                end % end "if Athena kmin after LR check is too large"
            else % audit types other than Athena need not check LR
                % kmin should be larger than half round size
                kmin(jcurrent) = max(Valid_k(1), ceil(n_in(jcurrent)/2)+1);
                startat = jcurrent; % Note first round for audit
            end % end if statement checking Athena LR and assigning kmins to all audits
        end % end "if ratio test gives kmin < n"
    end % end while loop for figuring out if jcurrent is a good round
    
    % We are here because we ran out of rounds or because we found a 
    % round for which the ratio is large enough. 
    
    %-----------Compute kmins for next rounds, if any --------%
    if startat == 0 % didn't find a first round all returned arrays are empty
        n_out = []; kmin = []; StopSched = [];  RiskSched = []; 
    else % Found a first round where audit has non-zero prob of stopping
        % The stopping prob and risk for this round are the right tails:
        StopSched(1, startat) = 1-binocdf(kmin(startat)-1, n_in(startat), p);
        RiskSched(1, startat) = 1-binocdf(kmin(startat)-1, n_in(startat), 0.5);
        % Initialize cumulative probabilities. 
        CStopSched = StopSched; 
        CRiskSched = RiskSched;
        
        % If there is another round, we should compute the pdf of winner 
        % votes in this round as it would be just before going into the 
        % next round and just after the stopping conditions are tested. 
        if startat < NumberRounds
    
            % We now need to compute the pdf for the smaller values of 
            % winner votes left in the current sample, which we will need 
            % to compute the pdf for winner votes after drawing the next 
            % sample. 
            %
            % CurrentTier: array of size kmin(j) to store the non-zero 
            %               probabilities for winner votes in the interval 
            %               [0, kmin(j)-1] going into the next draw. Note 
            %               that the probability of winner votes being 
            %               kmin(j) or larger is zero. 
            %               For j=startat, the CurrentTier is the 
            %               binomial pdf lopped off at kmin(startat), 
            %               leaving behind at most kmin(startat)-1 votes 
            %               for the winner. 

            CurrentTierStop=binopdf(0:kmin(startat)-1, n_in(startat), p);
            CurrentTierRisk=binopdf(0:kmin(startat)-1, n_in(startat), 0.5);
            
            % Now ready to find kmin for next round
            for j=startat+1:NumberRounds
                %----Preparation for computing new pdf----%
                ThisRoundSize = n_in(j)-n_in(j-1); 
                
                % k: number of votes for the winner
                % Use CurrentTier from the previous draw and the pdf for 
                % the new sample to compute the new pdf (of the sum of: 
                % votes for the winner from the previous round and
                % from new ballots drawn). This is computed as the 
                % convolution of the two distributions, using the FFT. 
                % Rename old CurrentTier as PreviousTier
                % Pad PreviousTier in readiness for FFT
                % Padding before fft is necessary, see, for example, 
                % https://www.mathworks.com/help/signal/ug/linear-and-circular-convolution.html
                PreviousTierStop=[CurrentTierStop zeros(1,ThisRoundSize)];
                PreviousTierRisk=[CurrentTierRisk zeros(1,ThisRoundSize)];
                clear CurrentTierRisk;
                clear CurrentTierStop;
                
                % Padding ballot probability vector for the new draw 
                % (this pdf is the binomial of the size of the new draw)
                NewBallotsStop = [binopdf(0:ThisRoundSize,ThisRoundSize, p) ...
                    zeros(1,kmin(j-1)-1)];
                NewBallotsRisk = [binopdf(0:ThisRoundSize,ThisRoundSize, 0.5) ...
                    zeros(1,kmin(j-1)-1)];
                
                % ---------- Compute new pdf -----------% 
                % The new pdf, CurrentTier, is the convolution of 
                % PreviousTier and the pdf of the binomial draw, 
                % NewBallots. Convolution is computed using the FFT. 
                CurrentTierStop=ifft(fft(PreviousTierStop).*fft(NewBallotsStop));
                CurrentTierRisk=ifft(fft(PreviousTierRisk).*fft(NewBallotsRisk));
                
                % --------- Allocate arrays for tails -----------%
                TailStop = zeros(1, size(CurrentTierStop-1, 2));
                TailRisk = zeros(1, size(CurrentTierRisk-1, 2));
                
                % ----------Compute tails --------%
                % MATLAB indexes arrays beginning at 1. Thus 
                % CurrentTier(k+1) corresponds to the probability of 
                % k votes. 
                for k=1:size(TailStop,2)
                    TailStop(k) = sum(CurrentTierStop(k+1:size(CurrentTierStop,2)));
                    TailRisk(k) = sum(CurrentTierRisk(k+1:size(CurrentTierRisk,2)));
                end

                % ----------- kmins through computation of p values -----%
                
                if strcmp(audit_method,'Athena') || strcmp(audit_method,'Minerva') 
                   % Athena/Minerva p-values are identical for a given 
                    % distribution and value of k: the ratio of the right 
                    % tails of the stopping probability and risk 
                    % distributions. 
                    Valid_k = find(alpha*(TailStop) >= (TailRisk));
                    % The kth value of the test above tests the ratio of 
                    % the right tails for kmin = k
                    if strcmp(audit_method,'Minerva') % No need to test LR
                        % kmin(j) must be larger than ceil(n_in(j)/2)
                        kmin(j) = max(Valid_k(1), ceil(n_in(j)/2)+1);
                    else % Need to also test LR for Athena stopping condition
                        km = max(Valid_k(1), ceil(slope*n_in(j) + intercept));
                        kmin(j) = max(km, ceil(n_in(j)/2)+1); 
                    end
                 else % this is Metis
                    % Test only Metis p-value, no LR test for Metis
                    % Metis test compares the sums of right tails, 
                    % including right tails from previous rounds
                    Valid_k = find(alpha*(CStopSched(j-1)+ TailStop) ...
                        >= (CRiskSched(j-1) + TailRisk));
                    % kmin(j) must be larger than ceil(n_in(j)/2)
                    kmin(j) = max(Valid_k(1), ceil(n_in(j)/2)+1);
                end
                
                % Risk for this round:
                StopSched(j) = TailStop(kmin(j));
                RiskSched(j) = TailRisk(kmin(j));
                CStopSched(j) = StopSched(j) + CStopSched(j-1);
                CRiskSched(j) = RiskSched(j) + CRiskSched(j-1);
                
                % Lop off at kmin: 
                CurrentTierStop = CurrentTierStop(1,1:kmin(j));
                CurrentTierRisk = CurrentTierRisk(1,1:kmin(j));
            end
        else
            % Assign values to return if only a single round 
        end
        n_out = n_in(startat:NumberRounds);
        kmin = kmin(startat:NumberRounds);
        StopSched = StopSched(1, startat:NumberRounds);
        RiskSched = RiskSched(1, startat:NumberRounds);
    end
end

    