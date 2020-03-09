import json
from scipy.stats import binom

def check_athena_rs(p, n, alpha, sprob, delta):
    """Returns the kmin if the passed n is a satisfactory round size, and 0 otherwise."""
    H0_dist = binom.pmf(range(0, n + 1), n, .5)
    Ha_dist = binom.pmf(range(0, n + 1), n, p)

    LR_num = 0
    LR_denom = 0

    for k in range(n, -1, -1):
        LR_num += Ha_dist[k]
        LR_denom += H0_dist[k]

        # If the risk exceeds alpha at this point, it will for all lower values as well.
        if LR_denom > alpha:
            return 0
            
        # TODO: stronger trapping condition: minerva likelihood ratio monotonic with decreasing k
        # TODO: start from bravo k and decrease--we're always better than bravo!
        # TODO: don't use likelihood ratio nomenclature for tail ratio

        # Short circuit to avoid imprecise float division in extreme cases.
        if LR_num > sprob and (LR_denom == 0.0 or LR_num / LR_denom > 1.0 / alpha) and   \
        (H0_dist[k] == 0.0 or Ha_dist[k] / H0_dist[k] > 1 / delta):
            return k
        
    return 0

def check_athena_offset(p, n, offset, alpha, sprob, delta):
    """Examines all round sizes in [n - offset, n) or (n, n + offset] (offset < 0 and > 0,
    respectively) and returns:
    0 if none are satisfactory
    1 if some but not all are satisfactory
    2 if all are satisfactory."""
    ct = 0

    if offset < 0:
        for x in range(n + offset, n):
            if check_athena_rs(p, x, alpha, sprob, delta) != 0:
                ct += 1
    else:
        for x in range(n + 1, n + offset + 1):
            if check_athena_rs(p, x, alpha, sprob, delta) != 0:
                ct += 1
    
    if ct == 0:
        return 0
    elif ct < offset:
        return 1
    else:
        return 2

def binary_athena_last_rs(p, left, right, offset, alpha, sprob, delta):
    """Using a binary search approximation (approximation because the search space is not
    completely sorted), find the round size such that a round size one smaller is the last
    unsatisfactory round size.

    To find the "last" round size n (a misnomer), n should be satisfactory, all offset
    values following n should be satisfactory, and not all offset values preceeding n
    should be satisfactory."""

    assert(right >= left)

    mid = (left + right) // 2

    ksome = check_athena_rs(p, mid, alpha, sprob, delta)

    if ksome == 0:
        # Round size of mid unsatisfactory. The searched-for round size must be larger.
        return binary_athena_last_rs(p, mid, right, offset, alpha, sprob, delta)

    else:
        prec = check_athena_offset(p, mid, -1, alpha, sprob, delta)
        fol = check_athena_offset(p, mid, offset, alpha, sprob, delta)

        # Haven't found the last round size if there's larger unsatisfactory round sizes.
        if fol < 2:
            return binary_athena_last_rs(p, mid, right, offset, alpha, sprob, delta)

        # Preceeding size is satisfactory.
        elif prec == 2 and fol == 2:
            return binary_athena_last_rs(p, left, mid, offset, alpha, sprob, delta)
        
        else:
            return mid

names = []
relevant = []
total = []
margin = []

# NOTE: The following ought to be changed based on where Filip's raw data is found.
with open('./../../aurror/code/data/2016_election.json') as state_data:
    states = json.load(state_data)
    
    for state in states:
        names.append(state)
        relevant.append(states[state]['contests']['presidential']['results'][0] +
                        states[state]['contests']['presidential']['results'][1])
        total.append(states[state]['contests']['presidential']['ballots_cast'])
        margin.append(abs(states[state]['contests']['presidential']['margin']))

assert(len(names) == len(relevant) == len(total) == len(margin))

out = {}

margin_threshold = .05
for i in range(0, len(names)):
    if margin[i] > margin_threshold:
        print(names[i])

        # Simple efficiency improvement since upper search boundary for margins > .05 is
        # relatively small.
        if margin[i] > .05:
            upper = 10000
        else:
            upper = 2000000
        raw = binary_athena_last_rs((1+margin[i])/2, 0, upper, 100, .1, .9, 1)
        scaled = int(raw * total[i] / relevant[i] + 1) # ceiling instead of floor

        m_raw = binary_athena_last_rs((1+margin[i])/2, 0, upper, 100, .1, .9, 1000000)
        m_scaled = int(raw * total[i] / relevant[i] + 1) # ceiling instead of floor

        out[names[i]] = []
        out[names[i]].append({"Athena_gm_raw": raw, "Athena_gm_scaled": scaled,          
        "Minerva_gm_raw": m_raw, "Minerva_gm_scaled": m_scaled})

        with open('2016_election_goddess.json', 'w') as output:
            json.dump(out, output, sort_keys=True, indent=4)