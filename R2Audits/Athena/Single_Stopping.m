function [kmin, pstop, pstop_minus_1] = Single_Stopping(margin, alpha, StopSched_prev, ...
                RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
                n_prev, k_prev, n_next)
%
% [kmin, pstop, pstop_minus_1] = Single_Stopping(margin, alpha, StopSched_prev, ...
%               RiskSched_prev, CurrentTierStop, CurrentTierRisk, ... 
%               n_prev, k_prev, n_next)
%
% Computes stopping probability and kmin for a single given round for a 
% single given k (number of winner ballots). Minerva. Also computes for 
% the previous size to detect a change. 
%
% ---------------------------Inputs------------------------
%
%       margin:             fractional margin
%       alpha:              fractional risk limit
%       StopSched_prev:     most recent Stop_Sched
%       RiskSched_prev:     most recent RiskSched 
%       CurrentTierStop:	most recent winner vote distribution for 
%                               election with margin
%       CurrentTierRisk:    most recent winner vote distribution for 
%                               tied election
%       n_prev:             total number of ballots drawn so far
%       k_prev:             total number of winner votes drawn so far
%       n_next:             potential next cumulative round size
%
% -------------------------Outputs---------------------------
% Each output is row vector of the size of percentiles
%
%       kmin:               kmin for the given next round size. 
%       pstop:              corresponding stopping probability. 
%       pstop_minus_1:      stopping probability for next round size n_next-1
%
% -------------------------Usage------------------------------
%
% Use for first round sizes as follows:
%   [kmin, pstop, pstop_minus_1] = Single_Stopping(margin, alpha, (0), (0), ...
%           (1), (1), 0, 0, n_next)
% 

	% assumed fraction of winner votes
	p = (1+margin)/2;
    
    % number of new draws
    new_draws = n_next-n_prev;
    
    %--------------Compute kmin----------------%
	if n_prev == 0 % First round. Do not need convolutions. 
        NextTierStop = binopdf(0:new_draws,new_draws,p);
        NextTierRisk = binopdf(0:new_draws,new_draws,0.5);
	else % Not first round, need convolution
        NextTierStop = R2CurrentTier(margin,CurrentTierStop,new_draws);
        NextTierRisk = R2CurrentTier(0,CurrentTierRisk,new_draws);
  end

	% Now that we have the stopping and tied election 
	% distributions, find a single kmin value for a new draw of 
	% new_draw ballots. AthenaNextkmin returns n+1 if kmin larger 
	% than n
	kmin = AthenaNextkmin(margin, alpha, [], StopSched_prev, ...
                RiskSched_prev, NextTierStop, NextTierRisk, n_next, 'Minerva');
            
    %---------------Compute Stopping----------------%
	if kmin <= n_next
        % Round is large enough for  non-zero stopping probability. 
        % Compute binomial cdf for kmin - k_prev for a draw of 
        % n_next ballots. 
        pstop = 1-binocdf(kmin-k_prev-1,new_draws,p);
  else
      pstop = 0;
	end % Found pstop
            
     %--------Repeat above process for new_draws-1 --- %
     
     %--------------Compute kmin for new_draws-1----------------%
	if n_prev == 0 % First round. Do not need convolutions. 
        NextTierStop = binopdf(0:new_draws-1,new_draws-1,p);
        NextTierRisk = binopdf(0:new_draws-1,new_draws-1,0.5);
	else % Not first round, need convolution
        NextTierStop = R2CurrentTier(margin,CurrentTierStop,new_draws-1);
        NextTierRisk = R2CurrentTier(0,CurrentTierRisk,new_draws-1);
	end
    
	kmin_minus_1 = AthenaNextkmin(margin, alpha, [], StopSched_prev, ...
                RiskSched_prev, NextTierStop, NextTierRisk, n_next-1, 'Minerva');
            
	if kmin_minus_1 <= n_next-1
        % Round is large enough for  non-zero stopping probability. 
        % Compute binomial cdf for kmin_minus_1 - k_prev for a draw of 
        % n_next-1 ballots. 
        pstop_minus_1 = 1-binocdf(kmin_minus_1-k_prev-1,new_draws-1,p);
  else
        pstop_minus_1 = 0;
	end % Found pstop
            