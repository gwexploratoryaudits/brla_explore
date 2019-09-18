function [n, kmin] = BSquareBRAVOLikekminMany(margin, alpha, N)
% The BSquareBRAVOLikekmin function for vector inputs, used to compute 
% multiple audits. 
% Generating kmin for a B-square (ballot-by-ballot) BRAVO-like (BRAVO 
% without replacement) audit
%------------------
% Input: 
%   margin:         vector of fractional margins
%   alpha:          vector of fractional risk limits
%   N:              vector of total votes cast for two candidates
%----------
% Output: lists of size: size(margin,2) X size(alpha,2) X size(N,2)
%           each list element is an array (different-sized arrays)
%   n:              each element an array of sample sizes, beginning with  
%                       the first one where it is possible to stop the
%                        audit (k=n). 
%   kmin:           each element an array of minimum values of k; jth 
%                       value is the minimum number of votes for winner 
%                       required to terminate an audit with sample size n(j). 
%

%-------------
% Computed values.
% p:                Fractional vote count for winner
% winnertally:      Number of votes obtained by winner
% HalfN:            Maximum votes for announced winner for the election  
%                       outcome to be incorrect. That is, half the total  
%                       votes if N is even, and a losing margin of one 
%                       if N is odd.
% OneOverAlpha:     Inverse of the risk used repeatedly

    % for ease of computation
    num_margin=size(margin,2);
    num_alpha = size(alpha,2);
    num_N = size(N,2);
    
    for i=1:num_margin
        % p is fractional vote for winner 
        p = (1+margin(i))/2;
        for s=1:num_alpha
             % for ease of computation
             OneOverAlpha = 1/alpha(s);
             for t=1:num_N
                %---------------------
                % MODELLING THE BAYESIAN RISK
                %   We compute the likelihood ratio and compare it 
                %   to 1/alpha
                %   k: number of votes for winner in sample
                %   j: sample with sample size n(j)
                %   ratio: actual ratio for the kmin (sanity check, 
                %           differs from prescribed values because   
                %           kmin is integer, but ratio should not be 
                %           smaller than 1/alpha). 

                % For sample size n(j), for each possible value of 
                % k beginning at kmin(j-1), denoted kprev here to 
                % accommodate j=1, we determine the likelihood ratio. 
                % We stop when it is not smaller than 1/alpha. This is 
                % kmin(j) for the corresponding value of n(j).

                %----------Initialization----------%
                HalfN = floor(N(t)/2);
                winnertally = ceil(p*N(t));
                nvalue = (1:N(t));
                kprev = zeros(1,N(t)+1);
                kminvalue = zeros(1,N(t));
                ratio = zeros(1,N(t));
                kprev(1,1)=1;

                % We use startat to remember the value of j 
                % corresponding to the first time n(j) is 
                % sufficiently large: if all ballots in the sample are 
                % for the winner, we can stop the audit. 
                startat = 0;

                for j=1:N(t)
                    for k=kprev(1,j):nvalue(j)
                        ThisRatio = hygepdf(k,N(t),winnertally,nvalue(j))/hygepdf(k,N(t),HalfN,nvalue(j));
                        if ThisRatio > OneOverAlpha
                            break
                        end
                    end
                    kminvalue(1,j) = k;
                    kprev(1,j+1)=k;
                    if ThisRatio > OneOverAlpha && startat == 0
                        startat = j;
                    end
                end

                % We now delete the first few entries in n and kmin, 
                % so that the first entry is the first instance when 
                % ratio is large enough. 
                nvalue = [startat:N(t)];
                kminvalue = kminvalue(1,startat:N(t));
                %n{t+(s-1)*num_N+(i-1)*num_N*num_alpha}=nvalue;
                %kmin{t+(s-1)*num_N+(i-1)*num_N*num_alpha}=kminvalue;
                n{i,s,t}=nvalue;
                kmin{i,s,t}=kminvalue;
            end
        end
    end
end
