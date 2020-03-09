% very basic script to compute Arlo first round values for a single state
% also comparing to Filip's
% for margins smaller than 5%

% read Filip's file of the states
fname='2016_one_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
next_rounds = zeros(size(states,1), 1);

for i=3
    total_ballots = election_results.(states{i}).contests.presidential.ballots_cast;
    total_relevant_ballots = sum(election_results.(states{i}).contests.presidential.results);
    margin = abs(election_results.(states{i}).contests.presidential.margin);
    
    % factor to scale raw values by to obtain approx round sizes
    factor = total_ballots/total_relevant_ballots;
    [next_rounds(i), ~, ~, ~]  = NextRoundSizes(margin, 0.1, 1.0, (0), (0), (1), (1), 0, 0, (0.9), 10000, 'Arlo');
    % if 10000 not large enough; try 15000
    if next_rounds(i) >= 10000
        [next_rounds(i), ~, ~, ~]  = NextRoundSizes(margin, 0.1, 1.0, (0), (0), (1), (1), 0, 0, (0.9), 15000, 'Arlo');
    end
    election_results.(states{i}).contests.presidential.Arlo_pv_raw = next_rounds(i);
	next_rounds_scaled(i) = ceil(factor*next_rounds(i));
	election_results.(states{i}).contests.presidential.Arlo_pv_scaled = next_rounds_scaled(i);
end

% Filip's arlo file
fname2='2016_one_round_arlo.json';
Arlo_rounds = jsondecode(fileread(fname2));
tests = fieldnames(Arlo_rounds);
for i=3
    fz(i) = Arlo_rounds.(tests{i}).expected.round_candidates
end

% Write Filip's Arlo values to our structure
for i=3
    election_results.(states{i}).contests.presidential.Arlo_fz = fz(i);
end

% Write all these into one file. 
txt = jsonencode(election_results);
fname3 = '2016_one_round_all.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

