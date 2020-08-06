% Script that computes first round sizes using the new approach for 
% handling irrelevant ballots, but acts as though there are no
% irrelevant ballots in order to compare these numbers to the 
% Minerva_pv_raw numbers to make sure that the new approach code 
% is performing correctly. Just prints the results values to 
% a text file for examination.

% Read JSON file with states data
fname='../2016_One_round_all.json';
election_results = jsondecode(fileread(fname));
states = fieldnames(election_results);
next_rounds = zeros(size(states,1), 1);

fileID = fopen('results_no_irrelevant_ballots.txt','w');

max_draws = 600;
alpha = 0.1;
delta = 1;

for i=1:size(states,1)
    
    margin = abs(election_results.(states{i}).contests.presidential.margin);
    % Check that the absoluate value of the margin is greater than 0.12
    if (margin > 0.12)
        
        total_relevant_ballots = sum(election_results.(states{i}).contests.presidential.results);
        
        for j=1:size(candidates,1)
            CurrentTierStop{j} = (1);
        end
        CurrentTierRisk = CurrentTierStop;
        StopSched = zeros(size(candidates));
        RiskSched = StopSched;
        k_last = 0;
        n_last = 0;
        
        [n, kmin, Stopping] = StopProb_IrrelevantBallots(margin, alpha, delta, ...
            StopSched, RiskSched, CurrentTierStop, CurrentTierRisk, ... 
            n_last, k_last, max_draws, "Athena", 0)
        
        kValuemax = find(Stopping < 0.9);
        round_size = kValuemax(size(kValuemax,2))+1;
        
        fprintf(fileID, "State: %s\tMinerva_raw: %d\tIrrelevant_code: %d\n", states{i}, election_results.(states{i}).contests.presidential.Minerva_pv_raw, round_size);
        
    end
end

fclose(fileID);