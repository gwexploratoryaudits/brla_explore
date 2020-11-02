% To check against simulator first round output and to generate data for 
% second round size using binary search
% for the moment, only margin >= 20%

%---Read Presidential data. Need margin, which is not in simulation output
% file. 
fname='2016_one_round_all.json';
election_results = loadjson(fileread(fname));
states = fieldnames(election_results);

%---Read simulation data
fname1='2016_pres_trials.json';
simulation_results = jsondecode(fileread(fname1));

%---Risk Limit and Audit
alpha = 0.1;
audit_method = 'Minerva';
count_pvalue_mismatch = 0; % number of mismatches of pvalue computed with simulation data. 
count_stop_mismatch = 0; % number of mismatches of stop computed with simulation data. 

for i=1:size(states,1)
    margin = abs(election_results.(states{i}).contests.presidential.margin);
    data_check.(states{i}).margin = margin;
    % doing only for 20% or larger margins right now
    if (margin > 0.1)
      for j=1:5
        n_in = simulation_results.(states{i}).underlying_reported_first_5(j).relevant_sample_size;
        k_all = simulation_results.(states{i}).underlying_reported_first_5(j).winner_ballots;
        call_first_round_trial
        data_check.(states{i}).underlying_reported_first_5(j).n = n_in;
        data_check.(states{i}).underlying_reported_first_5(j).k = k_all;
        data_check.(states{i}).underlying_reported_first_5(j).p_value = pvalue;
        data_check.(states{i}).underlying_reported_first_5(j).stop = stop;
        data_check.(states{i}).underlying_reported_first_5(j).kmin = kmin;
        data_check.(states{i}).underlying_reported_first_5(j).next_round_size = next_round_size;
        data_check.(states{i}).underlying_reported_first_5(j).next_round_kmin = next_round_kmin;    
        data_check.(states{i}).underlying_reported_first_5(j).next_round_sprob = next_round_sprob;   
        if abs(pvalue - simulation_results.(states{i}).underlying_reported_first_5(j).p_value) > 0.0001
            count_pvalue_mismatch = count_pvalue_mismatch + 1;
            pvalue_mismatch(count_pvalue_mismatch) = i;
        end
        if stop ~= simulation_results.(states{i}).underlying_reported_first_5(j).stop
            count_stop_mismatch = count_stop_mismatch + 1;
            stop_mismatch(count_stop_mismatch) = i;
        end
      end
      for j=1:5
        n_in = simulation_results.(states{i}).underlying_reported_not_stop_5(j).relevant_sample_size;
        k_all = simulation_results.(states{i}).underlying_reported_not_stop_5(j).winner_ballots;
        call_first_round_trial
        data_check.(states{i}).underlying_reported_not_stop_5(j).n = n_in;
        data_check.(states{i}).underlying_reported_not_stop_5(j).k = k_all;
        data_check.(states{i}).underlying_reported_not_stop_5(j).p_value = pvalue;
        data_check.(states{i}).underlying_reported_not_stop_5(j).stop = stop;
        data_check.(states{i}).underlying_reported_not_stop_5(j).kmin = kmin;
        data_check.(states{i}).underlying_reported_not_stop_5(j).next_round_size = next_round_size;
        data_check.(states{i}).underlying_reported_not_stop_5(j).next_round_kmin = next_round_kmin;    
        data_check.(states{i}).underlying_reported_not_stop_5(j).next_round_sprob = next_round_sprob;   
        if abs(pvalue - simulation_results.(states{i}).underlying_reported_not_stop_5(j).p_value) > 0.0001
            count_pvalue_mismatch = count_pvalue_mismatch + 1;
            pvalue_mismatch(count_pvalue_mismatch) = i;
        end
        if stop ~= simulation_results.(states{i}).underlying_reported_not_stop_5(j).stop
            count_stop_mismatch = count_stop_mismatch + 1;
            stop_mismatch(count_stop_mismatch) = i;
        end
      end
      for j=1:5
        n_in = simulation_results.(states{i}).underlying_tied_first_5(j).relevant_sample_size;
        k_all = simulation_results.(states{i}).underlying_tied_first_5(j).winner_ballots;
        call_first_round_trial
        data_check.(states{i}).underlying_tied_first_5(j).n = n_in;
        data_check.(states{i}).underlying_tied_first_5(j).k = k_all;
        data_check.(states{i}).underlying_tied_first_5(j).p_value = pvalue;
        data_check.(states{i}).underlying_tied_first_5(j).stop = stop;
        data_check.(states{i}).underlying_tied_first_5(j).kmin = kmin;
        data_check.(states{i}).underlying_tied_first_5(j).next_round_size = next_round_size;
        data_check.(states{i}).underlying_tied_first_5(j).next_round_kmin = next_round_kmin;    
        data_check.(states{i}).underlying_tied_first_5(j).next_round_sprob = next_round_sprob;   
        if abs(pvalue - simulation_results.(states{i}).underlying_tied_first_5(j).p_value) > 0.0001
            count_pvalue_mismatch = count_pvalue_mismatch + 1;
            pvalue_mismatch(count_pvalue_mismatch) = i;
        end
        if stop ~= simulation_results.(states{i}).underlying_tied_first_5(j).stop
            count_stop_mismatch = count_stop_mismatch + 1;
            stop_mismatch(count_stop_mismatch) = i;
        end
      end
    end
end

% Write this back into a new file
fname2='check_simulations.json';
txt = savejson(data_check);
fid = fopen(fname2, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);