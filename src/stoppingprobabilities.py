# Grant McClearn
# July 24, 2019

''' A program that calculates the probabability mass function of stopping at audit
tiers and going to a full hand count (included so the sum over all values of the pmf = 1),
given the true tally of the election.
One can view computing a risk-limiting audit (in the convolution approach) as the
special case of this where the true tally is set to a tie
(or margin of 1 in favor of the reported loser).

The computation of the expectation of the pmf is also performed, and this program
is what was used to calculate the expectations shown in spreadsheet data also
on this repository.'''

from scipy.stats import hypergeom
''' Provides the hypergeometric distribution, of use in the calculation of error.'''

import datetime as dt
''' For benchmarking the time it takes the program to run.'''

def get_interval(dist):
    ''' This function aids in truncating distributions by finding levels l and u such that 
    cdf(l) < .0000001 and 1 - cdf(u) < .0000001. (Here, cdf is used somewhat loosely because
    we do not require cdf(infinity) = 1,
    although the distribution should sum "close enough" to 1 because .0000001 is absolute, not relative 
    (i.e. a distribution that summed to .0000004 would result in only half the distribution being between l and u). 
    
    The purpose of this is to improve efficiency, since, 
    for instance almost all of the hypergeometric distribution falls between a fraction of its range. 
    This decreases the time it takes to iterate over the (meaningful parts of) distributions. '''

    length = len(dist)
    sum = 0
    for x in dist:
        sum += x
    if (sum < 2 * .00000001):
        return ([int(length/2 - 1), int(length/2 + 1)])


    lower_sum = 0
    lower_endpoint = 0
    for i in range(0, length):
        lower_sum += dist[i]

        # if adding the next value of the distribution would cause us to exceed the tolerance,
        # break and return the lower level
        if (lower_sum + dist[i + 1] > .0000001):
            lower_endpoint = i
            break
    
    upper_sum = 0
    upper_endpoint = length
    for i in range(0, length):
        upper_sum += dist[length - i - 1]

        if (upper_sum + dist[length - i - 2] > .0000001):
            upper_endpoint = length - i - 1
            break
    
    endpoints = [lower_endpoint, upper_endpoint]
    return endpoints

def main():
    starttime = dt.datetime.now()

    # N = total number of votes for the two candidates
    N = 100000

    # the true tally of the election (number of votes received for reported winner)
    # Of course one does not ever know this value, short of doing a full hand count,
    # but the reported tally can be used here as a proxy to perform optimization.
    true_tally = 60000

    # m = number of audit rounds, equal to the length of the list n
    m = 9

    # n = a list of the size of each of the escalating audit rounds
    n = [200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200]

    # k_mins = a list of the k_min values, respective to the audit rounds in list n
    k_mins = [122, 232, 447, 868, 1698, 3339, 6596, 13063, 25913]

    # sprobs = stopping probabilities = 
    # a list of the probabilities that each audit round (respectively) stops
    # In special case of tied true tally, this is the error of the round.
    sprobs = [0] * m

    ''' The first audit round is calculated directly and does not require a convolution 
    (as there is no previous distribution to convolve with). '''
    current_round_distribution = hypergeom.pmf(range(0, n[0] + 1), N, true_tally, n[0])
    this_round_sprob = 0
    for k in range(k_mins[0], n[0] + 1):
        this_round_sprob += current_round_distribution[k]

    print("Round ", 1, " stopping probability:", this_round_sprob)
    sprobs[0] = this_round_sprob

    # We now remove the probabilities >= k_min, since they do not proceed to further audit rounds.
    for k in range(k_mins[0], n[0] + 1):
        current_round_distribution[k] = 0

    # As we proceed into the next distribution, we set previous_rounds_distribution equal to the current_round_distribution.
    previous_rounds_distribution = current_round_distribution

    # For rounds > 1, we must take into account this previous_rounds_distribution.
    for roundnum in range(1, m):

        # re-initializing a current_round_distribution to reflect the size of the new audit round
        current_round_distribution = [0] * (n[roundnum] + 1)

        # We compute an interval which contains almost the entire previous_rounds_distribution, but improves efficiency.
        previous_rounds_distribution_bounds = get_interval(previous_rounds_distribution)

        # We compute the convolution manually to allow for a changing third parameter of the hypergeometric distribution.
        for previous_rounds_possibility in range(previous_rounds_distribution_bounds[0], previous_rounds_distribution_bounds[1]):

            # Each possible number of ballots drawn for the reported winner (this round only) is in the following range.
            # It is the variable of the hypergeometric distribution.
            winner_ballots = range(0, n[roundnum] - n[roundnum - 1] + 1)

            # the number of unsampled ballots
            unsampledN = N - n[roundnum - 1]

            # the number of unsampled winner ballots
            # We do not know what this true value is; hence the requirement of an outer loop,
            # which iterates over every possibility.
            unsampled_winner_ballots = true_tally - previous_rounds_possibility

            # number of ballots being sampled (this round)
            sample_size = n[roundnum] - n[roundnum - 1]

            this_round_draws = hypergeom.pmf(winner_ballots, unsampledN, unsampled_winner_ballots, sample_size)

            for this_round_possibility in range(0, n[roundnum] - n[roundnum - 1] + 1):
                # Here, the probability of getting x ballots (for the reported winner) in the previous rounds and
                # y ballots in the current round is calculated, giving one component of the probability of getting
                # x + y ballots for the reported winner in total.
                component_probability = previous_rounds_distribution[previous_rounds_possibility]
                component_probability *= this_round_draws[this_round_possibility]
                current_round_distribution[previous_rounds_possibility + this_round_possibility] += component_probability
    

        # We calculate the sprob of the computed convolution for the given k_min.
        this_round_sprob = 0
        for k in range(k_mins[roundnum], n[roundnum] + 1):
            this_round_sprob += current_round_distribution[k]

        print("Round ", roundnum + 1, " stopping probability:", this_round_sprob)
        sprobs[roundnum] = this_round_sprob

        # Removing those probabilities which do not proceed to the next round.
        for k in range(k_mins[roundnum], n[roundnum] + 1):
            current_round_distribution[k] = 0
    
        previous_rounds_distribution = current_round_distribution

    rounds_sprob_sum = 0
    for sprob in sprobs:
        rounds_sprob_sum += sprob

    print("The chance of the audit stopping before a full hand count is", rounds_sprob_sum * 100,"%.")

    # Computation of the expectation.
    expectation = 0
    for index in range(0, m):
        expectation += n[index] * sprobs[index]
    # Inclusive of the possibility of a full hand count.
    expectation += (1 - rounds_sprob_sum) * N

    print("The average number of ballots that will be audited is", expectation)

    print("Time elapsed:", dt.datetime.now() - starttime)

if __name__ == '__main__':
    main()