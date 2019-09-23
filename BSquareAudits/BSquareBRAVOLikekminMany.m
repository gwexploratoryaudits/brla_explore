function [n_Many, kmin_Many] = BSquareBRAVOLikekminMany(marginVector, alphaVector, NVector)
    %
    % [n_Many, kmin_Many] = BSquareBRAVOLikekminMany(marginVector, alphaVector, NVector)
    % The BSquareBRAVOLikekmin function for vector inputs, used to compute 
    % multiple audits. 
    % Generating kmin for many B-square (ballot-by-ballot) BRAVO-like 
    % (BRAVO without replacement) audits. 
    % ----------
    % Input: 
    %	marginVector:       row vector of fractional margins.
    %	alphaVector:        row vector of fractional risk limits.
    %	NVector:            row vector of total vot[es cast for two candidates.
    %----------
    % Output:           two structured lists, each of size: 
    %                       no. of margin values X 
    %                       no. of alpha values X 
    %                       no of N values
    %                       each list element is an array (different-sized 
    %                       arrays)
    %	n_Many:         each element of this list is a 1-D array n from 
    %                       BSquareBRAVOLikekmin. It begins at the smallest 
    %                       sample size for which a kmin no larger than 
    %                       sample size gives a large enough likelihood 
    %                       ratio and ends at the corresponding value of N. 
    %	kmin_many:      each element of this list is a 1-D array kmin from
    %                       BSquareBRAVOLike kmin; jth value is the minimum 
    %                       number of votes for winner required to terminate 
    %                       an audit with sample size n(j). 
    % ----------

    % for ease of computation
    num_margin=size(marginVector,2);
    num_alpha = size(alphaVector,2);
    num_N = size(NVector,2);
    
    for i=1:num_margin
        for s=1:num_alpha
             for t=1:num_N
                [n_Many{i,s,t}, kmin_Many{i,s,t}, ratio] = BSquareBRAVOLikekmin(marginVector(i), alphaVector(s), NVector(t));
             end
        end
    end
end
