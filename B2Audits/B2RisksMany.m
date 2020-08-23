function [RiskSched_Many, RiskValue_Many, ExpectedBallots_Many] = ...
    B2RisksMany(marginVector, NVector, n_Many, kmin_Many, audit_type)
    %
    % [RiskSched_Many, RiskValue_Many, ExpectedBallots_Many] = ...
    % BSquareRisksMany(marginVector, NVector, n_Many, kmin_Many, audit_type)
    %
    % This is the B2Risks function for vector inputs, used to compute 
    % multiple audits. 
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
    %
    % Input: 
    %   marginVector:       row vector of margins as a fraction (for 
    %                           stopping probs)
    %                           or vector of zeroes (for risks)
    %   NVector:            row vector of total votes cast in election. 
    %                           When the audit is with replacement, NVector 
    %                           is inconsequential. 
    %   Also input are the following structured lists of arrays. The lists
    %   are of size: 
    %       no. of margins X y X no. of election sizes
    %   where we assume that y is the number of risk limits used to 
    %   generate the input n_Many and kmin_Many. 
    %   Each pair of list items (n and kmin) corresponds to a single audit 
    %   defined by a particular combination of margin, alpha and N. Note
    %   we do not need the risk limits for computing the risks, and hence 
    %   they are not input here. The alpha here refers to that we assume 
    %   was used to generate the kmins that are input to this code. 
    %   n_Many:             structured list of 1-D arrays of number of 
    %                           samples
    %   kmin_Many:          structured list of 1-D arrays of kmin; same 
    %                           size as n
    %   audit_type:         0 or 1 depending on whether the audit is with 
    %                           or without replacement respectively. 
    %   Single entries (arrays) in n_Many and kmin_Many may be outputs of 
    %   B2BravoLikekmin or B2BRAVOkmin using margin, some values of 
    %   alpha (and N for BRAVOLike). For a single array in the list, the 
    %   jth value of kmin is the minimum number of votes for winner 
    %   required to terminate the audit round of size n(j). 
    %
    %   The audit defined by margin(i), an unknown (for this code) alpha(s) 
    %   and N(t) is at position (i,s,t)
    %   The best way to use this code is to use output from
    %   B2BravoLikeMany or B2BRAVOkminMany, but it may also be used to 
    %   evaluate the risks of other audits specified as described above. 
    %
    % ----------
    %
    % Output
    %   RiskSched_Many:         structured list of arrays of risk schedules. 
    %                               jth value in an array is the risk (or 
    %                               stopping prob.) of the n(j)th ballot 
    %                               draw for the corresponding audit
    %   RiskValue_Many:         array of the risks (or stopping 
    %                               probabilities) computed as the sum of 
    %                               all values of risk(j). 
    %   ExpectedBallots_Many:	array of floor of the expected number of 
    %                               ballots examined. Should be close to 
    %                               correct when sampling is without 
    %                               replacement. Should be larger than 
    %                               (1-risk-limit)*size(n, 2) for zero 
    %                               margin.
    %
    % ----------

    % for ease of computation
    num_margin=size(marginVector,2);
    % We assume the risk limit is the second dimension in n_Many
    num_alpha = size(n_Many,2);
    
    % For without replacement, we assume that the number of election sizes 
    % is the third dimension in n_Many. For with replacement, we ignore
    % election size. 
    if audit_type == 1
        num_N = size(n_Many,3);
        % Initialize RiskValue and Expected Ballots
        RiskValue_Many = zeros(num_margin, num_alpha, num_N);
        ExpectedBallots_Many = zeros(num_margin, num_alpha, num_N);
    
        for i=1:num_margin   
            for s=1:num_alpha
                for t=1:num_N
                    [RiskSched_Many{i,s,t}, RiskValue_Many(i,s,t), ExpectedBallots_Many(i,s,t)] = B2Risks(marginVector(i), NVector(t), n_Many{i,s,t}, kmin_Many{i,s,t}, audit_type);
                end
            end
        end
        
    else
        % Initialize RiskValue and Expected Ballots
        RiskValue_Many = zeros(num_margin, num_alpha);
        ExpectedBallots_Many = zeros(num_margin, num_alpha);
        
        for i=1:num_margin   
            for s=1:num_alpha
                [RiskSched_Many{i,s}, RiskValue_Many(i,s), ExpectedBallots_Many(i,s)] = B2Risks(marginVector(i), [], n_Many{i,s}, kmin_Many{i,s}, audit_type);
            end
        end
    end
end