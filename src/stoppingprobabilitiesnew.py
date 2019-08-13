# Grant McClearn
# Last Edited: August 13, 2019

''' A program which calculates the probability of stopping at each audit round when provided
    the number of ballots cast for two candidates in a two candidate election, the round schedule,
    the k_mins, and a true tally.

    Crucially, if the true tally is set to a tie (or margin of 1 in favor of the reported loser) then the
    sum of the stopping probabilities is the risk limit of the provided set of k_mins! '''

from scipy.stats import hypergeom
''' The hypegeometric distribution is central to the computation of the stopping probabilities. '''

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

class Stopping_Probabilities:

    def __init__(self, N, round_schedule, k_mins, true_tally):
        ''' Inputted parameters '''
        # N = number of ballots cast for the two candidates (in a two candidate contest)
        self.N = N
        # The round schedule is a list of strictly increasing integers, each in [0, N],
        # such that after completion of the i'th round round_schedule[i] ballots will
        # have been examined.
        self.round_schedule = round_schedule
        # The i'th value of k_min is the stopping rule for the i'th round: if the auditor
        # received >= k_min ballots for the winner then the audit stops.
        self.k_mins = k_mins
        # The true tally of the election. Of course one does not know this, but using
        # the reported tally as a proxy is useful for optimization. If the true_tally
        # is set to a tie (or margin of 1 in favor of the reported loser) then the sum of the
        # stopping probabilities is the risk limit of an audit conducted with the
        # provided k_mins.
        self.true_tally = true_tally

        ''' Derived parameters '''
        self.number_of_rounds = len(round_schedule)
        # The i'th value of sprobs is the probability that the audit will stop at
        # (i.e., immediately after completion of) round i. (It is NOT cumulative.)
        self.sprobs = [0] * self.number_of_rounds

    def calculate_sprobs(self):
        ''' The basic structure of the calculation of stopping probabilities follows.
        (1) Compute the distribution of the number of ballots for the winner.
        (2) Find the right tail (bounded by the k_min) of the distribution. 
            This is the stopping probability.
        (3) Lop off the right-tail probability when proceeding to the next round,
            as those probabilities (since they result in the audit stopping) will
            not result in future errors. '''

        round_index = 0

        # first round (no previous_rounds_distribution yet exists)
        current_round_distribution = self.calculate_first_round_distribution()
        self.sprobs[round_index] = self.find_round_sprob(round_index, current_round_distribution)
        previous_rounds_distribution = self.lop_off_distribution(round_index, current_round_distribution)

        # further rounds
        for round_index in range(1, self.number_of_rounds):
            current_round_distribution = self.calculate_further_round_distribution(round_index, previous_rounds_distribution)
            self.sprobs[round_index] = self.find_round_sprob(round_index, current_round_distribution)
            previous_rounds_distribution = self.lop_off_distribution(round_index, current_round_distribution)

    def calculate_first_round_distribution(self):
        ''' We draw round_schedule[0] ballots from a total of N ballots, of which we assume half_N are for the reported winner
        (so that the audit is risk-limiting). Of that sample, anywhere from 0 to round_schedule ballots (inclusive) could 
        have been for the reported winner. '''

        # This functionality is in a different method than other rounds to emphasize that the fact that, by
        # virtue of it using no convolution, it is qualitatively different from later rounds.
        return hypergeom.pmf(range(0, self.round_schedule[0] + 1), self.N, self.true_tally, self.round_schedule[0])

    def find_round_sprob(self, round_index, current_round_distribution):
        ''' Find the right tail probability (where the left boundary is the k_min) of an audit round.
            This is the stopping probability for that round. '''
        round_sprob = 0
        for k in range(self.k_mins[round_index], self.round_schedule[round_index] + 1):
            round_sprob += current_round_distribution[k]
        return round_sprob

    def calculate_further_round_distribution(self, round_index, previous_rounds_distribution):
        # initializing a current_round_distribution
        current_round_distribution = [0] * (self.round_schedule[round_index] + 1)
        
        # improving efficiency at the expense of negligible accuracy
        previous_rounds_distribution_bounds = get_interval(previous_rounds_distribution)

        # For every possibility (of number of ballots for the winner) in the past rounds...
        for previous_rounds_possibility in range(previous_rounds_distribution_bounds[0], previous_rounds_distribution_bounds[1]):
            winner_ballots = range(0, self.round_schedule[round_index] - self.round_schedule[round_index - 1] + 1)
            unsampled_N = self.N - self.round_schedule[round_index - 1]
            unsampled_winner_ballots = self.true_tally - previous_rounds_possibility
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

    def compute_total_sprob(self):
        # If the true tally is a tie (or margin of 1 in favor of the reported loser),
        # then this method returns the risk limit of the audit conducted with the k_mins.
        total_sprob = 0
        for sprob in self.sprobs:
            total_sprob += sprob
        return total_sprob
    
    def compute_expectation(self):
        # This returns the average number of ballots examined by the audit if the reported tally
        # is correct.
        expectation = 0
        for index in range(0, self.number_of_rounds):
            expectation += self.round_schedule[index] * self.sprobs[index]
        expectation += self.N * (1 - self.compute_total_sprob())
        return expectation
        


def main():
    N = 100000
    round_schedule = [200, 400, 800, 1600, 3200]
    k_mins = [117, 223, 431, 843, 1661]
    true_tally = 65000

    mysprobs = Stopping_Probabilities(N, round_schedule, k_mins, true_tally)
    mysprobs.calculate_sprobs()

    print(mysprobs.sprobs)
    print("Expectation:", mysprobs.compute_expectation())


if __name__ == '__main__':
    main()