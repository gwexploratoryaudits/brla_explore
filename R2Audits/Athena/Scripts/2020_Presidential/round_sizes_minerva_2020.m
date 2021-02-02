% very basic script to compute Minerva first round values
% for the moment, only margin >= 5%
fname='2020_election.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
next_rounds = zeros(size(states,1), 1);

for i=1:size(states,1)
    total_ballots = election_results.(states{i}).contests.presidential.ballots_cast;
    total_relevant_ballots = sum(election_results.(states{i}).contests.presidential.results);
    margin = abs(election_results.(states{i}).contests.presidential.margin);
    
    % factor to scale up raw values
    factor = total_ballots/total_relevant_ballots;
    
    % doing only for 5% or larger margins right now
    if (margin > 0.01)
        [next_rounds(i), ~, ~, ~, ~]  = NextRoundSize(margin, 0.1, 1.0, (0), (0), (1), (1), 0, 0, (0.9), 10000, 0.0001);
        
        election_results.(states{i}).contests.presidential.Minerva_pv_raw = next_rounds(i);
        
        % scale up
        next_rounds_scaled(i) = ceil(factor*next_rounds(i));
        election_results.(states{i}).contests.presidential.Minerva_pv_scaled = next_rounds_scaled(i);
    end
end

% write structure into 2020 file
fname_2020='2020_election_minerva.json';
txt = savejson('',election_results);
fid = fopen(fname_2020, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);
