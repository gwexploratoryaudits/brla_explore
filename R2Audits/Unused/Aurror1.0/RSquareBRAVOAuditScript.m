% This script designs an R-Square audit beginning with a given 
% stopping probability schedule, margin, risk limit and election size. 
%
% The script generates n and kmin from function BSquareBRAVOkmin, 
% then the stopping probability schedule and total stopping probabilities 
% from BSquareRisksMany, then sample sizes for percentiles, and, using 
% these and the risk schedule generated from BSquareRisksMany, an 
% Rsquare risk schedule and a corresponding kmin schedule. 
% 
% nB2, kminB2, StopSchedB2, RiskSchedB2, StopProbB2, RiskValueB2 are the 
% various parameters for direct application of B-by-B-BRAVO. 
% kminR2, StopSchedR2, RiskSchedR2, StopProbR2, RiskValueR2 give the 
% modified values. 
% GoalRiskSched is the goal risk sched, modelled on the risk sched for the
% B-by-B audit. 
%------------
%
%Input: 
%   margin:         election margin for BSquareBRAVO and the stopping
%                       probs. 
%   percentiles:    row of percentiles as fractions, these will decide 
%                       round sizes. 
%   alpha:          risk limit
%   N:              election size
%----------
% Output:
%   Row arrays of size number of rounds: 
%       RoundSched, kminB2, kminR2, StopSchedB2, RiskSchedB2, StopSchedR2, RiskSchedR2, GoalRiskSched. 
%  RiskValueB2, RiskValueR2, StopProbB2, StopProbR2, ExpectedBallotsB2,ExpectedBallotsR2. 

margin = 0.1;
percentiles = [0.25, 0.5, 0.75, 0.9, 0.99];
alpha = 0.1;
% N is a dummy variable needed to compute other values computed by the 
% functions we call. N not needed anywhere in an audit with replacement. 
N = 1000;

num_rounds = size(percentiles,2);

%Initialize
RoundSched = zeros(1,num_rounds);
StopSchedB2 =  zeros(1,num_rounds);
RiskSchedB2 =  zeros(1,num_rounds);
StopSchedR2 =  zeros(1,num_rounds);
RiskSchedR2 =  zeros(1,num_rounds);
GoalRiskSched =  zeros(1,num_rounds);
GoalProbSched =  zeros(1,num_rounds);
CStopSchedB2 =  zeros(1,num_rounds);
CRiskSchedB2 =  zeros(1,num_rounds);
CStopSchedR2 =  zeros(1,num_rounds);
CRiskSchedR2 =  zeros(1,num_rounds);
CGoalRiskSched =  zeros(1,num_rounds);
CGoalProbSched =  zeros(1,num_rounds);

% Generate BSquare BRAVO audit kmins
[kmslope, kmintercept, nBRAVO, kminBRAVO] = BSquareBRAVOkmin(margin,alpha);

% Generate stopping scheds and total probabilities for the same audit and 
% election margin. 
% ``0'' is used to indicate an audit with replacement. 
[StopSched, StopProb, ExpectedBallots] = BSquareRisks(margin, N, nBRAVO, kminBRAVO, 0);

% Obtain sample sizes for percentiles, this is the round schedule.  
RoundSched = StoppingPercentiles(nBRAVO, StopSched, percentiles);

% To obtain the corresponding risk schedule modelled on the BSquare audit, 
% first compute risk schedule of Bsquare audit, margin=0
[RiskSched, RiskValue, ExpectedBallots] = BSquareRisks(0, N, nBRAVO, kminBRAVO, 0);

% Now compute the desired risk schedule for the RSquare audit
GoalRiskSched(1,1) = sum(RiskSched(1,1:RoundSched(1,1)-nBRAVO(1)+1));
for m=2:num_rounds
    GoalRiskSched(m) = sum(RiskSched(1,RoundSched(m-1)+1-nBRAVO(1)+1:RoundSched(m)-nBRAVO(1)+1));
end

% Now compute kmins for an RSquare audit with RoundSched and GoalRiskSched
[kminR2, RiskSchedR2, RiskValueR2, ExpectedBallots] = RSquareInvRisks(0, N, RoundSched, GoalRiskSched, 0);

% Compute the stopping probs with this kmin
[StopSchedR2, StopProbR2, ExpectedBallotsR2] = RSquareRisks(margin, N, RoundSched, kminR2, 0);

% Compute kmins for direct application of BRAVO to compare
[kmslope, kmintercept, nB2, kminB2] = RSquareBRAVOkmin(margin, alpha, RoundSched);

% Use these kmins for stopping probs and risks
[RiskSchedB2, RiskValueB2, ExpectedBallots] = RSquareRisks(0, N, nB2, kminB2, 0);
[StopSchedB2, StopProbB2, ExpectedBallotsB2] = RSquareRisks(margin, N, nB2, kminB2, 0);

% Compute what the stopping probbailities should have been
GoalProbSched(1,1) = sum(StopSched(1,1:RoundSched(1,1)-nBRAVO(1)+1));
for m=2:num_rounds
    GoalProbSched(m) = sum(StopSched(1,RoundSched(m-1)+1-nBRAVO(1)+1:RoundSched(m)-nBRAVO(1)+1));
end

% Compute cumulative probabilities
CStopSchedB2 =  CumDistFunc(StopSchedB2);
CRiskSchedB2 =  CumDistFunc(RiskSchedB2);
CStopSchedR2 =  CumDistFunc(StopSchedR2);
CRiskSchedR2 =  CumDistFunc(RiskSchedR2);
CGoalRiskSched =  CumDistFunc(GoalRiskSched);
CGoalProbSched =  CumDistFunc(GoalProbSched);

%Display
RoundSched
kminR2
nB2
kminB2
CGoalProbSched
CStopSchedR2
CStopSchedB2
CGoalRiskSched
CRiskSchedR2
CRiskSchedB2
RiskValueR2
RiskValueB2
ExpectedBallotsR2
ExpectedBallotsB2

% Plot and save as images
plot(nB2,CGoalProbSched,'ko-',nB2,CStopSchedB2,'r+-', nB2, CStopSchedR2, 'b*-')
xlabel('Total Ballots Drawn. Cumulative round schedule is: 193, 332, 587, 974, 2155 ballots')
ylabel('Cumulative Stopping Probabilities')
title('Cumulative Stopping probabilities for margin=0.1 and risk limit=0.1')
legend('Theoretical BRAVO audit (Goal)','BRAVO as currently done','Proposed Audit', 'Location', 'South')
print -djpeg90 stopping.jpeg
plot(nB2,CGoalRiskSched,'ko-',nB2,CRiskSchedB2,'r+-', nB2, CRiskSchedR2, 'b*-')
xlabel('Total Ballots Drawn. Cumulative round schedule is: 193, 332, 587, 974, 2155 ballots')
ylabel('Cumulative (Maximum) Risk Expenditure')
title('Cumulative (Maximum) Risk Expenditure for margin=0.1 and risk limit=0.1')
legend('Theoretical BRAVO audit (Goal)','BRAVO as currently done','Proposed Audit', 'Location', 'South')
print -djpeg90 risk.jpeg

