% Computes Minerva and Bravo pvalues as a function of sample size
% using sample data from sampled_ccd.m
% Primary, Montgomery County, OH, 2020
% 2020_montgomery_official.json
%

    % Read election results
    fname = '2020_montgomery_official.json'; %CHOOSE
    election_computations = loadjson(fileread(fname));
    races = fieldnames(election_computations.contests);

    % Other parameters of choice
    race = 'd_cc_1_2_2021'; % CHOOSE
    alpha = 0.1; % CHOOSE
        
    % Read sample
    % Vote for each candidate, for each ballot in the sample, in the order 
    % of the random draw. 
    sampled_ccd; % CHOOSE
    
    % Read candidate list
    candidates = fieldnames(election_computations.contests.(race).tally);
    votes = zeros(size(candidates));
    
    % ----- PART I ---- Compute necessary properties -------
    for j=1:size(candidates,1)
        votes(j) = election_computations.contests.(race).tally.(candidates{j});
    end
    
    % Find max votes
    [votes_max, winner] = max(votes);

    % For each candidate, including winner, compute margin
    relevant_ballots = votes_max + votes;
    margin = (votes_max-votes)./relevant_ballots;
    
    % list of all losing candidate (numbers)
    losers = (1:size(candidates,1)); 
    losers(winner) = []; % delete the winner
    
    cumulative_sample = zeros(size(sample));
   
    % Compute number of ballots for each candidate after each draw
    for i=1:size(sample,1)
        cumulative_sample(i, 1:size(sample,2)) = sum(sample(1:i,1:size(sample,2)));
    end
    
    
    % Strip out winner
    winner_sample = cumulative_sample(:,winner);
    cumulative_sample_t = transpose(cumulative_sample);
    cumulative_sample_t(winner, :) = [];
    loser_sample = transpose(cumulative_sample_t);
    
    % Initialize p-values, each candidate each round
    p_minerva = zeros(size(loser_sample)); 
    p_sb = p_minerva;
    p_eor = p_minerva;
    
    % Initialize overall pvalue for round, maximum over all candidates
    p_max_minerva = ones(1,size(loser_sample,2));
    p_max_sb = p_max_minerva;
    p_max_eor = p_max_minerva;
    
    % For each draw, represented by cumulative_sample i, compute new p-value(s)
    i=1; % All p-values to be computed
    k = winner_sample(i);
	for j=1:size(loser_sample,2) % for each loser
        n = loser_sample(i,j) + k;
        margin_sample = margin(losers(j));
        if n==0
            p_eor(i,j) = 1;
            p_sb(i,j) = 1;
            p_minerva(i,j) = 1;
        else
            p_eor(i,j) = 1/(exp(log(1+margin_sample)*k + log(1-margin_sample)*(n-k)));
            p_sb(i,j) = min(p_eor(1:i,j));
            p_minerva(i,j) = sum(binopdf(k:n,n,0.5))/sum(binopdf(k:n,n,(1+margin_sample)/2));
        end
	end
    
    p_max_minerva(i) = max(p_minerva(i, :));
    p_max_eor(i) = max(p_eor(i, :));
    p_max_sb(i) = max(p_sb(i, :));
    
	for i=2:size(cumulative_sample, 1)
        % First copy p-values from previous round; then change only those
        % that have changed
        p_minerva(i, :) = p_minerva(i-1,:);
        p_sb(i, :) = p_sb(i-1,:);
        p_eor(i, :) = p_eor(i-1,:);
        
        if(winner_sample(i) > winner_sample(i-1)) 
            % latest ballot was for winner, change all p-values
            k = winner_sample(i);
            for j=1:size(loser_sample,2) % for each loser
                n = loser_sample(i,j) + k;
                margin_sample = margin(losers(j)); 
                p_eor(i,j) = 1/(exp(log(1+margin_sample)*k + log(1-margin_sample)*(n-k)));
                p_sb(i,j) = min(p_eor(1:i,j));
                p_minerva(i,j) = sum(binopdf(k:n,n,0.5))/sum(binopdf(k:n,n,(1+margin_sample)/2));
            end
        elseif(loser_sample(i,j) > loser_sample(i-1,j)) 
                % change set of p-values
                n = loser_sample(i,j) + k; %k is from previous round, fine
                margin_sample = margin(losers(j)); 
                p_eor(i,j) = 1/(exp(log(1+margin_sample)*k + log(1-margin_sample)*(n-k)));
                p_sb(i,j) = min(p_eor(1:i,j));
                p_minerva(i,j) = sum(binopdf(k:n,n,0.5))/sum(binopdf(k:n,n,(1+margin_sample)/2));
        end % if no relevant new ballot, no problem
        % p value for ith draw is the max among p values for all candidates
        p_max_minerva(i) = max(p_minerva(i, :));
        p_max_eor(i) = max(p_eor(i, :));
        p_max_sb(i) = max(p_sb(i, :));
    end 
    
% Plot
% Name colors
maroon = [0.5 0 0];
navy = [0 0 0.5];
dull_green = [0 0.3 0];
dull_orange = [0.8, 0.3, 0];

begin_from = 1;
end_at = 240;

% Bravo p-value 
first_plot = plot((begin_from:end_at), p_max_eor, 's-', ...
   'Color', navy);
hold

second_plot = plot((begin_from:end_at), p_max_sb, '*-', ...
   'Color', maroon);

third_plot = plot((begin_from:end_at), p_max_minerva, 'o-', ...
   'Color', dull_green);

% Draw horizontal line at 2 risk limits and label
yl1 = yline(alpha, ':', {sprintf('Risk limit = %1.1f', alpha)}, 'Interpreter', 'latex');
yl1.LineWidth=2;
yl1.FontSize=16;
yl1.LabelHorizontalAlignment='left';

yl2 = yline(alpha/2, ':', {sprintf('Risk limit = %1.2f', alpha/2)}, 'Interpreter', 'latex');
yl2.LineWidth=2;
yl2.FontSize=16;
yl2.LabelHorizontalAlignment='left';

ti = title('County Commissioner FTC 1-2-2021, Democrat', 'Interpreter', 'latex');
ti.FontSize = 20; 

% Legend
leg = legend(vertcat(first_plot, second_plot, third_plot), 'EoR p-value', ...
    'SB p-value', 'Minerva p-value', 'Interpreter', 'latex');
leg.Location = 'SouthWest'; 
leg.FontSize = 16;

axis([0, 100, 0.00, 0.125])

ax = gca;
ax.XAxis.FontSize = 14;
ax.YAxis.FontSize = 14;

% Label axes
xlab = xlabel('Number of ballots drawn', 'Interpreter', 'latex'); 
xlab.FontSize = 18;
ylab = ylabel('Computed p-value', 'Interpreter', 'latex');
ylab.FontSize = 18; 

values_point1 = [find(p_max_minerva <= 0.1, 1), find(p_max_sb <= 0.1, 1), find(p_max_eor <= 0.1, 1)]
values_point05 = [find(p_max_minerva <= 0.05, 1), find(p_max_sb <= 0.05, 1), find(p_max_eor <= 0.05, 1)]




