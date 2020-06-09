# Grant McClearn
# Last Edited: August 28, 2019

''' A program which, given the number of ballots cast for two candidates in a two-candidate election,
    the round schedule, and the risk schedule, calculates k_mins and their associated errors. '''

from scipy.stats import hypergeom
''' The hypegeometric distribution is central to the computation of this audit. '''

def get_interval(dist):
    ''' This function aids in truncating distributions by finding levels l and u such that 
    cdf(l) < .0000001 and 1 - cdf(u) < .0000001. (Here, cdf is used somewhat loosely because 
    we do not require cdf(infinity) = 1,
    although the distribution should sum "close enough" to 1 because .0000001 is absolute, not relative 
    (i.e. a distribution that summed to .0000004 would result in only half the distribution 
    being between l and u). 
    
    The purpose of this is to improve efficiency, since, 
    for instance almost all of the hypergeometric distribution falls between a fraction of its range. 
    This decreases the time it takes to iterate over the (meaningful parts of) distributions. '''
    tolerance = .0000001
    length = len(dist)

    # Edge case: distribution too small.
    sum = 0
    for x in dist:
        sum += x
    if (sum < 2 * tolerance):
        return ([int(length/2 - 1), int(length/2 + 1)])

    lower_sum = 0
    lower_endpoint = 0
    for i in range(0, length):
        lower_sum += dist[i]

        # if adding the next value of the distribution would cause us to exceed the tolerance, 
        # break and return the lower level
        if (lower_sum + dist[i + 1] > tolerance):
            lower_endpoint = i
            break
    
    upper_sum = 0
    upper_endpoint = length
    for i in range(0, length):
        upper_sum += dist[length - i - 1]

        if (upper_sum + dist[length - i - 2] > tolerance):
            upper_endpoint = length - i - 1
            break
    
    endpoints = [lower_endpoint, upper_endpoint]
    return endpoints

class Convolution_Audit:

    def __init__(self, N, round_schedule, risk_schedule):
        ''' Inputted audit parameters '''
        # N = number of ballots cast for the two candidates (in a two candidate contest)
        self.N = N
        # The round schedule is a list of strictly increasing integers, each in [0, N],
        # such that after completion of the i'th round round_schedule[i] ballots will
        # have been examined.
        self.round_schedule = round_schedule
        # The risk schedule (also called the error distribution or the risk allottment function)
        # conveys how much risk each audit round gets to contribute to the overall risk.
        # The sum of the allotted_risk_schedule is the risk limit of the audit.
        self.allotted_risk_schedule = risk_schedule

        ''' Derived audit parameters '''
        self.half_N = int(N / 2)
        self.number_of_rounds = len(round_schedule)
        self.half_rounds = [int(round_size / 2) for round_size in round_schedule]
        # The i'th value of k_min is the stopping rule for the i'th round: if the auditor
        # received >= k_min ballots for the winner then the audit stops.
        self.k_mins = [0] * self.number_of_rounds
        # Due to the k_mins' being integers, each round will not use up exactly its allotted
        # amount of risk. This list keeps track of the true risk used up by each round.
        self.used_risk_schedule = [0] * self.number_of_rounds
    
    def conduct_audit(self):
        ''' The basic structure of the audit follows.
            (1) Compute the distribution of the number of ballots for the winner.
            (2) Based on right-tail probabilities, decide the satisfactory k_min.
            (3) Lop off the right-tail probability when proceeding to the next round,
                as those probabilities (since they result in the audit stopping) will
                not result in future errors.
        '''

        round_index = 0

        # first round (no previous_rounds_distribution yet exists)
        current_round_distribution = self.calculate_first_round_distribution()
        self.decide_k_min(round_index, current_round_distribution)
        previous_rounds_distribution = self.lop_off_distribution(round_index, current_round_distribution)

        # further rounds
        for round_index in range(1, self.number_of_rounds):
            current_round_distribution = self.calculate_further_round_distribution(round_index, previous_rounds_distribution)
            self.decide_k_min(round_index, current_round_distribution)
            previous_rounds_distribution = self.lop_off_distribution(round_index, current_round_distribution)
        
    def calculate_first_round_distribution(self):
        ''' We draw round_schedule[0] ballots from a total of N ballots, of which we assume half_N are for the reported winner
        (so that the audit is risk-limiting). Of that sample, anywhere from 0 to round_schedule ballots (inclusive) could 
        have been for the reported winner. '''

        # This functionality is in a different method than other rounds to emphasize that the fact that, by
        # virtue of it using no convolution, it is qualitatively different from later rounds.
        return hypergeom.pmf(range(0, self.round_schedule[0] + 1), self.N, self.half_N, self.round_schedule[0])
    
    def decide_k_min(self, round_index, current_round_distribution):
        # For each potential k_min...
        for potential_k_min in range(self.half_rounds[round_index], self.round_schedule[round_index] + 1):
            potential_k_min_error = 0

            # calculate the right tail probability...
            for k in range(potential_k_min, self.round_schedule[round_index] + 1):
                potential_k_min_error += current_round_distribution[k]

            # and if it is less than the allotted error we have found our k_min.
            if potential_k_min_error <= self.allotted_risk_schedule[round_index]:
                self.k_mins[round_index] = potential_k_min
                self.used_risk_schedule[round_index] = potential_k_min_error

                # Unused risk (due to k_min's being an integer) is donated to the next round, if there is a next round.
                if round_index + 1 < self.number_of_rounds:
                    leftover_error = self.allotted_risk_schedule[round_index] - self.used_risk_schedule[round_index]
                    self.allotted_risk_schedule[round_index + 1] += leftover_error
                break
        return

    def calculate_further_round_distribution(self, round_index, previous_rounds_distribution):
        # initializing a current_round_distribution
        current_round_distribution = [0] * (self.round_schedule[round_index] + 1)
        
        # improving efficiency at the expense of negligible accuracy
        previous_rounds_distribution_bounds = get_interval(previous_rounds_distribution)

        # For every possibility (of number of ballots for the winner) in the past rounds...
        for previous_rounds_possibility in range(previous_rounds_distribution_bounds[0], previous_rounds_distribution_bounds[1] + 1):
            winner_ballots = range(0, self.round_schedule[round_index] - self.round_schedule[round_index - 1] + 1)
            unsampled_N = self.N - self.round_schedule[round_index - 1]
            unsampled_winner_ballots = self.half_N - previous_rounds_possibility
            sample_size = self.round_schedule[round_index] - self.round_schedule[round_index - 1]

            # and every possibility in the current round...
            this_round_draws = hypergeom.pmf(winner_ballots, unsampled_N, unsampled_winner_ballots, sample_size)

            for this_round_possibility in winner_ballots:
                # we calculate the probability of their simultenaiety.
                
                # An example follows.
                # If we received 115 ballots for the winner in the previous rounds, 
                # and 113 in the current round, those probabilities
                # multiplied give one small component of the probability of having gotten 228 ballots for the winner in total.

                component_probability = previous_rounds_distribution[previous_rounds_possibility] * this_round_draws[this_round_possibility]
                current_round_distribution[previous_rounds_possibility + this_round_possibility] += component_probability
        return current_round_distribution

    def lop_off_distribution(self, round_index, current_round_distribution):
        # Removing probabilities which do not proceed to further audit rounds.
        for k in range(self.k_mins[round_index], self.round_schedule[round_index] + 1):
            current_round_distribution[k] = 0
        return current_round_distribution

    def get_precise_risk(self):
        risk = 0
        for round_risk in self.used_risk_schedule:
            risk += round_risk
        return risk

def main():
    N = 100000
    round_schedule = [200, 400, 800, 1600, 3200]
    # One should ensure that the sum of the values of the risk schedule is less than the desired risk limit.
    # This can be done using riskschedulemaker.py.
    risk_schedule = [.01] * 5
    audit = Convolution_Audit(N, round_schedule, risk_schedule)
    audit.conduct_audit()

    print(audit.k_mins)
    print(audit.get_precise_risk())

if __name__ == '__main__':
    main()