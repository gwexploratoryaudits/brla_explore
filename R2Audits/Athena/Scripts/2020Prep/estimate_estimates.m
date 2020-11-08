% To generate estimates of first round using gaussian approximations 
% for margins 1% and smaller. 

%---Read Presidential data. Need margin. 
fname='2016_one_round_all.json';
election_results = loadjson(fileread(fname));
states = fieldnames(election_results);

%---Risk Limit and Audit
alpha = 0.1;
percentiles = [0.7, 0.8, 0.9];

for i=1:size(states,1)
    margin = abs(election_results.(states{i}).contests.presidential.margin);
    % doing only for 1% or smaller margins right now
    margin_min = 0.01;
    if (margin <= margin_min)
        estimate.(states{i}).margin = margin;
        margin_many(i) = margin;
        for j=1:size(percentiles,2)
            next_round(i) = estimate_first_round_Minerva(margin, alpha, percentiles(j));
            estimate.(states{i}).n_est = next_round(i);
        end
    end
end

margin_many = margin_many((margin_many < margin_min) & (margin_many > 0));
% Write this back into a new file
fname2='estimate_estimates.json';
txt = savejson(estimate);
fid = fopen(fname2, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);