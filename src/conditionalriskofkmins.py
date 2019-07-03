import numpy as np
from scipy.stats import hypergeom
from scipy.signal import fftconvolve
import datetime as dt

starttime = dt.datetime.now()

''' This function aids in truncating distributions by finding levels l and u such that 
    cdf(l) < .0000001 and 1 - cdf(u) < .0000001. (Here, cdf is used somewhat loosely because we do not require cdf(infinity) = 1,
    although the distribution should sum "close enough" to 1 because .0000001 is absolute, not relative 
    (i.e. a distribution that summed to .0000004 would result in only half the distribution being between l and u). 
    
    The purpose of this is to improve efficiency, since, for instance almost all of the hypergeometric distribution falls between a fraction of its range. 
    This decreases the time it takes to iterate over the (meaningful parts of) distributions. '''
def get_interval(dist):
    length = len(dist)

    lower_sum = 0
    lower_endpoint = 0
    for i in range(0, length):
        lower_sum += dist[i]

        # if adding the next value of the distribution would cause us to exceed the tolerance, break and return the lower level
        if (lower_sum + dist[i + 1] > .000001):
            lower_endpoint = i
            break
    
    upper_sum = 0
    upper_endpoint = length
    for i in range(0, length):
        upper_sum += dist[length - i - 1]

        if (upper_sum + dist[length - i - 2] > .000001):
            upper_endpoint = length - i - 1
            break
    
    endpoints = [lower_endpoint, upper_endpoint]
    return endpoints

# N = total number of votes for the two candidates
N = 100000
HalfN = int(N / 2)

# m = number of audit tiers, equal to the length of the list n
m = 9

# n = a list of the size of each of the escalating audit tiers
n = [200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200]
halfn = [int(tiersize / 2) for tiersize in n]

# kmins = a list of the kmin values, respective to the audit tiers in list n
kmins = [119, 225, 434, 849, 1667, 3293, 6527, 12967, 25793]

# errors = a list of the probabilities that each audit tier (respectively) makes an error, initialized to zeroes
errors = [0] * m

''' The first audit tier is calculated directly and does not require a convolution (as there is no previous distribution to convolve with). '''
current_tier_distribution = hypergeom.pmf(range(0, n[0] + 1), N, HalfN, n[0])
this_tier_error = 0
for k in range(kmins[0], n[0] + 1):
    this_tier_error += current_tier_distribution[k]

print("Tier ", 1, " error:", this_tier_error)
errors[0] = this_tier_error

# We now remove the probabilities >= kmin, since they do not proceed to further audit tiers.
for k in range(kmins[0], n[0] + 1):
    current_tier_distribution[k] = 0

# As we proceed into the next distribution, we set previous_tiers_distribution equal to the current_tier_distribution.
previous_tiers_distribution = current_tier_distribution

# For tiers > 1, we must take into account this previous_tiers_distribution.
for tiernum in range(1, m):
    # re-initializing a current_tier_distribution to reflect the size of the new audit tier
    current_tier_distribution = [0] * (n[tiernum] + 1)

    # We compute an interval which contains almost the entire previous_tiers_distribution, but improves efficiency.
    previous_tiers_distribution_bounds = get_interval(previous_tiers_distribution)

    # We compute the convolution manually to allow for a changing third parameter of the hypergeometric distribution.
    for previous_tier_possibility in range(previous_tiers_distribution_bounds[0], previous_tiers_distribution_bounds[1]):
        this_tier_draws = hypergeom.pmf(range(0, n[tiernum] - n[tiernum - 1] + 1), N - n[tiernum - 1], HalfN - previous_tier_possibility, n[tiernum] - n[tiernum - 1])

        for this_tier_possibility in range(0, n[tiernum] - n[tiernum - 1] + 1):
            current_tier_distribution[previous_tier_possibility + this_tier_possibility] += previous_tiers_distribution[previous_tier_possibility] * this_tier_draws[this_tier_possibility]

    # We calculate the error of the computed convolution for the given kmin.
    this_tier_error = 0
    for k in range(kmins[tiernum], n[tiernum] + 1):
        this_tier_error += current_tier_distribution[k]

    print("Tier ", tiernum + 1, " error:", this_tier_error)
    errors[tiernum] = this_tier_error

    # Removing those probabilities which do not proceed to the next tier.
    for k in range(kmins[tiernum], n[tiernum] + 1):
        current_tier_distribution[k] = 0
    
    previous_tiers_distribution = current_tier_distribution

risk = 0
for error in errors:
    risk += error

print(errors)

print("The risk limit of this audit is", risk * 100,"%.")

print("Time elapsed:", dt.datetime.now() - starttime)
    # Keep in mind that the error from using get_interval does propogate.
        
