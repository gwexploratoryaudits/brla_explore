% This script designs an R-Square audit beginning with 
% margin, a risk limit, election size, audit type, invalid votes, round 
% schedule, and a prescribed B-square audit defined by: 
%       ballot-by-ballot round schedule vector 
%       corresponding risk schedule. 
% 
% Note the round schedule would probably need to be computed by
% iterating on this script: using a trial round schedule, figuring 
% out what it gives, updating it in some direction, again seeing what 
% it gives, etc. 
%
% Anticipated use: to plan an audit, between the announcement of 
% rough election results and the audit itself. 
%
% The script generates: 
%   kmins using RSquareInvRisks
%   stopping probabilities using these kmins in RSquareRisks
% 
% nB2, RiskSchedB2, RoundSched are input; nB2 and RiskSchedB2 may be
% computed using B-SquareAudits/BSquareParameterScript
% kminR2, StopSchedR2, RiskSchedR2, StopProbR2, RiskValueR2 are the output
% 
% Intermediate computed value is GoalRiskSched 
%------------
%
%Input: 
%   margin:             election margin for BSquareBRAVO and the stopping
%                           probs. 
%   alpha:              risk limit
%   N:                  election size
%   R:                  invalid votes in election
%   audit_type:         0 for with replacement, else considered without
%   RoundSchedFull:     proposed round schedule
%   nB2:                ballot-by-ballot round sizes
%   RiskSchedB2:        Risk schedule for ballot-by-ballot audit
%----------
% Output:
%   Row arrays of size number of rounds: 
%       kminR2, StopSchedR2, RiskSchedR2, 
%   Single values:
%       StopProbR2, RiskValueR2, ExpectedBallotsR2. 

margin = 0.1;
alpha = 0.1;
% N is a dummy variable needed to compute other values computed by the 
% functions we call. N not needed anywhere in an audit with replacement. 
cost = 10; % one hand count ballot is equivalent to one-tenth of a polling audit ballot
N = 14000;
audit_type = 0; % with replacement
R = 1400;
RoundSchedFull = [350, 700, 1400];
RoundSchedLessInvalid = ceil(((N-R)/N)*RoundSchedFull);

num_rounds = size(RoundSchedFull,2);

nB2 = nBRAVO;
RiskSchedB2 = RiskSchedBRAVO;

%Initialize
GoalRiskSched =  zeros(1,num_rounds);
StopSchedR2 =  zeros(1,num_rounds);
RiskSchedR2 =  zeros(1,num_rounds);


% Desired risk schedule for the RSquare audit
GoalRiskSched(1,1) = sum(RiskSchedB2(1,1:RoundSchedLessInvalid(1,1)-nB2(1)+1));
for m=2:num_rounds-1
    GoalRiskSched(m) = sum(RiskSchedB2(1,RoundSchedLessInvalid(m-1)+1-nB2(1)+1:RoundSchedLessInvalid(m)-nB2(1)+1));
end
GoalRiskSched(num_rounds) = alpha-sum(GoalRiskSched(1:num_rounds-1));

% kmins for the RSquare audit defined by risk schedule
[kminR2, RiskSchedR2, RiskValueR2, ExpectedBallots] = RSquareInvRisks(0, N, RoundSchedLessInvalid, GoalRiskSched, audit_type);

% Compute the stopping probs with this kmin
[StopSchedR2, StopProbR2, ExpectedBallotsR2] = RSquareRisks(margin, N, RoundSchedLessInvalid, kminR2, audit_type);

% Take into account cost as well as true round sizes, with invalid votes,
% to compute expected ballots
%ExpectedBallotsWithCost =  dot(StopSchedR2,RoundSchedFull) + (((1-StopProbR2)*N)/cost);
ExpectedPolledBallotsR2 = dot(StopSchedR2,RoundSchedFull); 

% Compute cumulative probabilities
CStopSchedR2 =  CumDistFunc(StopSchedR2);
CRiskSchedR2 =  CumDistFunc(RiskSchedR2);
CGoalRiskSched = CumDistFunc(GoalRiskSched);

% For the B2 audit
if audit_type == 0
    [kmslope, kmintercept, n_outB2, kminB2] = RSquareBRAVOkmin(margin, alpha, RoundSchedLessInvalid);
else
    [n_outB2, kminB2, LLR] = RSquareBRAVOLikekmin(margin, alpha, N, RoundSchedLessInvalid)
end

[StopSchedB2, StopProbB2, ExpectedBallotsB2] = RSquareRisks(margin, N, RoundSchedLessInvalid, kminB2, audit_type);
[RiskSchedB2, RiskValueB2, ExpectedBallots] = RSquareRisks(0, N, RoundSchedLessInvalid, kminB2, audit_type);

CStopSchedB2 =  CumDistFunc(StopSchedB2);
CRiskSchedB2 =  CumDistFunc(RiskSchedB2);
ExpectedPolledBallotsB2 = dot(StopSchedR2,RoundSchedFull); 
%Display
RoundSchedLessInvalid
kminR2
n_outB2
kminB2
CStopSchedR2
CStopSchedB2
CGoalRiskSched
CRiskSchedR2
CRiskSchedB2
RiskValueR2
RiskValueB2
ExpectedBallotsR2
ExpectedBallotsB2
ExpectedPolledBallotsR2
ExpectedPolledBallotsB2

