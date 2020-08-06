function [n, kmin, Stopping] = StopProb_IrrelevantBallots(difference_fraction, alpha, delta, ...
    StopSched_prev, RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
    n_last, k_last, max_draws, audit_method, irrelevant_fraction)
    %
    % [n, kmin, Stopping] = StopProb_IrrelevantBallots(difference_fraction, ...
    %   alpha, delta, StopSched_prev, RiskSched_prev, CurrentTierStop, ... 
    %   CurrentTierRisk, n_last, k_last, max_draws, audit_method, irrelevant_fraction)
    %
    % Computes kmin and Stopping probability for various round sizes n
    % beginning at n_last + 1 and going on to max_draws. Takes in to 
    % account the reported percent of irrelevant ballots.
    % Outputs are arrays indexed by number of new ballots drawn. 
    % Same as StopProb.m but using new irrelevant ballot approach.
    %
    % ---------------------------Inputs------------------------
    %
    %       difference_fraction:    fractional difference between winner and loser votes
    %       alpha:                  fractional risk limit
    %       delta:                  minimum value for Athena LR; not needed for 
    %                                   other audit types
    %       StopSched_prev:         most recent Stop_Sched
    %       RiskSched_prev:         most recent RiskSched 
    %       CurrentTierStop:        most recent winner vote distribution for 
    %                                   election with margin
    %       CurrentTierRisk:        most recent winner vote distribution for 
    %                                   tied election
    %       n_last:                 total number of ballots drawn so far
    %       k_last:                 total number of winner votes drawn so far
    %       max_draws:              maximum number of ballots that can be 
    %                                   drawn in all
    %       audit_method:           one of Arlo, Athena, Minerva, Metis
    %
    %       irrelevant_fraction:    reported fraction of irrelevant ballots
    %
    % -------------------------Outputs---------------------------
    %
    %       n:                      total ballots drawn, (n_last+1:max_draws)
    %       kmin:                   corresponding kmin
    %       Stopping:               corresponding stopping probability
    %

% assumed fraction of winner votes
p = ((1-irrelevant_fraction)+difference_fraction)/2;

% assumed fraction of loser votes
l = 1-irrelevant_fraction-p;

% margin calculation to be passed into R2CurrentTier and AthenaNextkmin
denom = p+l;
margin = difference_fraction/denom;

% possible new total sample size
n = (n_last+1:max_draws);

% allocate kmin
kmin = zeros(1, size(n,2));

% allocate and initialize probabilities to zero
Stopping = zeros(1, max_draws-n_last);

%--------------Compute kmins----------------%

for j=1:max_draws-n_last % j is number of new ballots drawn

   if n_last == 0 % Not Arlo, but first round. Do not need convolutions. 
      NextTierStop = binopdf(0:j,j,(1+margin)/2);
      NextTierRisk = binopdf(0:j,j,0.5);
   else % Not Arlo and not first round, need convolution
      NextTierStop = R2CurrentTier(margin,CurrentTierStop,j);
      NextTierRisk = R2CurrentTier(0,CurrentTierRisk,j);
   end

   kmin(j) = AthenaNextkmin(margin, alpha, delta, StopSched_prev, ...
   RiskSched_prev, NextTierStop, NextTierRisk, n(j), audit_method);
  
end

%---------------Compute Stopping----------------%

% NOTE: Assuming not Arlo right now... 
for j=1:max_draws-n_last % j is number of new ballots drawn

    % Round is large enough for non-zero stopping probability
    if kmin(j) <= n(j)
        
        % Initialize stopping probability for round size of j
        Final_stop_prob = 0;
        
        for i=0:j % i is the number of irrelevant ballots, j-i is the number of relevant ballots
            
            % Initialize the stopping probability for round size of j where
            % i ballots are irrelevant 
            Stop_prob=0;
            
            % There is no chance of stopping if...
            %   - 0 of new ballots drawn are relevant
            %   - the number of relevant votes drawn is not large enough,
            %       meaning its corresponding kmin value returned is larger
            %       than itself   
            if (j-i > 0) && (kmin(j-i) <= n(j-i))
                for k=kmin(j-i)-k_last:j-i 
                
                    % Calculate the probability of drawing k winner ballots,
                    % j-k-i loser ballots, and i irrelevant ballots
                    Stop_prob = Stop_prob + TrinomialDistribution(p,l,irrelevant_fraction,k,j-k-i,i);
                end

                Final_stop_prob = Final_stop_prob + Stop_prob;
            end
        end 
            
        Stopping(j) = Final_stop_prob;
    end
end    

   