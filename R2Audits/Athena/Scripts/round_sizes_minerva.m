% very basic script to compute Athena first round values
fname='2016_one_round_all.json';
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
    if (margin > 0.05)
        [next_rounds(i), ~, ~, ~]  = NextRoundSizes(margin, 0.1, 1.0, (0), (0), (1), (1), 0, 0, (0.9), 1500, 'Minerva');
        
        % if 1500 not enough, 6000 we have found is
        if next_rounds(i) > 1500
            [next_rounds(i), ~, ~, ~]  = NextRoundSizes(margin, 0.1, 1.0, (0), (0), (1), (1), 0, 0, (0.9), 6000, 'Minerva');
        end
        
        election_results.(states{i}).contests.presidential.Minerva_pv_raw = next_rounds(i);
        
        % scale up
        next_rounds_scaled(i) = ceil(factor*next_rounds(i));
        election_results.(states{i}).contests.presidential.Minerva_pv_scaled = next_rounds_scaled(i);
    end
end

% Write this back into the same file
txt = jsonencode(election_results);
fid = fopen(fname, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

