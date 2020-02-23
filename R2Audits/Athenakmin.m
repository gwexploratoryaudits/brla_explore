 function [n_out, kmin] = Athenakmin(margin, alpha, delta, n_in, audit_method)
    % IN PROGRESS
    % [n_out, kmin] = Athenakmin(margin, alpha, n_in)
    % Athena kmin values for valid values in given n_in. 
    % beta assumed zero. sampling assumed with replacement. 
    % -----------
    % Input: 
    %   margin:         fractional margin
    %   alpha:          fractional risk limit
    %   delta:          stopping condition for Athena
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
    %                           enough. That is, the first value of sample
    %                           size with a non-zero probability of making
    %                           a decision. 
    %	kmin:           1-D array of Athena kmin corresponding to n_out; 
    %                           size of n_out
    % -----------
    %
    % kmin[i] = smallest integer k such that stopping conditions are met. 


    %-------------Preliminaries--------------
    % p is fractional vote for winner 
    p=(1+margin)/2;
    
    % NumberRounds is the size of n_in and max size of n_out and kmin
    NumberRounds = size(n_in,2);

    % Initialize risk and stopping prob. scheds.
    RiskSched = zeros(1,NumberRounds);
    StopSched = zeros(1,NumberRounds);
    kmin = zeros(1, NumberRounds);
    startat=0;
    jcurrent=1;
    
    % Compute BRAVO kmins for alpha = delta to obtain an Athena condition
    [slope, intercept, n, kmin] = R2BRAVOkminWithSlope(margin, delta, n_in);

    %---------For jth audit round-----------
    %
    % For jcurrent=1 the stop prob and risk are straightforward: 
    % right tails of the corresponding binomial distribution. 
    % They are the same for Athena, Minerva and Metis

    % Right tail is 1-left tail, and left tail is the cdf. 
    % Compute ratios of tails for all values of k, and find first ratio to 
    % cross 1/alpha. This is kmin(1). 
    % If no ratio crosses alpha, try again with n_in(2) and so on. 
    % Continue till you find a round size, n_in(jcurrent) for which the
    % ratio is reached. Stop if you run out of rounds or if you find the
    % ratio. Note the value of jcurrent in startat if you find the ratio.  
    while startat == 0 && jcurrent <= NumberRounds
        Valid_k = find(alpha*(1-binocdf(ceil(n_in(jcurrent)/2):n_in(jcurrent), n_in(jcurrent), p))>= (1-binocdf(ceil(n_in(jcurrent)/2):n_in(jcurrent), n_in(jcurrent), 0.5)));
        if size(Valid_k,2) == 0
            jcurrent=jcurrent+1;
        else
            if strcmp(audit_method,'Athena')
            % Need check LR
                km = max(Valid_k(1)+ceil(n_in(jcurrent)/2), ceil(slope*n_in(jcurrent) + intercept));
                if km > n_in(jcurrent) % This round not large enough
                    jcurrent = jcurrent+1;
                else
                    kmin(jcurrent) = km;
                    startat = jcurrent;
                end
            else % others need not check LR
                kmin(jcurrent) = Valid_k(1)+ceil(n_in(jcurrent)/2);
                startat = jcurrent;
            end
        end
    end
    
    % We are here because we ran out of rounds or because we found a 
    % round for which the ratio is large enough. 
    
    if startat == 0 % didn't find a round, n_out and kmin are empty
        n_out = []; kmin = [];
    else
        % The stopping prob and risk corresponding to this value of kmin are:
        StopSched(startat) = 1-binocdf(kmin(startat)-1, n_in(startat), p);
        RiskSched(startat) = 1-binocdf(kmin(startat)-1, n_in(startat), 0.5);
        CStopSched = StopSched; 
        CRiskSched = RiskSched;
    
        % We now need to compute the pdf for smaller values of winner votes in 
        % the current sample, so we can compute the pdf for winner votes after 
        % drawing the next set of votes. 
        %                   
        % CurrentTier: array of size kmin(j) to store the non-zero 
        %               probabilities for winner votes in the interval 
        %               [0, kmin(j)-1] going into the next draw. Note that 
        %               there is zero probability of winner votes being 
        %               kmin(j) or larger. 
        %               For j=startat, hence, the CurrentTier is the binomial pdf 
        %               lopped off at kmin(startat). 

        CurrentTierStop=binopdf(0:kmin(startat)-1, n_in(startat), p);
        CurrentTierRisk=binopdf(0:kmin(startat)-1, n_in(startat), 0.5);
    
        % k: number of votes for the winner
        % Suppose the audit progresses to round j, j > 1. In order to 
        % compute the new pdf resulting from drawing more votes to get a 
        % total of n(j) votes, we use CurrentTier from the previous draw 
        % and the pdf for the probabilities of the entire sample drawn 
        % next to compute the new pdf. The risk is the right tail of this 
        % newly-computed pdf, which is lopped off and then becomes the 
        % (new) CurrentTier. 
    
        if startat < NumberRounds
            for j=startat+1:NumberRounds
                ThisRoundSize = n_in(j)-n_in(j-1);
                % Pad PreviousTier in readiness for FFT
                PreviousTierStop=[CurrentTierStop zeros(1,ThisRoundSize)];
                PreviousTierRisk=[CurrentTierRisk zeros(1,ThisRoundSize)];
                clear CurrentTierRisk;
                clear CurrentTierStop;
                % We now construct the new CurrentTier as the convolution 
                % of PreviousTier and the binomial function using the fft. 
                % Padding before fft is necessary, see, for example, 
                % https://www.mathworks.com/help/signal/ug/linear-and-circular-convolution.html
                % Padding ballot probability vector for the new draw
                NewBallotsStop = [binopdf(0:ThisRoundSize,ThisRoundSize, p) zeros(1,kmin(j-1)-1)];
                NewBallotsRisk = [binopdf(0:ThisRoundSize,ThisRoundSize, 0.5) zeros(1,kmin(j-1)-1)];
                % CurrentTier is convolution of the two
                CurrentTierStop=ifft(fft(PreviousTierStop).*fft(NewBallotsStop));
                CurrentTierRisk=ifft(fft(PreviousTierRisk).*fft(NewBallotsRisk));
                CDFStop = CumDistFunc(CurrentTierStop);
                CDFRisk = CumDistFunc(CurrentTierRisk);
                
                if strcmp(audit_method,'Athena') | strcmp(audit_method,'Minerva') 
                    % First test Athena/Minerva p-value
                    Valid_k = find(alpha*(1-CDFStop(ceil(n_in(j)/2)+1:size(CDFStop,2))) >= (1-CDFRisk(ceil(n_in(j)/2+1):size(CDFRisk,2))));
                    if strcmp(audit_method,'Minerva') % No testing LR
                        kmin(j) = Valid_k(1)+ceil(n_in(j)/2);
                    else % Next test Likelihood Ratio for Athena
                        kmin(j) = max(Valid_k(1)+ceil(n_in(j)/2), ceil(slope*n_in(j) + intercept));
                    end
                else % assume Metis
                    % Test only Metis p-value
                    Valid_k = find(alpha*(CStopSched(j-1)+1-CDFStop(ceil(n_in(j)/2)+1:size(CDFStop,2))) >= (CRiskSched(j-1)+1-CDFRisk(ceil(n_in(j)/2)+1:size(CDFStop,2))));
                    kmin(j) = Valid_k(1)+ceil(n_in(j)/2);
                end
                % Risk for this round:
                StopSched(j) = sum(CurrentTierStop(kmin(j)+1:size(StopSched,2)));
                RiskSched(j) = sum(CurrentTierRisk(kmin(j)+1:size(RiskSched,2)));
                CStopSched(j) = StopSched(j) + CStopSched(j-1);
                CRiskSched(j) = RiskSched(j) + CRiskSched(j-1);
                % Lop off at kmin: 
                CurrentTierStop = CurrentTierStop(1,1:kmin(j));
                CurrentTierRisk = CurrentTierRisk(1,1:kmin(j));
            end
        end
        n_out = n_in(startat:NumberRounds);
        kmin = kmin(startat:NumberRounds);
    end
end

    