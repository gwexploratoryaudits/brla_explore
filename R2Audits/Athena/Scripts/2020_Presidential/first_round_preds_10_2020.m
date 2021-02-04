% First round size using binary search 
% For the moment, only margin >= 1% which is all but 4 2020 states

%---Read Presidential data. 
fname='2020_election.json';
election_results = loadjson(fileread(fname));
states = fieldnames(election_results);

%---Risk Limit, minimum margin and Audit2
alpha = 0.1;
% doing only for 1% or larger margins right now
margin_min = 0.01;
audit_method = 'Minerva';
audit_method_B = 'EoR';

for i=1:size(states,1)
    margin = abs(election_results.(states{i}).contests.presidential.margin);
    margin_many(i) = margin;
    if (margin > margin_min)
        call_first_round_estimates
    else
        next_round_size = estimate_first_round_Minerva(margin, alpha, 0.9);
        [next_round_size_B, ~, next_round_sprob_B, ~, ~] = ...
            estimate_first_round_EoR(margin, alpha, 0.9);
    end
    % factor to scale up raw values
    total_ballots = ...
            election_results.(states{i}).contests.presidential.ballots_cast;
    total_relevant_ballots = ...
            sum(election_results.(states{i}).contests.presidential.results);
	factor = total_ballots/total_relevant_ballots;
	% Write round sizes
	election_results.(states{i}).round_sizes_Minerva_EoR = ...
            [next_round_size, next_round_size_B];
	election_results.(states{i}).round_sizes_Minerva_EoR_scaled = ...
            ceil(factor*[next_round_size, next_round_size_B]);
	next_round_many_scaled(i) = ceil(factor*next_round_size);
	next_round_B_many_scaled(i) = ceil(factor*next_round_size_B);
	election_results.(states{i}).round_sizes_factor = next_round_size_B/next_round_size;
	% Distinct Ballots
    distinct(i) = ceil(total_ballots*(1-((1-(1/total_ballots))^next_round_many_scaled(i))));
    distinct_B(i) = ceil(total_ballots*(1-((1-(1/total_ballots))^next_round_B_many_scaled(i))));
    election_results.(states{i}).distinct_Minerva_EoR = ...
            [distinct(i), distinct_B(i)];
	election_results.(states{i}).distinct_factor = distinct_B(i)/distinct(i);
    % Probabilities
    if (margin > margin_min)
        election_results.(states{i}).stop_prob_Minerva = next_round_sprob;
    end
	election_results.(states{i}).stop_prob_EoR = next_round_sprob_B;       
end

% For graphs etc.

% Uncomment below if only want exactly computed values. 
% next_round_many_scaled = next_round_many_scaled(margin_many > margin_min);
% next_round_B_many_scaled = next_round_B_many_scaled(margin_many > margin_min);
% margin_many = margin_many(margin_many > margin_min);
factor_many = next_round_B_many_scaled./next_round_many_scaled;
distinct_factor_many = distinct_B./distinct;

% Write this back into a new file
fname2='pred_both_first_rounds_10.json';
txt = savejson(election_results);
fid = fopen(fname2, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);