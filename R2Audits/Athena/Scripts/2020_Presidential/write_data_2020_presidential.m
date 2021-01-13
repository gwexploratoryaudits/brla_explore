% MIT Election data csv file to json

% read 2020 data
A = readmatrix('2020-president-only-votes');

% read 2016 data file, with candidate names modified
fname_2016='2016_election.json';
election_results_20 = jsondecode(fileread(fname_2016));
states = fieldnames(election_results_20);

% modify structure using 2020 data
for i=1:size(states,1)
    election_results_20.(states{i}).contests.presidential.ballots_cast = A(2*i,2);
    election_results_20.(states{i}).contests.presidential.candidates = [{'Biden'}, {'Trump'}];
    election_results_20.(states{i}).contests.presidential.results = [A(2*i-1, 1), A(2*i,1)];
    total_relevant_ballots = sum(election_results_20.(states{i}).contests.presidential.results);
    margin = (A(2*i-1,1) - A(2*i,1))/(A(2*i-1,1) + A(2*i,1));
    election_results_20.(states{i}).contests.presidential.margin = margin;
end

% write structure into 2020 file
fname_2020='2020_election.json';
txt = savejson('',election_results_20);
fid = fopen(fname_2020, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);