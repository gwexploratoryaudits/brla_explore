# Grant McClearn
# Last Edited: August 28, 2019

''' This program, given the parameters of an audit, simulates that audit (many times) and reports
    the simulated risk--the proportion of times the audit failed to proceed to a full hand count.

    Please note: if you have a very large number of rounds, 
    you may have to change your maximum recursion depth (to the number of rounds)
    when using this program. Recursion is employed because each round needs a loop
    (to draw however many ballots), yet the number of rounds is variable. '''

import random

class Audit_Simulation:
    def __init__(self, N, round_schedule, k_mins, num_simulations):
        ''' Overarching parameters '''
        self.N = N
        self.round_schedule = round_schedule
        self.k_mins = k_mins
        
        self.m = len(round_schedule)

        self.num_simulations = num_simulations
        self.num_failed = 0

        ''' Per individual simulation parameters '''
        self.unaudited_total = N
        self.unaudited_loser = int(N / 2)

        self.audited_total = 0
        self.audited_loser = 0

    def examine_ballot(self):
        random_ballot = random_ballot = random.randrange(self.unaudited_total)
        # of the unaudited ballots, ballots in [0, unaudited_loser - 1] are for the loser, otherwise for the winner
        if (random_ballot < self.unaudited_loser):
            self.unaudited_loser = self.unaudited_loser - 1
            self.unaudited_total = self.unaudited_total - 1

            self.audited_total = self.audited_total + 1
            self.audited_loser = self.audited_loser + 1
        else:
            self.unaudited_total = self.unaudited_total - 1

            self.audited_total = self.audited_total + 1

    def simulate_round(self, round_num):
        # when no more rounds are left
        if round_num > self.m:
            return
        # If we draw more ballots for the reported winner than the k_min, increment num_failed.
        # Otherwise proceed to the next round.
        if round_num == 1:
            for ballot_draw in range(self.round_schedule[0]):
                self.examine_ballot()
            if (self.audited_total - self.audited_loser >= self.k_mins[0]):
                self.num_failed += 1
                return
            else:
                self.simulate_round(round_num + 1)
        else:
            for ballot_draw in range(self.round_schedule[round_num - 1] - self.round_schedule[round_num - 2]):
                self.examine_ballot()
            if (self.audited_total - self.audited_loser >= self.k_mins[round_num - 1]):
                self.num_failed += 1
                return
            else:
                self.simulate_round(round_num + 1)

    def conduct_simulation(self):
        if (len(self.round_schedule) != len(self.k_mins)):
            print("Schedule mismatch")

        for sim in range(self.num_simulations):
            # Reset the variables that vary simulation-by-simulation.
            self.simulate_round(1)
            self.unaudited_total = self.N
            self.unaudited_loser = int(self.N / 2)

            self.audited_total = 0
            self.audited_loser = 0
        print("Simulated risk limit:", float(self.num_failed) / self.num_simulations)

def main():
    auditsim = Audit_Simulation(100000, [200, 400, 800, 1600, 3200], [117, 223, 431, 843, 1661], 10000)
    auditsim.conduct_simulation()

if __name__ == '__main__':
    main()