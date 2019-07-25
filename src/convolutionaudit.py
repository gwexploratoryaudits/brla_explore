# Grant McClearn
# July 24, 2019

''' A program to calculate the kmins (stopping rule) of an audit proceeding in rounds, 
or tiers in the Bayesian nomenclature,
given a specified (frequentist) risk limit.'''

from scipy.stats import hypergeom
''' Provides the hypergeometric distribution, of use in the calculation of error.'''

import datetime as dt
''' For benchmarking the time it takes the program to run.'''

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
    length = len(dist)

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
    HalfN = int(N / 2)

    # m = number of audit rounds, equal to the length of the list n
    m = 9

    # n = a list of the size of each of the escalating audit rounds
    n = [200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200]
    halfn = [int(roundsize / 2) for roundsize in n]

    # the specified risk limit of the audit
    risklim = .09

    # risk allottment function, or error distribution
    # a decreasing geometrically (r = 1/2) error distribution is commented out
    allotted_error = [risklim / m] * m
    '''
    allotted_error = [0] * m
    for i in range(0, m):
        allotted_error[i] = .05 * (1.0 / 2) * ((1.0/2) ** (i))
    testerr = 0
    for x in allotted_error:
        testerr += x
    print(testerr)
    allotted_error[0] += risklim - testerr
    '''

    # lists storing stopping rules and their respective probabilities of error
    k_mins = [0] * m
    used_error = [0] * m

    ''' The first audit round is calculated directly and does not require a convolution 
    (as there is no previous distribution to convolve with). '''
    current_round_distribution = hypergeom.pmf(range(0, n[0] + 1), N, HalfN, n[0])

    ''' We analyze potential k_mins. We start with the lowest possible (half of the vote),
    increasing until a k_min is found that is bounded by the allotted error. In this way,
    we ensure we get the smallest (most desireable) k_min. '''
    for potential_k_min in range(halfn[0], n[0]):
        this_round_error = 0
        for k in range(potential_k_min, n[0] + 1):
            this_round_error += current_round_distribution[k]
        # if the error resulting from this potential k_min is indeed lower than allotted
        # error, we have found our k_min
        if this_round_error <= allotted_error[0]:
            k_mins[0] = potential_k_min
            used_error[0] = this_round_error
            # leftover error given to next round
            allotted_error[1] += allotted_error[0] - used_error[0]
            break

    # We now remove the probabilities >= kmin, since they do not proceed to further audit rounds.
    for k in range(k_mins[0], n[0] + 1):
        current_round_distribution[k] = 0

    print("Round 1 completed, with kmin", k_mins[0], "and error: ", used_error[0])

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
            unsampled_winner_ballots = HalfN - previous_rounds_possibility

            # number of ballots being sampled (this round)
            sample_size = n[roundnum] - n[roundnum - 1]

            this_round_draws = hypergeom.pmf(winner_ballots, unsampledN, unsampled_winner_ballots, sample_size)

            for this_round_possibility in range(0, n[roundnum] - n[roundnum - 1] + 1):
                # Here, the probability of getting x ballots (for the reported winner) in the previous rounds and
                # y ballots in the current round is calculated, giving one component of the probability of getting
                # x + y ballots for the reported winner in total.
                component_probability = previous_rounds_distribution[previous_rounds_possibility] * this_round_draws[this_round_possibility]
                current_round_distribution[previous_rounds_possibility + this_round_possibility] += component_probability
    
        # Again, finding the k_min by increasing the potential k_min
        # until one that is less than the allotted error is found.
        for potential_k_min in range(halfn[roundnum], n[roundnum]):
            this_round_error = 0
            for k in range(potential_k_min, n[roundnum] + 1):
                this_round_error += current_round_distribution[k]    
            if this_round_error <= allotted_error[roundnum]:
                k_mins[roundnum] = potential_k_min
                used_error[roundnum] = this_round_error
                # giving leftover error to next audit round, if there is a next round
                if roundnum + 1 < m:
                    allotted_error[roundnum + 1] += allotted_error[roundnum] - used_error[roundnum]
                break
        
        # Removing those probabilities which do not proceed to the next round.
        for k in range(k_mins[roundnum], n[roundnum]):
            current_round_distribution[k] = 0

        print("Round", roundnum + 1, "completed, with kmin", k_mins[roundnum], "and error: ", used_error[roundnum])

        previous_rounds_distribution = current_round_distribution

    # The used risk will (essentially) always be slightly less than the prespecified risk, 
    # due to the k_mins' being integers.
    used_risk = 0
    for error in used_error:
        used_risk += error

    print("The set of k_mins is", k_mins)
    print("The precise risk limit of the audit is", used_risk * 100, "%.")

    print("Time elapsed:", dt.datetime.now() - starttime)

if __name__ == '__main__':
    main()