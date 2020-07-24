import json
from scipy.stats import binom
import numpy as np

def check_arlo_rs(p, n, alpha, sprob):
    """Returns some k if the passed n is a satisfactory round size, and 0 otherwise."""
    Ha_dist = binom.pmf(range(0, n + 1), n, p)
    H0_dist = binom.pmf(range(0, n + 1), n, .5)

    tail = 0

    for k in range(n, -1, -1):
        tail += Ha_dist[k]

        # If the p-value is too large for this k, it will be for all k' < k as well.
        if alpha * Ha_dist[k] < H0_dist[k]:
            return 0

        if tail > sprob:
            return k

def check_arlo_offset(p, n, offset, alpha, sprob):
    """Examines all round sizes in [n - offset, n) or (n, n + offset] (offset < 0 and > 0,
    respectively) and returns:
    0 if none are satisfactory
    1 if some but not all are satisfactory
    2 if all are satisfactory."""
    ct = 0

    if offset < 0:
        for x in range(n + offset, n):
            if check_arlo_rs(p, x, alpha, sprob) != 0:
                ct += 1
    else:
        for x in range(n + 1, n + offset + 1):
            if check_arlo_rs(p, x, alpha, sprob) != 0:
                ct += 1
    
    if ct == 0:
        return 0
    elif ct < offset:
        return 1
    else:
        return 2

def binary_arlo_last_rs(p, left, right, offset, alpha, sprob):
    """Using a binary search approximation (approximation because the search space is not
    completely sorted), find the round size such that a round size one smaller is the last
    unsatisfactory round size.
    To find the "last" round size n (a misnomer), n should be satisfactory, all offset
    values following n should be satisfactory, and not all offset values preceeding n
    should be satisfactory."""

    print(left, right)

    assert(right >= left)

    mid = (left + right) // 2

    k = check_arlo_rs(p, mid, alpha, sprob)

    if k == 0:
        # Round size of mid unsatisfactory. The searched-for round size must be larger.
        return binary_arlo_last_rs(p, mid+1, right, offset, alpha, sprob)

    else:
        prec = check_arlo_offset(p, mid, -1, alpha, sprob)
        fol = check_arlo_offset(p, mid, offset, alpha, sprob)

        # Haven't found the last round size if there's larger unsatisfactory round sizes.
        if fol < 2:
            return binary_arlo_last_rs(p, mid+1, right, offset, alpha, sprob)

        # Preceeding size is satisfactory.
        elif prec == 2 and fol == 2:
            return binary_arlo_last_rs(p, left, mid-1, offset, alpha, sprob)
        
        else:
            return mid

names = []
relevant = []
total = []
margin = []

# NOTE: The following ought to be changed based on where Filip's raw data is found.
with open('./../../athena/code/data/2016_election.json') as state_data:
    states = json.load(state_data)
    
    for state in states:
        names.append(state)
        relevant.append(states[state]['contests']['presidential']['results'][0] +
                        states[state]['contests']['presidential']['results'][1])
        total.append(states[state]['contests']['presidential']['ballots_cast'])
        margin.append(abs(states[state]['contests']['presidential']['margin']))

assert(len(names) == len(relevant) == len(total) == len(margin))

out = {}

margin_threshold = .0
for i in range(0, len(names)):
    if margin[i] > margin_threshold:
        print(names[i])

        # Simple efficiency improvement since upper search boundary for margins > .05 is
        # relatively small.
        if margin[i] > .05:
            upper = 30000
        elif margin[i] > .01:
            upper = 500000
        else:
            upper = 4000000

        raw = binary_arlo_last_rs((1+margin[i])/2, 0, upper, 100, .1, .9)
        scaled = int(raw * total[i] / relevant[i] + 1) # ceiling instead of floor

        #raw2 = binary_arlo_last_rs((1+margin[i])/2, 0, upper, 100, .1, .9, .5)
        #raw3 = binary_arlo_last_rs((1+margin[i])/2, 0, upper, 100, .1, .9, .2)
        #raw4 = binary_arlo_last_rs((1+margin[i])/2, 0, upper, 100, .1, .9, .1)

        #m_raw = binary_arlo_last_rs((1+margin[i])/2, 0, upper, 100, .1, .9)
        #m_scaled = int(m_raw * total[i] / relevant[i] + 1) # ceiling instead of floor

        out[names[i]] = []
        out[names[i]].append({"Arlo_gm_raw": raw, "Arlo_gm_scaled": scaled})

        with open('2016_election_complete_arlo.json', 'w') as output:
            json.dump(out, output, sort_keys=True, indent=4)