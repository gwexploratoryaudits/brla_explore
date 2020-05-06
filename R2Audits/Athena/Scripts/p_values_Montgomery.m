% very basic script to compute Athena first round p-values for Montgomery
% County, Ohio, 2020 primary audit

% Input values

% Contests: valid values are 1-9
races = [1];
k_in = [10];
n_in = [14];

% 
% Read election results and first round predictions
fname='2020_montgomery_results.json';
election_results = jsondecode(fileread(fname));

contests = fieldnames(election_results);
% First four fields are global values for the election. 
% Next 9 fields are contests. 
% For each contest 

for i=1:size(races)
    % For each contest in races, find p-value
    [p_value, LR] = p_value(election_results.(contests{races(i)+4}).margin, ...
        (0), (0), (1), (1), n_in(i), k_in(i), 'Athena');
    election_results.(contests{races(i)+4}).test = [n_in(i), k_in(i)];
    election_results.(contests{races(i)+4}).p_value = p_value;
    election_results.(contests{races(i)+4}).LR = LR;
end

% Write election_results back into new file
txt = jsonencode(election_results);
fname3 = '2020_montgomery_test_pvalues.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

