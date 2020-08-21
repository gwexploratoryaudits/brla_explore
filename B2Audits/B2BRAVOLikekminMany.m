function [n_Many, kmin_Many] = B2BRAVOLikekminMany(marginVector, alphaVector, NVector)
    %
    % [n_Many, kmin_Many] = B2BRAVOLikekminMany(marginVector, alphaVector, NVector)
    % The B2BRAVOLikekmin function for vector inputs, used to compute 
    % multiple audits. 
    % Generating kmin for many B2 (ballot-by-ballot) BRAVO-like 
    % (BRAVO without replacement) audits. 
    %
    % ----------
    %
    % Input: 
    %	marginVector:       row vector of fractional margins.
    %	alphaVector:        row vector of fractional risk limits.
    %	NVector:            row vector of total votes cast for two candidates.
    %
    %----------
    %
    % Output:               two structured lists, each of size: 
    %                           no. of margin values X 
    %                           no. of alpha values X 
    %                           no of N values
    %                           each list element is an array (different-
    %                           sized arrays)
    %	n_Many:             each element of this list is a 1-D array n 
    %                           output by B2BRAVOLikekmin. It begins at 
    %                           the smallest sample size n(1) for which 
    %                           kmin(1) <= n(1) and the sample size gives 
    %                           a large enough likelihood ratio. The last 
    %                           value of n is the corresponding value of N. 
    %	kmin_many:          each element of this list is a 1-D array kmin 
    %                           from B2BRAVOLikekmin and is of the same 
    %                           size as the corresonding array n above; 
    %                           kmin(j) is the minimum number of votes for 
    %                           winner required to terminate an audit with 
    %                           sample size n(j). 
    %
    % ----------
    %

    % for ease of computation
    num_margin=size(marginVector,2);
    num_alpha = size(alphaVector,2);
    num_N = size(NVector,2);
    
    for i=1:num_margin
        for s=1:num_alpha
             for t=1:num_N
                [n_Many{i,s,t}, kmin_Many{i,s,t}, ~] = ...
                    B2BRAVOLikekmin(marginVector(i), alphaVector(s), NVector(t));
                % Observe that we do not care about the LLR output by 
                % B2BRAVOLikekmin here. 
             end
        end
    end
end
