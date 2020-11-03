% To check against simulator first round output and to generate data for 
% second round size using binary search with and without knowldege of 
% winner ballots drawn. 
% For the moment, only margin >= 10%

%---Read Presidential data. Need margin, which is not in simulation output
% file. 
fname='2016_one_round_all.json';
election_results = loadjson(fileread(fname));
states = fieldnames(election_results);

%---Risk Limit and Audit
alpha = 0.1;
audit_method = 'Minerva';
audit_method_B = 'EoR';

for i=1:size(states,1)
    margin = abs(election_results.(states{i}).contests.presidential.margin);
    % doing only for 20% or larger margins right now
    if (margin > 0.1)
        data_check.(states{i}).margin = margin;
        % First write raw first round sizes
        n_in = election_results.(states{i}).contests.presidential.Athena_pv_raw;
        n_in_B = election_results.(states{i}).contests.presidential.Arlo_pv_raw;
        % Now compute second round sizes. 
        call_first_round_averages
        data_check.(states{i}).round_sizes_Minerva = [n_in, next_round_size];
        data_check.(states{i}).round_sizes_EoR = [n_in_B, next_round_size_B];
        data_check.(states{i}).round_sizes_factor_Minerva = next_round_size/n_in;
        data_check.(states{i}).round_sizes_factor_EoR = next_round_size_B/n_in_B;
        data_check.(states{i}).kmins_Minerva = [kmin, next_round_kmin];  
        data_check.(states{i}).kmins_EoR = [kmin_B, next_round_kmin_B];  
        data_check.(states{i}).stop_prob_Minerva = [StopSched(1,1),next_round_sprob];
        data_check.(states{i}).stop_prob_EoR = [StopSched_B(1,1),next_round_sprob_B];
        data_check.(states{i}).cumulative_stop_prob_Minerva = [StopSched(1,1),StopSched(1,1)+(1-StopSched(1,1))*next_round_sprob];
        data_check.(states{i}).cumulative_stop_prob_EoR = [StopSched_B(1,1),StopSched_B(1,1)+(1-StopSched_B(1,1))*next_round_sprob_B];
    end
end

% Write this back into a new file
fname2='pred_both_next_rounds.json';
txt = savejson(data_check);
fid = fopen(fname2, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);