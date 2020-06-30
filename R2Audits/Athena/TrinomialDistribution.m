function final_prob = TrinomialDistribution(winner_fraction, loser_fraction, irrelevant_fraction, ... 
winner_ballots, loser_ballots, irrelevant_ballots)

    % Calculate the probability using the multinomial pdf
    X = [winner_ballots, loser_ballots, irrelevant_ballots];
    PROB = [winner_fraction, loser_fraction, irrelevant_fraction];
    final_prob = mnpdf(X,PROB);

end