import numpy as np
from scipy.stats import hypergeom
from scipy.signal import fftconvolve
import datetime as dt

''' The basic structure of this program is the same as conditionalriskofkmins. The difference is that instead of finding the error associated with a
    fixed set of kmins, we find the kmins such that their error is bounded by the risk. This doesn't actually add too much time, since the most
    expensive computations are the convolutions themselves, which we only compute once for each audit tier in any event. '''
    
starttime = dt.datetime.now()

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

N = 100000
HalfN = int(N / 2)

m = 9
n = [200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200]
halfn = [int(tiersize / 2) for tiersize in n]

risklim = .005

# error distributions here, a decreasing geometrically (r = 1/2) error distribution is commented out
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


k_mins = [0] * m
used_error = [0] * m

# first audit tier calculated directly
current_tier_distribution = hypergeom.pmf(range(0, n[0] + 1), N, HalfN, n[0])

for potential_k_min in range(halfn[0], n[0]):
    this_tier_error = 0
    for k in range(potential_k_min, n[0] + 1):
        this_tier_error += current_tier_distribution[k]
    if this_tier_error <= allotted_error[0]:
        k_mins[0] = potential_k_min
        used_error[0] = this_tier_error
        allotted_error[1] += allotted_error[0] - used_error[0]
        break

for k in range(k_mins[0], n[0] + 1):
    current_tier_distribution[k] = 0

print("Tier 1 completed.")

previous_tiers_distribution = current_tier_distribution

for tiernum in range(1, m):
    current_tier_distribution = [0] * (n[tiernum] + 1)

    previous_tiers_distribution_bounds = get_interval(previous_tiers_distribution)

    for previous_tier_possibility in range(previous_tiers_distribution_bounds[0], previous_tiers_distribution_bounds[1]):
        this_tier_draws = hypergeom.pmf(range(0, n[tiernum] - n[tiernum - 1] + 1), N - n[tiernum - 1], HalfN - previous_tier_possibility, n[tiernum] - n[tiernum - 1])

        for this_tier_possibility in range(0, n[tiernum] - n[tiernum - 1] + 1):
            current_tier_distribution[previous_tier_possibility + this_tier_possibility] += previous_tiers_distribution[previous_tier_possibility] * this_tier_draws[this_tier_possibility]

    
    for potential_k_min in range(halfn[tiernum], n[tiernum]):
        #print("going into tier", tiernum + 1, "with allotted error", allotted_error[tiernum])
        this_tier_error = 0
        for k in range(potential_k_min, n[tiernum] + 1):
            this_tier_error += current_tier_distribution[k]
        if this_tier_error <= allotted_error[tiernum]:
            k_mins[tiernum] = potential_k_min
            used_error[tiernum] = this_tier_error
            # giving leftover error to next audit tier
            if tiernum + 1 < m:
                allotted_error[tiernum + 1] += allotted_error[tiernum] - used_error[tiernum]
            break

    for k in range(k_mins[tiernum], n[tiernum]):
        current_tier_distribution[k] = 0

    print("Tier", tiernum + 1, "completed.")

    previous_tiers_distribution = current_tier_distribution


used_risk = 0
for error in used_error:
    used_risk += error

print("The risk of the audit is", used_risk * 100, "%.")
print(used_error)
print(k_mins)

print("Time elapsed:", dt.datetime.now() - starttime)
    



