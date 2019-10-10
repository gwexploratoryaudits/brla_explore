% This script designs an R-Square audit beginning with a given 
% stopping probability schedule, margin, risk limit and election size. It
% is intended to provide expository numbers to convince folks who are used
% to BRAVO numbers. 
%
% The script generates n and kmin from function 
% BSquareBRAVOkmin/BSquareBRAVOLikekmin, then the stopping probability 
% schedules and total stopping probabilities from BSquareRisks, then 
% sample sizes for percentiles, and, using these and the risk schedule 
% generated from BSquareRisks, an Rsquare risk schedule and a corresponding 
% kmin schedule. 
% 
% nB2, kminB2, StopSchedB2, RiskSchedB2, StopProbB2, RiskValueB2 are the 
% various parameters for direct application of B-by-B-audits. 
% kminR2, StopSchedR2, RiskSchedR2, StopProbR2, RiskValueR2 give the 
% modified values. 
% GoalRiskSched is the goal risk sched, modelled on the risk sched for the
% B-by-B audit. 
%------------
%
%Input: 
%   margin:         election margin for BSquareBRAVO/BRAVOLike and the 
%                       stopping probs. 
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
N = 14000;

num_rounds = size(percentiles,2);

%Initialize
RoundSched = zeros(1,num_rounds);
StopSchedB2BRAVO =  zeros(1,num_rounds);
RiskSchedB2BRAVO =  zeros(1,num_rounds);
StopSchedR2BRAVO =  zeros(1,num_rounds);
RiskSchedR2BRAVO =  zeros(1,num_rounds);
GoalRiskSchedBRAVO =  zeros(1,num_rounds);
GoalProbSchedBRAVO =  zeros(1,num_rounds);
CStopSchedB2BRAVO =  zeros(1,num_rounds);
CRiskSchedB2BRAVO =  zeros(1,num_rounds);
CStopSchedR2BRAVO =  zeros(1,num_rounds);
CRiskSchedR2BRAVO =  zeros(1,num_rounds);
CGoalRiskSchedBRAVO =  zeros(1,num_rounds);
CGoalProbSchedBRAVO =  zeros(1,num_rounds);

StopSchedB2BRAVOLike =  zeros(1,num_rounds);
RiskSchedB2BRAVOLike =  zeros(1,num_rounds);
StopSchedR2BRAVOLike =  zeros(1,num_rounds);
RiskSchedR2BRAVOLike =  zeros(1,num_rounds);
GoalRiskSchedBRAVOLike =  zeros(1,num_rounds);
GoalProbSchedBRAVOLike =  zeros(1,num_rounds);
CStopSchedB2BRAVOLike =  zeros(1,num_rounds);
CRiskSchedB2BRAVOLike =  zeros(1,num_rounds);
CStopSchedR2BRAVOLike =  zeros(1,num_rounds);
CRiskSchedR2BRAVOLike =  zeros(1,num_rounds);
CGoalRiskSchedBRAVOLike =  zeros(1,num_rounds);
CGoalProbSchedBRAVOLike =  zeros(1,num_rounds);

% Generate BSquare BRAVO audit kmins
[kmslope, kmintercept, nBRAVO, kminBRAVO] = BSquareBRAVOkmin(margin,alpha);

% Generate BSquare BRAVOLike audit kmins
[nBRAVOLike, kminBRAVOLike, LLR] = BSquareBRAVOLikekmin(margin,alpha, N);

% Generate stopping scheds and total probabilities for the same BRAVO audit 
% and election margin. 
% ``0'' is used to indicate an audit with replacement. 
[StopSchedBRAVO, StopProbBRAVO, ExpectedBallotsBRAVOTrue] = BSquareRisks(margin, N, nBRAVO, kminBRAVO, 0);
[StopSchedBRAVOLike, StopProbBRAVOLike, ExpectedBallotsBRAVOLikeTrue] = BSquareRisks(margin, N, nBRAVOLike, kminBRAVOLike, 1);

% Obtain sample sizes for percentiles, this is the round schedule.  
RoundSched = StoppingPercentiles(nBRAVO, StopSchedBRAVO, percentiles);

% To obtain the corresponding risk schedule modelled on the BSquare audit, 
% first compute risk schedule of Bsquare audit, margin=0
[RiskSchedBRAVO, RiskValueBRAVO, ExpectedBallotsBRAVO] = BSquareRisks(0, N, nBRAVO, kminBRAVO, 0);
[RiskSchedBRAVOLike, RiskValueBRAVOLike, ExpectedBallotsBRAVOLike] = BSquareRisks(0, N, nBRAVOLike, kminBRAVOLike, 1);

% Now compute the desired risk schedule for the RSquare audit
GoalRiskSchedBRAVO(1,1) = sum(RiskSchedBRAVO(1,1:RoundSched(1,1)-nBRAVO(1)+1));
GoalRiskSchedBRAVOLike(1,1) = sum(RiskSchedBRAVOLike(1,1:RoundSched(1,1)-nBRAVOLike(1)+1));
for m=2:num_rounds
    GoalRiskSchedBRAVO(m) = sum(RiskSchedBRAVO(1,RoundSched(m-1)+1-nBRAVO(1)+1:RoundSched(m)-nBRAVO(1)+1));
    GoalRiskSchedBRAVOLike(m) = sum(RiskSchedBRAVOLike(1,RoundSched(m-1)+1-nBRAVOLike(1)+1:RoundSched(m)-nBRAVOLike(1)+1));
end

% Now compute kmins for an RSquare audit with RoundSched and GoalRiskSchedBRAVO
[kminR2BRAVO, RiskSchedR2BRAVO, RiskValueR2BRAVO, ExpectedBallotsBRAVO] = RSquareInvRisks(0, N, RoundSched, GoalRiskSchedBRAVO, 0);
[kminR2BRAVOLike, RiskSchedR2BRAVOLike, RiskValueR2BRAVOLike, ExpectedBallotsBRAVOLike] = RSquareInvRisks(0, N, RoundSched, GoalRiskSchedBRAVO, 1);

% Compute the stopping probs with this kmin
[StopSchedR2BRAVO, StopProbR2BRAVO, ExpectedBallotsR2BRAVO] = RSquareRisks(margin, N, RoundSched, kminR2BRAVO, 0);
[StopSchedR2BRAVOLike, StopProbR2BRAVOLike, ExpectedBallotsR2BRAVOLike] = RSquareRisks(margin, N, RoundSched, kminR2BRAVOLike, 1);

% Compute kmins for direct application of audit to compare
[kmslope, kmintercept, nB2BRAVO, kminB2BRAVO] = RSquareBRAVOkmin(margin, alpha, RoundSched);
[nB2BRAVOLike, kminB2BRAVOLike, LLR] = RSquareBRAVOLikekmin(margin, alpha, N, RoundSched);

% Use these kmins for stopping probs and risks
[RiskSchedB2BRAVO, RiskValueB2BRAVO, ExpectedBallotsBRAVO] = RSquareRisks(0, N, nB2BRAVO, kminB2BRAVO, 0);
[StopSchedB2BRAVO, StopProbB2BRAVO, ExpectedBallotsB2BRAVO] = RSquareRisks(margin, N, nB2BRAVO, kminB2BRAVO, 0);

[RiskSchedB2BRAVOLike, RiskValueB2BRAVOLike, ExpectedBallotsBRAVOLike] = RSquareRisks(0, N, nB2BRAVOLike, kminB2BRAVOLike, 1);
[StopSchedB2BRAVOLike, StopProbB2BRAVOLike, ExpectedBallotsB2BRAVOLike] = RSquareRisks(margin, N, nB2BRAVOLike, kminB2BRAVOLike, 1);

% Compute what the stopping probabilities should have been
GoalProbSchedBRAVO(1,1) = sum(StopSchedBRAVO(1,1:RoundSched(1,1)-nBRAVO(1)+1));
GoalProbSchedBRAVOLike(1,1) = sum(StopSchedBRAVOLike(1,1:RoundSched(1,1)-nBRAVOLike(1)+1));
for m=2:num_rounds
    GoalProbSchedBRAVO(m) = sum(StopSchedBRAVO(1,RoundSched(m-1)+1-nBRAVO(1)+1:RoundSched(m)-nBRAVO(1)+1));
    GoalProbSchedBRAVOLike(m) = sum(StopSchedBRAVOLike(1,RoundSched(m-1)+1-nBRAVOLike(1)+1:RoundSched(m)-nBRAVOLike(1)+1));
end

% Compute cumulative probabilities
CStopSchedB2BRAVO =  CumDistFunc(StopSchedB2BRAVO);
CRiskSchedB2BRAVO =  CumDistFunc(RiskSchedB2BRAVO);
CStopSchedR2BRAVO =  CumDistFunc(StopSchedR2BRAVO);
CRiskSchedR2BRAVO =  CumDistFunc(RiskSchedR2BRAVO);
CGoalRiskSchedBRAVO =  CumDistFunc(GoalRiskSchedBRAVO);
CGoalProbSchedBRAVO =  CumDistFunc(GoalProbSchedBRAVO);

CStopSchedB2BRAVOLike =  CumDistFunc(StopSchedB2BRAVOLike);
CRiskSchedB2BRAVOLike =  CumDistFunc(RiskSchedB2BRAVOLike);
CStopSchedR2BRAVOLike =  CumDistFunc(StopSchedR2BRAVOLike);
CRiskSchedR2BRAVOLike =  CumDistFunc(RiskSchedR2BRAVOLike);
CGoalRiskSchedBRAVOLike =  CumDistFunc(GoalRiskSchedBRAVOLike);
CGoalProbSchedBRAVOLike =  CumDistFunc(GoalProbSchedBRAVOLike);

%Display
RoundSched
kminR2BRAVO
nB2BRAVO
kminB2BRAVO
RoundSched
kminR2BRAVOLike
nB2BRAVOLike
kminB2BRAVOLike

CGoalProbSchedBRAVO
CStopSchedR2BRAVO
CStopSchedB2BRAVO
CGoalProbSchedBRAVOLike
CStopSchedR2BRAVOLike
CStopSchedB2BRAVOLike

CGoalRiskSchedBRAVO
CRiskSchedR2BRAVO
CRiskSchedB2BRAVO
CGoalRiskSchedBRAVOLike
CRiskSchedR2BRAVOLike
CRiskSchedB2BRAVOLike

RiskValueR2BRAVO
RiskValueB2BRAVO
ExpectedBallotsBRAVOTrue
ExpectedBallotsR2BRAVO
ExpectedBallotsB2BRAVO
RiskValueR2BRAVOLike
RiskValueB2BRAVOLike
ExpectedBallotsBRAVOLikeTrue
ExpectedBallotsR2BRAVOLike
ExpectedBallotsB2BRAVOLike

% Plot and save as images
plot(nB2BRAVO,CGoalProbSchedBRAVO,'ko-',nB2BRAVO,CStopSchedB2BRAVO,'r+-', nB2BRAVO, CStopSchedR2BRAVO, 'b*-', nB2BRAVOLike,CGoalProbSchedBRAVOLike,'gs-',nB2BRAVOLike,CStopSchedB2BRAVOLike,'md-', nB2BRAVOLike, CStopSchedR2BRAVOLike, 'c^-')
xlabel('Total Ballots Drawn. Cumulative round schedule is: 193, 332, 587, 974, 2155 ballots')
ylabel('Cumulative Stopping Probabilities')
title('Cumulative Stopping probabilities for margin=0.1 and risk limit=0.1')
legend('Theoretical BRAVO audit (Goal)','BRAVO as currently done','Proposed Audit', 'Theoretical BRAVOLike audit (Goal)','BRAVOLike as currently done','Proposed Audit','Location', 'South')
print -djpeg90 stopping.jpeg
plot(nB2BRAVO,CGoalRiskSchedBRAVO,'ko-',nB2BRAVO,CRiskSchedB2BRAVO,'r+-', nB2BRAVO, CRiskSchedR2BRAVO, 'b*-', nB2BRAVOLike, CGoalRiskSchedBRAVOLike,'gs-',nB2BRAVOLike,CRiskSchedB2BRAVOLike,'md-', nB2BRAVOLike, CRiskSchedR2BRAVOLike, 'c^-')
xlabel('Total Ballots Drawn. Cumulative round schedule is: 193, 332, 587, 974, 2155 ballots')
ylabel('Cumulative (Maximum) Risk Expenditure')
title('Cumulative (Maximum) Risk Expenditure for margin=0.1 and risk limit=0.1')
legend('Theoretical BRAVO audit (Goal)','BRAVO as currently done','Proposed Audit','Theoretical BRAVOLike audit (Goal)','BRAVOLike as currently done','Proposed Audit', 'Location', 'South')
print -djpeg90 risk.jpeg

