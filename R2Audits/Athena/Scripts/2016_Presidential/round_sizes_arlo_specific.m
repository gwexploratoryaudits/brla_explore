% very basic script to compute Arlo first round values for a single state
% also comparing to Filip's
% for margins smaller than 5%
% 3: Arizona; 20: Maine; 29: Nevada; 34: NC; 24: Minnesota; 10: Florida;
% 50: Wisconsin; 39: Pennsylvania; 
% 23: Michigan; 30: NH; 

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
    [next_rounds(i), ~, ~, ~]  = NextRoundSizes(margin, 0.1, 1.0, (0), (0), (1), (1), 0, 0, (0.9), 300000, 'Arlo');
    
    election_results.(states{i}).contests.presidential.Arlo_pv_raw = next_rounds(i);
	next_rounds_scaled(i) = ceil(factor*next_rounds(i));
	election_results.(states{i}).contests.presidential.Arlo_pv_scaled = next_rounds_scaled(i);
end

% Filip's arlo file
fname2='2016_one_round_arlo.json';
Arlo_rounds = jsondecode(fileread(fname2));
tests = fieldnames(Arlo_rounds);
for i=1:size(tests,1)
    fz(i) = Arlo_rounds.(tests{i}).expected.round_candidates;
end

% the states are not in the same order as the states file and rather than 
% bother, simply swap them around. Put Maine and Nebraska (Nevada?) in 
% their correct positions. 
fz_fixed = fz(:,[1:19, 50, 20:26, 51, 27:49]);

% Write Filip's Arlo values to our structure
for i=39
    election_results.(states{i}).contests.presidential.Arlo_fz = fz_fixed(i);
end

% Write all these into one file. 
txt = jsonencode(election_results);
fname3 = '2016_one_round_all.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

