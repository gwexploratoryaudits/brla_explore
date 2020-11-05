% Second round size using binary search without knowledge of 
% winner ballots drawn, for both EoR and Minerva. 
% For the moment, only margin >= 1%

%---Read Presidential data. Need margin, which is not in simulation output
% file. 
% fname='2016_one_round_all.json';
% election_results = loadjson(fileread(fname));
% states = fieldnames(election_results);

%---Read first round data. 
fname_first='pred_both_first_rounds_90_20.json';
first_round = loadjson(fileread(fname_first));
states = fieldnames(first_round.second_round);
FirstRound = first_round.second_round;

%---Risk Limit, minimum margin and Audit
alpha = 0.2;
% doing only for 2% or larger margins right now
margin_min = 0.1;
audit_method = 'Minerva';
audit_method_B = 'EoR';

for i=1:size(states,1)
    margin = abs(FirstRound.(states{i}).margin);
    margin_many(i) = margin;
    if (margin > margin_min)
        second_round_90_20.(states{i}).margin = margin;
        % First write raw first round sizes
        n_in = FirstRound.(states{i}).round_sizes_Minerva_EoR(1);
        n_in_B = FirstRound.(states{i}).round_sizes_Minerva_EoR(2);
        n_in_many(i) = n_in;
        n_in_B_many(i) = n_in_B;
        % Now compute second round sizes. 
        call_first_round_averages
        % Write round sizes
        second_round_90_20.(states{i}).round_sizes_Minerva = [n_in, next_round_size];
        second_round_90_20.(states{i}).round_sizes_EoR = [n_in_B, next_round_size_B];
        next_round_many(i) = next_round_size;
        next_round_B_many(i) = next_round_size_B;
        second_round_90_20.(states{i}).second_round_sizes_factor_Minerva = next_round_size/n_in;
        second_round_90_20.(states{i}).second_round_sizes_factor_EoR = next_round_size_B/n_in_B;
        second_round_90_20.(states{i}).second_round_size_factor_incremental = ...
            (next_round_size_B-n_in_B)/(next_round_size-n_in);
        second_round_90_20.(states{i}).average_round_size_Minerva = ...
            StopSched(1,1)*n_in +(1-StopSched(1,1))*next_round_size; 
        average_many(i) = StopSched(1,1)*n_in +(1-StopSched(1,1))*next_round_size; 
        second_round_90_20.(states{i}).average_round_size_EoR = ...
            StopSched_B(1,1)*n_in_B +(1-StopSched_B(1,1))*next_round_size_B;
        average_B_many(i) = StopSched_B(1,1)*n_in_B +(1-StopSched_B(1,1))*next_round_size_B;
        second_round_90_20.(states{i}).average_round_size_factor = ...
            (StopSched_B(1,1)*n_in_B ...
            +(1-StopSched_B(1,1))*next_round_size_B)/(StopSched(1,1)*n_in ...
            +(1-StopSched(1,1))*next_round_size);
        % kmins
        %second_round.(states{i}).kmins_Minerva = [kmin, next_round_kmin];  
        %second_round.(states{i}).kmins_EoR = [kmin_B, next_round_kmin_B];
        % Probabilities
        %second_round.(states{i}).stop_prob_Minerva = [StopSched(1,1),next_round_sprob];
        %second_round.(states{i}).stop_prob_EoR = [StopSched_B(1,1),next_round_sprob_B];
        %second_round.(states{i}).cumulative_stop_prob_Minerva = ...
            %[StopSched(1,1),StopSched(1,1)+(1-StopSched(1,1))*next_round_sprob];
        %second_round.(states{i}).cumulative_stop_prob_EoR = ...
            %[StopSched_B(1,1),StopSched_B(1,1)+(1-StopSched_B(1,1))*next_round_sprob_B];
    end
end

% For graphs etc.
n_in_many = n_in_many(margin_many > margin_min);
n_in_B_many = n_in_B_many(margin_many > margin_min);
next_round_many = next_round_many(margin_many > margin_min);
next_round_B_many = next_round_B_many(margin_many > margin_min);
average_many = average_many(margin_many > margin_min);
average_B_many = average_B_many(margin_many > margin_min);
margin_many = margin_many(margin_many > margin_min);
Minerva_factor = next_round_many./n_in_many;
ratio_of_average = average_B_many./average_many;

% Write this back into a new file
fname2='pred_both_next_rounds_90_20.json';
txt = savejson(second_round_90_20);
fid = fopen(fname2, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);