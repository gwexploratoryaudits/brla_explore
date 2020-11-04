% First round size using binary search 
% For the moment, only margin >= 0.05%

%---Read Presidential data. Need margin, which is not in simulation output
% file. 
fname='2016_one_round_all.json';
election_results = loadjson(fileread(fname));
states = fieldnames(election_results);

%---Risk Limit, minimum margin and Audit
alpha = 0.2;
% doing only for 1% or larger margins right now
margin_min = 0.005;
audit_method = 'Minerva';
audit_method_B = 'EoR';

for i=1:size(states,1)
    margin = abs(election_results.(states{i}).contests.presidential.margin);
    margin_many(i) = margin;
    if (margin > margin_min)
        second_round.(states{i}).margin = margin;
        call_first_round_estimates
        % Write round sizes
        second_round.(states{i}).round_sizes_Minerva_EoR = [next_round_size, next_round_size_B];
        next_round_many(i) = next_round_size;
        next_round_B_many(i) = next_round_size_B;
        second_round.(states{i}).second_round_sizes_factor = next_round_size_B/next_round_size;
        % kmins
        %second_round.(states{i}).kmins_Minerva = [kmin, next_round_kmin];  
        %second_round.(states{i}).kmins_EoR = [kmin_B, next_round_kmin_B];
        % Probabilities
        second_round.(states{i}).stop_prob_Minerva = next_round_sprob;
        second_round.(states{i}).stop_prob_EoR = next_round_sprob_B;
        %second_round.(states{i}).cumulative_stop_prob_Minerva = ...
            %[StopSched(1,1),StopSched(1,1)+(1-StopSched(1,1))*next_round_sprob];
        %second_round.(states{i}).cumulative_stop_prob_EoR = ...
            %[StopSched_B(1,1),StopSched_B(1,1)+(1-StopSched_B(1,1))*next_round_sprob_B];
    end
end

% For graphs etc.
next_round_many = next_round_many(margin_many > margin_min);
next_round_B_many = next_round_B_many(margin_many > margin_min);
margin_many = margin_many(margin_many > margin_min);
factor = next_round_B_many./next_round_many;

% Write this back into a new file
fname2='pred_both_first_rounds_90_20.json';
txt = savejson(second_round);
fid = fopen(fname2, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);