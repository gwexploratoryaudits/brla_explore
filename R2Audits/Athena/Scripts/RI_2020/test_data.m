% Test Oliver's data 
% For the moment, only margin = 25% 

%---Read data. 
fname='minerva2_data_10.json';
audit_results = loadjson(fileread(fname));

%---Large enough margin
margin_min = 0.25;

error_data(1).expt_no = 0;
k=1; % For chosen audits
m=1; % For errors

for i=31:40
    %for i=1:size(audit_results.results,2)
    margin = audit_results.results{i}.margin;
    if (margin >= margin_min)
        %--- Read audit parameters
        alpha = audit_results.results{i}.risk_limit;
        no_rounds = audit_results.results{i}.rounds;

        %--- Initialize
        currently_drawn_ballots = 0;
        current_k = 0;
        current_sigma = 1;
        next_draws = zeros(1,no_rounds);
        next_rounds = next_draws;
        tail_ratio = next_draws;
        pvalue = next_draws;
        sigma = next_draws;
        LR = next_draws;

        %--- Next round size
        [next_draws(1), ~, ~, ~, ~]  = ...
            NextRoundSize(margin, alpha/current_sigma, [], (0), (0), ...
            (1), (1), 0, 0, (audit_results.results{i}.sprobs(1)), 500, 0.0001);
        next_rounds(1) = currently_drawn_ballots + next_draws(1); 

        % Check with Oliver's
        if abs(next_rounds(1) - ...
                        audit_results.results{i}.round_sizes(1)) ...
                        > next_rounds(1)/100
                    error_data(m).expt_no = i;
                    error_data(m).round_no = 1;
                    error_data(m).next_rounds_comp = next_rounds(1);
                    error_data(m).next_rounds_noted = ...
                        audit_results.results{i}.round_sizes(1);
                    m=m+1;
                end

        for j=1:no_rounds
            this_draw = audit_results.results{i}.round_sizes(j)-currently_drawn_ballots;
            this_k = audit_results.results{i}.samples.Alice(j)-current_k;
            CurrentTierStop = binopdf(0:this_draw,this_draw, 0.5*(1+margin));
            CurrentTierRisk = binopdf(0:this_draw,this_draw, 0.5);
            StopSched = (0);
            RiskSched = (0);

            % Compute tail and likelihood ratios (tail ratio is pvalue for 
            % first round Minerva; LR is inverse of Bravo pvalue for only 
            % this round)
            [tail_ratio(j), LR(j)] = p_value(margin, StopSched, ...
                RiskSched, CurrentTierStop, CurrentTierRisk, this_draw, ...
                this_k, 'Minerva');

            % Update for all rounds by multiplying both pvalues by the 
            % current (i.e. previous) value of sigma
            pvalue(j) = tail_ratio(j)*current_sigma;
            sigma(j) = current_sigma/LR(j);

            if abs(pvalue(j) -  audit_results.results{i}.risk(j)) > 0.0001
                error_data(m).expt_no = i;
                error_data(m).round_no = j;
                error_data(m).pvalue_comp = pvalue(j);
                error_data(m).pvalue_noted = audit_results.results{i}.risk(j);
                m=m+1;
            end
    
            currently_drawn_ballots = audit_results.results{i}.round_sizes(j);
            current_k = audit_results.results{i}.samples.Alice(j);
            current_sigma = sigma(j);

            if j == no_rounds
            else
                [next_draws(j+1), ~, ~, ~, ~]  = NextRoundSize(margin, ...
                    alpha/current_sigma, [], (0), (0), (1), (1), 0, 0, ...
                    (audit_results.results{i}.sprobs(j+1)), 500, 0.0001); 
                next_rounds(j+1) = next_draws(j+1) + currently_drawn_ballots;
                if abs(next_rounds(j+1) - ...
                        audit_results.results{i}.round_sizes(j+1)) ...
                        > next_rounds(j+1)/100
                    error_data(m).expt_no = i;
                    error_data(m).round_no = j+1;
                    error_data(m).next_rounds_comp = next_rounds(j+1);
                    error_data(m).next_rounds_noted = ...
                        audit_results.results{i}.round_sizes(j+1);
                    m=m+1;
                end
            end
        end
        audit_check{k}.expt_no = i;
        audit_check{k}.pvalue = pvalue;
        audit_check{k}.sigma = sigma;
        audit_check{k}.next_draws = next_draws;
        audit_check{k}.next_rounds = next_rounds;
        k = k+1;
    end
end

% Write checks into a new file
fname2='minerva2_check_data_10.json';
txt = savejson(audit_check);
fid = fopen(fname2, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

% Write errors into yet another file
fname2='minerva2_error_data_10.json';
txt = savejson(error_data);
fid = fopen(fname2, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);