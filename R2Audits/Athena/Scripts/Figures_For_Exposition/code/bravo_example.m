% script to generate a graph that shows the two approaches to R2 Bravo
% using B2 rules. 
%
%---
% Required input is
%       x: winner fraction
%       n1: size of each draw
%       alpha: risk limit
%---

%----Input
p = 0.75; % Announced winner fraction
n1 = 20; % Ballots drawn in each round
alpha = 0.1; % risk limit

%----Computations
margin = 2*p-1;

% For bravo kmin. 
% Function outputs slope and intercept of straight line kmin as a 
% function of round size n. Both kmin and n are vectors, such that 
% kmin(j) is the kmin value for n(j). The kmin value for a particular 
% value of n, say n*, is: kmin(n == n*). The vectors go upto a maximum 
% round size of 6*ASN. They begin at the smallest round size for which a
% decision to stop has non-zero probability. 
[kmslope, kmintercept, n, kmin] = B2BRAVOkmin(margin, alpha);

% Flag to check if condition is met at the end of round
end_of_round_condition = false;

% Maximum number of rounds hard-coded
max_rounds = 5;

% Simulate a random sequence one round at a time, stopping when 
% too many rounds or condition satisfied at end of round. Monitor 
% ordered-ballot-draw condition as well. 
ballot_draw_condition = false;

% Initialize round counter
round_counter = 0;

% Initialize random sequence
x = [];
k = [];

while(round_counter < 5 && end_of_round_condition == false)
    for i=1:n1
        x = [x,binornd(1, p)];
        n_sample = size(x,2); % number of ballots drawn so far 
        k(n_sample) = sum(x); % number of winner votes
        % check ordered ballot condition at every draw
        if k(n_sample) >= kmin(n==n_sample)
            if ballot_draw_condition == false
                ballot_draw_condition = true;
                ballot_draw_size = (round_counter+1)*n1;
            end
        end
    end
    %check end_of_round condition at end of round
    if k(n_sample) >= kmin(n==n_sample) 
            end_of_round_condition = true;
            end_of_round_size = n_sample;
    end
    round_counter = round_counter + 1;
end
if end_of_round_condition == false
    end_of_round_size = n_sample;
end
if ballot_draw_condition == false
    ballot_draw_size = n_sample;
end

stop_at = find(n==n_sample); % Last sample

%----Plot
plot(n(1:stop_at), kmin(1:stop_at), '-', 'Color', [0.6 0 0], 'LineWidth', 3)
hold
plot((1:ballot_draw_size), k(1:ballot_draw_size), 's', ...
    'Color', [0 0 0.6], 'LineWidth', 2, 'MarkerSize', 10)
plot((n1:n1:end_of_round_size), k(n1:n1:end_of_round_size), 'kx', ...
    'LineWidth', 2, 'MarkerSize', 10)
xlabel('Sample Size', 'FontSize', 14)
ylabel('Winner Ballots in Sample', 'FontSize', 14)
title('Testing the BRAVO stopping condition', 'FontSize', 16)
legend('kmin: minimum winner ballots required to stop', ...
    'Ordered-ballot-draws test', 'End-of-round test', 'FontSize', 12, ...
    'Location', 'NorthWest')

% If want to standardize LaTeX font
% Label axes and title
xlab = xlabel('Sample Size', 'Interpreter', 'latex');
xlab.FontSize = 18;
ylab = ylabel('Winner Ballots in Sample', 'Interpreter', 'latex');
ylab.FontSize = 18;

ti = title('Testing the BRAVO stopping condition', 'Interpreter', 'latex');
ti.FontSize = 20; 

leg = legend('kmin: minimum winner ballots required to stop', ...
    'Ordered-ballot-draws test', 'End-of-round test', ...
    'Interpreter', 'latex');
leg.FontSize = 16;
leg.Location = 'NorthWest';