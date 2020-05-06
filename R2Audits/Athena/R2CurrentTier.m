function CurrentTier = R2CurrentTier(margin, PreviousTier, new_round_draws)
    %
    % CurrentTier = R2CurrentTier(margin, PreviousTier, new_round_draws)
    % This function returns winner vote distributions for an election 
    % defined by margin, for a new round, using the distribution for the 
    % previous round. 
    % ONLY FOR AUDITING WITH REPLACEMENT.
    % USES FOURIER TRANSFORM.
    %----------
    %
    % Input Values: 
    %   margin:             announced margin as a fraction for stopping probs;
    %                           zero for risk calculations
    %   PreviousTier:       row vector of previous winner vote distribution
    %   new_round_draws:	number of new draws
    %
    % Use PreviousTier = [1] when this is the first round. 
    %
    %----------
    %
    % Output Values
    %   CurrentTier:	array of individual probability values. kth value 
    %                           is the probability of having k-1 votes for 
    %                           the winner in this round. 
    %----------
    %

    % p: fractional vote count for winner
    p = (1+margin)/2;
    
    % We now construct the new CurrentTier as the convolution of 
    % PreviousTier and the binomial function for new_round_draws using 
    % the fft. Padding before fft is necessary, see, for example, 
    % https://www.mathworks.com/help/signal/ug/linear-and-circular-convolution.html
    
    % Consider two probability distributions of ballots: one with at most 
    % a ballots, and the other with at most b ballots. The lengths of the 
    % two vectors will be a+1 and b+1 respectively, to allow for the entry 
    % for zero ballots. The number of total ballots will be the sum of the 
    % two, which will be a+b. The probability distribution vector for the
    % sum will be of size a+b+1. Each vector needs to be padded to the 
    % size of the vector representing the sum. This is achieved by 
    % padding each vector by a zero vector of length: the other's size-1
    
    NewBallots = [binopdf(0:new_round_draws,new_round_draws, p) ...
        zeros(1,size(PreviousTier,2)-1)];
    PreviousTier=[PreviousTier zeros(1,new_round_draws)];
    
    % CurrentTier is convolution of the two
    CurrentTier=ifft(fft(PreviousTier).*fft(NewBallots));
end