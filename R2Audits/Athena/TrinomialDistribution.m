function final_prob = TrinomialDistribution(winner_fraction, loser_fraction, irrelevant_fraction, ... 
winner_ballots, loser_ballots, irrelevant_ballots, total_ballots)

    prob = (winner_fraction^winner_ballots)*(loser_fraction^loser_ballots)*(irrelevant_fraction^irrelevant_ballots);
    num_orderings = factorial(total_ballots) / ((factorial(winner_ballots))*(factorial(loser_ballots))*(factorial(irrelevant_ballots)));
    final_prob = prob * num_orderings;

end