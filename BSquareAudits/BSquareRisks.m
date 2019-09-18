function [risk, RiskValue, ExpectedBallots] = BSquareRisks(margin, N, n, kmin, audit_type)
%------------------------
% This function returns:
%       ballot-by-ballot stopping probability 
%       total stopping probability 
%       number of expected ballots drawn
% for a ballot-by-ballot audit defined by an array of kmin values, 
% applied to an election defined by margin.
% Note that, if margin=0, it returns: 
%       ballot-by-ballot risk schedule
%       total risk
%       number of expected ballots drawn (for this case, a sanity check)
%
%----------
%   Input Values: 
%   margin:         announced margin as a fraction for stopping probs;
%                   zero for risk calculations
%   N:              votes cast for two candidates; when audits with
%                   replacement, influences only ExpectedBallots
%   n:              vector of audit sizes as audit escalates
%   kmin:           Array of same size as n 
%   audit_type:     0 for with, or 1 for without, replacement
%
%   n and kmin are outputs of BSquareBravoLike or BSquareBRAVOkmin using 
%   margin (and N) when margin is not zero. the jth value of kmin is  
%   the minimum number of votes for winner required to terminate the 
%   audit round of size n(j). 
%
%--------------------------
% Output Values
%   risk:             array of individual risk values. jth value is the 
%                       risk (or stopping prob.) of the round with sample 
%                       size n(j)
%   RiskValue:        the risk computed as the sum of all values of risk(j). 
%   ExpectedBallots:  expected number of ballots examined
%                       should be larger than (1-risk-limit)*N for zero  
%                       margin.

%-------------
% Computed Values
% The right tail of the pdf at a round is the risk of the round, for an
% underlying vote distribution corresponding to the pdf. 
% The worst case risk corresponds to the pdf representing a tied election 
% (for even N) or one where the winner lost by a single vote (for odd N). 

% p: fractional vote count for winner
p = (1+margin)/2;
% WinnerVotes: number of votes won by the winner
WinnerVotes = floor(p*N);
% NumberDraws is the size of n and kmin
NumberDraws = size(n,2);

% Initialize risk (or stopping prob. when margin is not zero). 
risk = zeros(1,NumberDraws);
RiskValue = 0;

    %---------For jth audit round-----------   
    % For j=1 the risk is straightforward: 
    % risk = right tail of the hypergeometric pmf (without replacement)
    % risk = right tail of binomial distribution (with replacement)
    % Similarly, stopping probability is the right tail of the distribution 
    % when the election is correct. 
    if audit_type==0
        risk(1) = 1-binocdf(kmin(1)-1, n(1), p);
    else
        risk(1) = 1-hygecdf(kmin(1)-1, N, WinnerVotes, n(1));
    end
    
    % We now need to compute the pdf for smaller values of winner votes in 
    % the current sample, so we can compute the pdf for winner votes after 
    % drawing the next set of votes. 
    %                   
    % CurrentTier: array of size kmin(j) to store the 
    %               non-zero probabilities for winner votes in the 
    %               interval [0, kmin(j)-1] going into
    %               the next draw. Note that there is zero probability of 
    %               winner votes being kmin(j) or larger. 
    %               This CurrentTier is hence the hypergeometric pdf
    %               (without replacement) or the binomial pdf (with
    %               replacement) lopped off at kmin(1).  
    if audit_type==0
        CurrentTier=binopdf(0:kmin(1)-1, n(1), p);
    else
        CurrentTier=hygepdf(0:kmin(1)-1, N, WinnerVotes, n(1));
    end
    
    % k: number of votes for the winner
    % If the audit progresses to round j, j > 1, the pdf after drawing 
    % votes for audit round j uses CurrentTier for the current distribution 
    % and a simple expression for the probabilities of the single ballot
    % drawn next. The risk is the right tail of this newly-computed pdf
    % which is lopped off and then becomes CurrentTier. 
    
    for j=2:NumberDraws
        PreviousTier=CurrentTier;
        clear CurrentTier;
        % k=0--first element of CurrentTier--is possible only if jth draw
        % is for the loser. In this case: 
        if audit_type == 0
            % with replacement: prob of draw for loser is 1-p
            CurrentTier(1,1)=PreviousTier(1,1)*(1-p);
        else
            % without replacement: 
            % Total number of ballots to draw from is N-n(j-1). 
            % Total number of ballots for loser still in the election is:
            %       original number, N-WinnerVotes
            %       less those drawn, n(j-1), 
            % the last of which were all for the loser, which is how k=0
            CurrentTier(1,1)=PreviousTier(1,1)*((N-WinnerVotes)-n(j-1))/(N-n(j-1));
        end
        % Now for other elements of CurrentTier, which obtain contributions
        % for both possible ballot draws: for winner and for loser. 
        for k=1:kmin(j-1)-1
            if audit_type == 0
               CurrentTier(1,k+1)=PreviousTier(1,k+1)*(1-p) + PreviousTier(1,k)*p; 
            else
                CurrentTier(1,k+1)=PreviousTier(1,k+1)*((N-WinnerVotes)-(n(j-1)-k))/(N-n(j-1)) + PreviousTier(1,k)*(WinnerVotes-(k-1))/(N-n(j-1));
            end
        end
        
        % Finally adding one to the length of PreviousTier
        % to obtain k = kmin(j-1)
        if audit_type == 0
            CurrentTier(1,kmin(j-1)+1)= PreviousTier(1,kmin(j-1))*p;
        else
            CurrentTier(1,kmin(j-1)+1)= PreviousTier(1,kmin(j-1))*(WinnerVotes-(kmin(j-1)-1))/(N-n(j-1));
        end
        
        %kmin for this round might be larger than kmin(j-1)
        if kmin(j) > kmin(j-1)
            if audit_type == 0
                CurrentTier(1, kmin(j-1)+2:kmin(j)+1)=0;
            else
                CurrentTier(1, kmin(j-1)+2:kmin(j)+1)=0;
            end
        end
        
        % kmin increases by at most 1
        risk(j) = CurrentTier(1,kmin(j)+1);
        CurrentTier=CurrentTier(1,1:kmin(j));
        %save;
    end
    RiskValue = sum(risk(1:NumberDraws));
    ExpectedBallots = dot(risk,n) + (1-RiskValue)*N;
end