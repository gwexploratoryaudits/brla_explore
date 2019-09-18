function [n, kmin, ratio] = BSquareBRAVOLikekmin(margin, alpha, N)
% Generating kmin for a B-square (ballot-by-ballot) BRAVO-like (BRAVO 
% without replacement) audit
%------------------
% Input: 
%   margin:         fractional margin
%   alpha:          fractional risk limit
%   N:              votes cast for two candidates
%----------
% Output:
%   n:              array of sample sizes, beginning with the first one 
%                       where it is possible to stop the audit (k=n). 
%   kmin:           array of minimum values of k; jth  value is the minimum 
%                       number of votes for winner required to terminate 
%                       an audit with sample size n(j). 
%   ratio:         array of values of the likelihood ratio, sanity check. 

%-------------
% Computed values.
% HalfN:            Maximum votes for announced winner for the election  
%                       outcome to be incorrect. That is, half the total  
%                       votes if N is even, and a losing margin of one 
%                       if N is odd.
% OneOverAlpha:     Inverse of the risk used repeatedly
% p:                Fractional vote count for winner
% winnertally:      Number of votes obtained by winner

HalfN = floor(N/2);
OneOverAlpha = 1/alpha;
p = (1+margin)/2;
winnertally = ceil(p*N);

%---------------------
% MODELLING THE BAYESIAN RISK
%   We compute the likelihood ratio and compare it to 1/alpha
%   k: number of votes for winner in sample
%   j: sample with sample size n(j)
%   ratio: actual ratio for the kmin (sanity check, 
%           differs from prescribed values because kmin is integer, but  
%           ratio should not be smaller than 1/alpha). 

% For sample size n(j), for each possible value of k beginning at 
% kmin(j-1), denoted kprev here to accommodate j=1, we determine the   
% likelihood ratio. We stop when it is not smaller than 1/alpha. This is 
% kmin(j) for the corresponding value of n(j).

%----------Initialization----------%
n = (1:N);
kprev = zeros(1,N+1);
kmin = zeros(1,N);
ratio = zeros(1,N);
kprev(1,1)=1;

% We use startat to remember the value of j corresponding to the first 
% time n(j) is sufficiently large: if all ballots in the sample are for 
% the winner, we can stop the audit. 
startat = 0;

    for j=1:N
        for k=kprev(1,j):n(j)
            ThisRatio = hygepdf(k,N,winnertally,n(j))/hygepdf(k,N,HalfN,n(j));
            if ThisRatio > OneOverAlpha
                break
            end
        end
        kmin(1,j) = k;
        kprev(1,j+1)=k;
        ratio(1,j) = ThisRatio;
        if ThisRatio > OneOverAlpha && startat == 0
            startat = j;
        end
    end

    % We now delete the first few entries in n and kmin, so that the 
    % first entry is the first instance when ratio is large enough. 
    n = n(startat:N);
    kmin = kmin(1,startat:N);
end
