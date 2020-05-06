% script to rewrite election for Montgomery County, Ohio, 2020 primary audit

% Read election results
fname='2020_montgomery.json';
election_results = jsondecode(fileread(fname));

% Delete fields 8, 12, 15 as contests are local and too many ballots 
% required. 
election_results = rmfield(election_results, 'd_39th');
election_results = rmfield(election_results, 'r_judge');
election_results = rmfield(election_results, 'r_43rd');

% Want to change the names
election_results = renameStructField(election_results, 'd_primary', 'd_president');
election_results = renameStructField(election_results, 'd_cc_feb', 'd_cc_1_2_2021');
election_results = renameStructField(election_results, 'd_cc_mar', 'd_cc_1_3_2021');
election_results = renameStructField(election_results, 'r_cc_feb', 'r_cc_1_2_2021');

contests = fieldnames(election_results);

% Change Write-Ins to Write_Ins
election_results.(contests{5}).candidates{11} = 'Write_Ins';

% First four fields are global values for the election. 
% Next 9 fields are contests. 
% For each contest 

% New structure modelled on 
% https://github.com/gwexploratoryaudits/r2b2/blob/master/src/r2b2/tests/election_template.json

new_election_results.name = 'montgomery_primary_2020';
new_election_results.total_ballots = election_results.total_ballots;


for i=1:size(contests)-4
    votes = election_results.(contests{i+4}).votes;
    new_election_results.contests.(contests{i+4}).contest_ballots = sum(votes);
    candidates = election_results.(contests{i+4}).candidates;
    for j=1:size(candidates)
        new_election_results.contests.(contests{i+4}).tally.(candidates{j}) = votes(j);
    end
    new_election_results.contests.(contests{i+4}).num_winners = 1;
    
    % Find max votes
    [votes_max, r] = max(votes);
    new_election_results.contests.(contests{i+4}).reported_winners = election_results.(contests{i+4}).candidates(r);
    new_election_results.contests.(contests{i+4}).contest_type = 'PLURALITY';
    
end

% Write election_results back into new file
%txt = jsonencode(election_results);
txt = savejson(new_election_results);
fname3 = '2020_montgomery_formatted.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);
