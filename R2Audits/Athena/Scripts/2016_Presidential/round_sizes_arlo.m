% very basic script to compute Arlo first round values for the states, 2016
% also comparing to Filip's
% only for 5% or larger margins

% read Filip's file of the states
fname='2016_election.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
next_rounds = zeros(size(states,1), 1);
% n = zeros(size(states,1), 1500);
% kmin = n;
% Stopping_Arlo = n;

for i=1:size(states,1)
    total_ballots = election_results.(states{i}).contests.presidential.ballots_cast;
    total_relevant_ballots = sum(election_results.(states{i}).contests.presidential.results);
    margin = abs(election_results.(states{i}).contests.presidential.margin);
    
    % factor to scale raw values by to obtain approx round sizes
    factor = total_ballots/total_relevant_ballots;
    
    % doing only for 5% margins at the moment
    if (margin > 0.05)
        [next_rounds(i), ~, ~, ~]  = NextRoundSizes(margin, 0.1, 1.0, (0), (0), (1), (1), 0, 0, (0.9), 1500, 'Arlo');
        
        % if 1500 not large enough; we have found that 6000 is large enough
        if next_rounds(i) > 1500
            [next_rounds(i), ~, ~, ~]  = NextRoundSizes(margin, 0.1, 1.0, (0), (0), (1), (1), 0, 0, (0.9), 6000, 'Arlo');
        end
        
        election_results.(states{i}).contests.presidential.Arlo_pv_raw = next_rounds(i);
        next_rounds_scaled(i) = ceil(factor*next_rounds(i));
        election_results.(states{i}).contests.presidential.Arlo_pv_scaled = next_rounds_scaled(i);
    end
end

% Filip's arlo file
fname2='2016_one_round_arlo.json';
Arlo_rounds = jsondecode(fileread(fname2));
tests = fieldnames(Arlo_rounds);
for i=1:size(tests,1)
    fz(i) = Arlo_rounds.(tests{i}).expected.round_candidates
end

% the states are not in the same order as the states file and rather than 
% bother, simply swap them around. Put Maine and Nebraska (Nevada?) in 
% their correct positions. 
fz_fixed = fz(:,[1:19, 50, 20:26, 51, 27:49]);

% Write Filip's Arlo values to our structure
for i=1:size(tests,1)
    election_results.(states{i}).contests.presidential.Arlo_fz = fz_fixed(i);
end

% Write all these into one file. 
txt = jsonencode(election_results);
fname3 = '2016_one_round_all.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

