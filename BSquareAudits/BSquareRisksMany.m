function [StopSched, RiskValue, ExpectedBallots] = BSquareRisksMany(margin, alpha, N, n, kmin, audit_type)
%------------------------
% The BSquareRisks function for vector inputs, used to compute 
% multiple audits. It has an additional input, vector alpha, to 
% properly compute the ordering of n and kmin. 
% This function returns:
%       ballot-by-ballot stopping probability 
%       total stopping probability 
%       number of expected ballots drawn
% for multiple ballot-by-ballot audits defined by: 
%       paired lists of (different-size) arrays of kmins and corresponding 
%       sample sizes n, 
% and applied to the corresponding elections defined by margin and N.
% Note that, if margin=0, it returns: 
%       ballot-by-ballot risk schedule
%       total risk
%       number of expected ballots drawn (for this case, a sanity check)
%
%----------
%   Input Values: 
%   margin:         vector of margins as a fraction (for stopping probs)
%                   or vector of zeroes (for risk calculations)
%   alpha:          vector of risk limits as fractions
%   N:              vector of total votes cast in election. when audits 
%                       are with replacement, does not influence anything
%   the following are lists of arrays, both corresponding lists are  
%   of the same size:
%               size(margin,2) X size(alpha, 2) X size(N)
%   Each pair of list items (n and kmin) corresponds to a single audit 
%   defined by a particular combination of margin, alpha and N
%   n:              list of vectors of number of samples
%   kmin:           list of arrays of kmin; same size as n
%
%   audit_type:     0 or 1 depending on whether the audit type is with or
%                       without replacement respectively. 
%   Single entries (arrays) in n and kmin are outputs of BSquareBravoLike 
%   or BSquareBRAVOkmin using margin, alpha and N. For a single array in 
%   the list, the jth value of kmin is the minimum number of votes for 
%   winner required to terminate the audit round of size n(j). 
%
%   The audits are ordered with margin representing the outermost 
%   dimension, then alpha, then N. That is, the audit defined by 
%   margin(i), alpha(s) and N(t) is at position 
%                   t+(s-1)*num_N+(i-1)*num_N*num_alpha
%   where num_alpha and num_N is the total number of values of alpha and N 
%   respectively. 
%
%   The best way to use this code is to use output from
%   BSquareBravoLikeMany or BSquareBRAVOkminMany. 
%
%--------------------------
% Output Values
%   StopSched:          list of arrays of individual risk values. jth value 
%                           in an array is the risk (or stopping prob.) of 
%                           the round with sample size n(j) for the
%                           corresponding audit
%   RiskValue:          array of the risk (or stopping probability) computed 
%                           as the sum of all values of risk(j). 
%   ExpectedBallots:	array of expected number of ballots examined
%                           should be larger than (1-risk-limit)*N for zero  
%                           margin.

%-------------

    % for ease of computation
    num_margin=size(margin,2);
    num_alpha = size(alpha,2);
    num_N = size(N,2);
    
    % Initialize RiskValue and Expected Ballots
    RiskValue = zeros(num_margin, num_alpha, num_N);
    ExpectedBallots = zeros(num_margin, num_alpha, num_N);
    
    for i=1:num_margin   
        % p: fractional vote count for winner
        p = (1+margin(i))/2;
        for s=1:num_alpha
            for t=1:num_N
                % WinnerVotes: number of votes won by the winner
                WinnerVotes = floor(p*N(t));
                % NumberDraws is the size of the n and kmin arrays
                % corresponding to the audit defined by i, s, t
                % We first picke these from the lists n and kmin
                %nvalue = n{t+(s-1)*num_N+(i-1)*num_N*num_alpha};
                %kminvalue = kmin{t+(s-1)*num_N+(i-1)*num_N*num_alpha};
                nvalue=n{i,s,t};
                kminvalue=kmin{i,s,t};
                NumberDraws = size(nvalue,2);

                % Computed Values
                % An underlying vote distribution gives rise to a pdf on k, 
                % the number of votes drawn for the winner in a sample of 
                % size n. The right tail of the pdf, from kmin on, is the 
                % stopping probability of the round. 
                
                % Initialize risk (or stopping prob. when margin is not zero)
                % for this audit. 
                riskvalue = zeros(1,NumberDraws);
                RiskValue(i,s,t) = 0;

                %---------For jth audit round-----------   
                % For j=1 the risk is straightforward: 
                % risk = right tail of the binomial/hypergeometric pmf. 
                % Similarly, stopping probability is the right tail of the 
                % pmf when the election is correct. 
                if audit_type==0
                    riskvalue(1) = 1-binocdf(kminvalue(1)-1, nvalue(1), p);
                else
                    riskvalue(1) = 1-hygecdf(kminvalue(1)-1, N(t), WinnerVotes, nvalue(1));
                end
    
                % We now need to compute the pdf for smaller values of 
                % winner votes in the current sample, so we can compute 
                % the pdf for winner votes after drawing the next set of 
                % votes. 
    
                % CurrentTier: array of size kminvalue(j) to store the 
                % non-zero probabilities for winner votes in the interval 
                % [0, kminvalue(j)-1] going into the next draw. Note that 
                % there is zero probability of winner votes being kminvalue(j) 
                % or larger. This CurrentTier is hence the 
                % binomial/hypergeometric pdf lopped off at kminvalue(1).  
                if audit_type==0
                    CurrentTier=binopdf(0:kminvalue(1)-1, nvalue(1), p);
                else
                    CurrentTier=hygepdf(0:kminvalue(1)-1, N(t), WinnerVotes, nvalue(1));
                end
    
                % k: number of votes for the winner
                % If the audit progresses to round j, j > 1, the pdf after 
                % drawing votes for audit round j uses CurrentTier for the 
                % current distribution and a simple expression for the 
                % probabilities of the single ballot drawn next. The risk 
                % is the right tail of this newly-computed pdf which is 
                % lopped off and then becomes CurrentTier. 
    
                for j=2:NumberDraws
                    PreviousTier=CurrentTier;
                    clear CurrentTier;
                    % k=0--first element of CurrentTier--is possible only 
                    % if jth draw is for the loser. In this case: 
                    if audit_type == 0
                        % with replacement: prob of draw for loser is 1-p
                        CurrentTier(1,1)=PreviousTier(1,1)*(1-p);
                    else
                        % Total number of ballots to draw from is 
                        %               N(t)-nvalue(j-1). 
                        % Total number of ballots for loser still in the 
                        % election is:  
                        %       original number, N(t)-WinnerVotes
                        %       less those drawn, nvalue(j-1), 
                        % the last of which were all for the loser, 
                        % which is how k=0
                        CurrentTier(1,1)=PreviousTier(1,1)*((N(t)-WinnerVotes)-nvalue(j-1))/(N(t)-nvalue(j-1));
                    end
        
                    % Now for other elements of CurrentTier, which obtain 
                    % contributions for both possible ballot draws: for 
                    % winner and for loser. 
                    for k=1:kminvalue(j-1)-1
                        if audit_type == 0
                            CurrentTier(1,k+1)=PreviousTier(1,k+1)*(1-p) + PreviousTier(1,k)*p; 
                        else
                            CurrentTier(1,k+1)=PreviousTier(1,k+1)*((N(t)-WinnerVotes)-(nvalue(j-1)-k))/(N(t)-nvalue(j-1)) + PreviousTier(1,k)*(WinnerVotes-(k-1))/(N(t)-nvalue(j-1));
                        end
                    end
        
                    % Finally adding one to the length of PreviousTier
                    % to obtain k = kminvalue(j-1)
                    if audit_type == 0
                        CurrentTier(1,kminvalue(j-1)+1)= PreviousTier(1,kminvalue(j-1))*p;
                    else
                        CurrentTier(1,kminvalue(j-1)+1)= PreviousTier(1,kminvalue(j-1))*(WinnerVotes-(kminvalue(j-1)-1))/(N(t)-nvalue(j-1));
                    end
        
                    %kminvalue for this round might be larger than 
                    % kminvalue(j-1)
                    if kminvalue(j) > kminvalue(j-1)
                        if audit_type == 0
                            CurrentTier(1, kminvalue(j-1)+2:kminvalue(j)+1)=0;
                        else
                            CurrentTier(1, kminvalue(j-1)+2:kminvalue(j)+1)=0;
                        end
                    end
        
                    riskvalue(j) = CurrentTier(1,kminvalue(j)+1);
                    CurrentTier=CurrentTier(1,1:kminvalue(j));
                end
                RiskValue(i,s,t) = sum(riskvalue(1:NumberDraws));
                ExpectedBallots(i,s,t) = dot(riskvalue,nvalue) + (1-RiskValue(i,s,t))*size(nvalue,2);
                StopSched{i,s,t} = riskvalue;
                %risk{t+(s-1)*num_N+(i-1)*num_N*num_alpha}=riskvalue;
            end
        end
    end
end