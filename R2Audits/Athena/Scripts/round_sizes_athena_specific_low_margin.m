% very basic script to compute Athena first round values for a single state
% also comparing to Filip's
% for very small margins (round sizes at least 10000)
% 10: Florida; 24: Minnesota; 39: Pennsylvania; 
% 23: Michigan; 30: NH; 50: Wisconsin 

% read previous file of the states
fname='2016_one_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
next_rounds = zeros(size(states,1), 1);

for i=39
    total_ballots = election_results.(states{i}).contests.presidential.ballots_cast;
    total_relevant_ballots = sum(election_results.(states{i}).contests.presidential.results);
    margin = abs(election_results.(states{i}).contests.presidential.margin);
    
    % factor to scale raw values by to obtain approx round sizes
    factor = total_ballots/total_relevant_ballots;
    
    n_est = estimate_first_round_Athena(margin, 0.1, 0.9);
    
    max_draw = n_est;
    next_rounds(i) = n_est+1;
    count = 0;
    
    while next_rounds(i) >= max_draw && count < 10
        count = count +1;
        min_draw = max_draw; 
        max_draw = min_draw + 1500;
        [next_rounds(i), ~, ~, ~]  = NextRoundSizesRanges(margin, 0.1, 1.0, (0), (0), (1), (1), 0, 0, (0.9), min_draw, max_draw, 'Athena');
    end
    election_results.(states{i}).contests.presidential.Athena_pv_raw = next_rounds(i);
	next_rounds_scaled(i) = ceil(factor*next_rounds(i));
	election_results.(states{i}).contests.presidential.Athena_pv_scaled = next_rounds_scaled(i);
    election_results.(states{i}).contests.presidential.n_est_Athena = n_est;
end

% Filip's athena file
fname2='2016_one_round_athena.json';
Athena_rounds = jsondecode(fileread(fname2));
tests = fieldnames(Athena_rounds);
for i=1:size(tests,1)
    fz(i) = Athena_rounds.(tests{i}).expected.round_candidates;
end

% the states are not in the same order as the states file and rather than 
% bother, simply swap them around. Put Maine and Nebraska (Nevada?) in 
% their correct positions. 
fz_fixed = fz(:,[1:19, 50, 20:26, 51, 27:49]);

% Write Filip's Athena values to our structure
for i=39
    election_results.(states{i}).contests.presidential.Athena_fz = fz_fixed(i);
end

% Write all these into the original file. 
txt = jsonencode(election_results);
fname3 = '2016_one_round_all.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

