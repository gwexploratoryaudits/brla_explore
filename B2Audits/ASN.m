function Average_Ballots = ASN(margin, alpha)
    % 
    % Average_Ballots = ASN(margin, alpha)
    %
    % outputs ASN as described in BRAVO paper, eqn(5)
    %
    % ----------
    %
    % Input: 
    %   margin:         fractional margin
    %   alpha:          fractional risk limit
    %
    % ----------
    %
    % Output: 
    % Average_Ballots:  ASN value
    %
    % ----------

    p_w = (1+margin)/2;
    p_l = (1-margin)/2;
    z_w = log(1+margin);
    z_l = log(1-margin);

    Average_Ballots = (log(1/alpha)+ (z_w/2))/((p_w*z_w) + (p_l*z_l));
end