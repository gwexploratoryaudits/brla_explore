function prob = TrinomialDistribution(winner_fraction, irrelevant_fraction, ... 
winner_ballots, loser_ballots, irrelevant_ballots, total_ballots)

    loser_fraction = 1 - winner_fraction - irrelevant_fraction;
    prob = (winner_fraction^(winner_ballots))*(loser_fraction^(loser_ballots))*(irrelevant_fraction^(irrelevant_ballots));
    num_orderings = (factorial(total_ballots)) / ((factorial(winner_ballots))*(factorial(loser_ballots))*(factorial(irrelevant_ballots)));
    prob = prob * num_orderings;

end