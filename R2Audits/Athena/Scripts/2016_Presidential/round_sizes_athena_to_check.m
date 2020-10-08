% very basic script to read Athena raw first round values and 
% check kmin for delta = 1 and confirm that it does satisfy 
% Minerva condition. In this case, Minerva and Athena are the same. 
% Need raw values. 
fname='2016_one_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);


for i=1:size(states,1)
    if i==23 % Computed using estimate_first_round
        margin = abs(election_results.(states{i}).contests.presidential.margin);
        raw_value = 1259688/(4799284/(2279543+2268839));    
    else
        margin = abs(election_results.(states{i}).contests.presidential.margin);
        raw_value = election_results.(states{i}).contests.presidential.Athena_pv_raw;
    end
    % p is the fractional vote for winner 
    p=(1+margin)/2;

    % For ease of computation
    logpoveroneminusp=log(p/(1-p));

    kmslope = (log(0.5/(1-p)))/logpoveroneminusp;
    kmin_delta = kmslope*raw_value;
    ratio(i) = (1-binocdf(kmin_delta-1, raw_value, p))/(1-binocdf(kmin_delta-1, raw_value, 0.5));
end