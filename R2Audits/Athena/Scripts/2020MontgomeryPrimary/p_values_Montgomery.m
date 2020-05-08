% very basic script to compute Athena first round p-values for Montgomery
% County, Ohio, 2020 primary audit

% Input values
num_tests = 27;
alpha = 0.1;
delta = 1; %default

% Values below are chosen to be max round sizes for 0.9 percentiles, and
% kmin+1, kmin, kmin-1
n_in = [17, 17, 17, 42, 42, 42, 17, 17, 17, 49, 49, 49, 19, 19, 19, ...
    9, 9, 9, 33, 33, 33, 33, 33, 33, 86, 86, 86];

k_in = [13, 12, 11, 27, 26, 25, 13, 12, 11, 31, 30, 29, 14, 13, 12, ...
    8, 7, 6, 22, 21, 20, 22, 21, 20, 51, 50, 49];

% 
% Read election results and first round predictions
fname = '2020_montgomery_formatted_computations.json';
election_computations = loadjson(fileread(fname));

% % Read first tests, simply for writing into file. 
fname = '2020_montgomery_tests.json';
testing = loadjson(fileread(fname));

races = fieldnames(election_computations.contests);

for j=1:num_tests
    % Find p-value, contest number is ceil(j/3)
    i = ceil(j/3);
    
    % Generate winning vote distributions for each hypothesis
    margin = election_computations.contests.(races{i}).info.margin;
    CurrentTierStop = R2CurrentTier(margin,(1),n_in(j));
    CurrentTierRisk = R2CurrentTier(0,(1),n_in(j));
    
    %Compute p value
    [pvalue, LR] = p_value(margin, (0), (0), CurrentTierStop, ...
        CurrentTierRisk, n_in(j), k_in(j), 'Athena');
    dvalue = 1/LR;
    
    % Write into test structure
    testing.evaluate_risk.(sprintf('test%d',j)).audit_type = 'athena';
    testing.evaluate_risk.(sprintf('test%d',j)).election = election_computations.name;
    testing.evaluate_risk.(sprintf('test%d',j)).contest = races{i};
    testing.evaluate_risk.(sprintf('test%d',j)).alpha = alpha; 
    testing.evaluate_risk.(sprintf('test%d',j)).round_schedule = n_in(j)*ones(1); 
    testing.evaluate_risk.(sprintf('test%d',j)).audit_observations = k_in(j)*ones(1); 
    testing.evaluate_risk.(sprintf('test%d',j)).expected.passed = int8((pvalue <= alpha) && (dvalue <= delta)); 
    testing.evaluate_risk.(sprintf('test%d',j)).expected.pvalue = pvalue; 
    testing.evaluate_risk.(sprintf('test%d',j)).expected.delta = dvalue; 
end

% Write tests back into testing file
txt = savejson('',testing);
fname3 = '2020_montgomery_tests.json';
fid = fopen(fname3, 'w');
if fid == -1, error('Cannot create JSON file'); end
fwrite(fid,txt,'char');
fclose(fid);

