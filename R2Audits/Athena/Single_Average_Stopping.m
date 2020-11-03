function [kmin, pstop, pstop_minus_1] = Single_Average_Stopping(margin, ...
                alpha, StopSched_prev, RiskSched_prev, CurrentTierStop, ...
                CurrentTierRisk, n_prev, n_next)
%
% [kmin, pstop, pstop_minus_1] = Single_Average_Stopping(margin, ...
%           alpha, StopSched_prev, RiskSched_prev, CurrentTierStop, ...
%           CurrentTierRisk, n_prev, n_next)
%
% Computes stopping probability and kmin for a single given round. 
% Crucially, this is without knowing k (number of winner ballots in sample). 
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
%           (1), (1), 0, n_next)
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
        % Note that NextTierStop sums up to only 1-sum(StopSched_prev).
        all_stop = 1-sum(StopSched_prev);
        if all_stop >= 0.000001
            pstop = sum(NextTierStop(kmin+1:n_next))/all_stop;
        else
            pstop=0;
        end
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
        if all_stop >= 0.000001
            pstop_minus_1 = sum(NextTierStop(kmin_minus_1+1:n_next-1))/all_stop;
        else
            pstop=0;
        end
    else
        pstop_minus_1 = 0;
	end % Found pstop
            