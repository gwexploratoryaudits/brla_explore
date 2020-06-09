import random
from typing import List

class AuditSimulation:
    """ Simulates the audit, for the purposes of comparing the calculated risk to the
    simulated risk.

    Attributes
        total_ballots_cast (int): Total number of ballots cast in the contest.
        tally (int): The number of votes the reported winner has. Simulations of being
            risk-limited should use a worst-case tally (N / 2).
        round_schedule (List[int]): The List of cumulative round sizes.
        k_mins (List[int]): The List of stopping rules for the audit to be simulated.
        num_simulations (int): How many simulations should be performed. The larger this
        value, the more accurate the aggregated result.
        num_rounds: The number of rounds.
        simulated_stopping_probs (List[float]): The simulated stopping probabilities 
            for each round, cumulative.
        
    """

    total_ballots_cast: int
    tally: int
    round_schedule: List[int]
    k_mins: List[int]
    num_simulations: int
    num_rounds: int
    simulated_stopping_probs: List[float]

    def __init__(self, total_ballots_cast: int, tally: int, round_schedule: List[int],
                k_mins: List[int], num_simulations: int):

        self.total_ballots_cast = total_ballots_cast
        self.tally = tally
        self.round_schedule = round_schedule
        self.k_mins = k_mins
        self.num_simulations = num_simulations
        self.num_rounds = len(round_schedule)
        self.simulated_stopping_probs = [0] * self.num_rounds

    def conduct_simulations(self):
        """ Conducts the simulations and populates simulated_stopping_probs.
        """

        p = self.tally / self.total_ballots_cast

        stops = [0] * self.num_rounds

        for i in range(0, self.num_simulations):

            rw_ballots = 0
            
            for j in range(0, self.num_rounds):
                
                if j == 0:
                    ballots_to_draw = self.round_schedule[j]
                else:
                    ballots_to_draw = self.round_schedule[j] - self.round_schedule[j-1]
                
                rw_ballots_needed = self.k_mins[j]

                for draw in range(0, ballots_to_draw):
                    if random.random() < p:
                        rw_ballots += 1
                
                if rw_ballots >= rw_ballots_needed:
                    stops[j] += 1
                    break
        
        # Make stops empirical cumulative probabilities; populate stopping probabilities
        # array.
        for i in range(1, self.num_rounds):
            stops[i] += stops[i-1]
        for i in range(0, self.num_rounds):
            self.simulated_stopping_probs[i] = stops[i] / self.num_simulations
        print(self.simulated_stopping_probs)







    