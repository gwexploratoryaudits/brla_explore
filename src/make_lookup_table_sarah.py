"""
Sarah Morin
6/3/2019

Generating lookup table for Bayesian RLA using binary search

Bayesian RLA uses a prior distribution which is uniform on tallies favoring
the winner and concentrated on a margin of one for tallies favoring the loser.

To generate lookup table for an election, edit the parameters within the main
method: total_votes, audit_tiers, and risk_limits.
"""

from scipy.stats import hypergeom as hg
from typing import List


"""Generate lookup table for an election with:

    @param total_votes: Total number of votes cast in a given election.

    @param audit_tiers: Array (or list) of escalating audit tier sizes.
    The audit will begin with a sample of size audit_tiers[0] and either stop
    (if stopping criterion is met), or progress on to audit_tiers[1]
    (which should be double audit_tiers[0]), and so on.

    @param: risk_limits: Array (or list) of risk limits for which we will
    generate minimum stopping vote counts.

    @return: 2D Array (List) of integers where each row corresponds to a risk
    limit and each column corresponds to an audit tier. The table contains the
    minimum number of votes for the announced winner needed to stop the audit
    for a given risk limit and sample size (audit tier).

"""


def generate_lookup_table(total_votes: int, audit_tiers: List[int], risk_limits: List[float]) -> List[List[int]]:
    # Create empty lookup table with len(risk_limits) rows and len(audit_tiers) columns
    lookup_table = [[0 for i in range(len(audit_tiers))] for j in range(len(risk_limits))]

    # Prior distribution for Bayesian RLA (described above)
    prior = [0 for i in range(total_votes//2)]+[0.5]+[(0.5/(total_votes-(total_votes//2))) for j in range(total_votes-(total_votes//2))]

    # Fill table with stopping sizes
    for risk in range(len(risk_limits)):
        for audit_size in range(len(audit_tiers)):
            lookup_table[risk][audit_size] = get_kmin(audit_tiers[audit_size], risk_limits[risk], prior, total_votes)

    return lookup_table


"""
Get error value assosciated with stopping size and audit tier.
Error is calcualted using a prior distribution (as described above)
and a posterior ditribution generated using the hypergeometric distribution
and prior distribution. The posterior distribution is then normalized and
the assocaited error (or risk) is calculated.

    @param stop: (integer) stopping value to calculate error for. Should have
    stop < audit.

    @param audit: Size of current audit tier, i.e. size of sample which will
    be taken during audit.

    @param prior: Prior distribution (described above)

    @param total_votes: Total number of votes in election. Used for calcualting
    distributions.

    @return: error value assosciated with given audit tier and stopping size.
    Calcualted using method described in Bayesian RLA paper (Vora).
"""


def get_error(stop: int, audit: int, prior: List[float], total_votes: int) -> float:
    # Get posterior distribution
    posterior = hg.pmf(stop, total_votes, range(0, total_votes+1), audit)
    posterior = [posterior[i]*prior[i] for i in range(len(posterior))]
    posterior /= sum(posterior)

    return sum(posterior[range(total_votes//2 + 1)])

    # posterior = prior .* hg(stop, total_votes, range(0, total_votes+1), audit)
    # normalize: posterior = posterior/sum(posterior)
    # get error: sum(poster(range(total_votes//2 + 1)))


"""
Get stopping size for audit tier which meets given risk limit using prior
distribution for Bayesian RLA. Uses binary search to test various stopping size
values and verify that calcualted error is less than or equal to risk limit.

    @param audit_size: (integer) number of votes sampled from all votes in
    election

    @param risk: Risk limit for audit. Risk (error) associated with stopping
    value should be less than or equal to risk.

    @param prior: Prior distribution used to calcuated error when testing
    stopping values. Passed to get_error(stop, audit, prior).

    @param total_votes: Used to calcualte error values.

    @return: (integer) number of votes needed to stop audit at given audit size
    and risk limit
"""


def get_kmin(audit_size: int, risk: float, prior: List[float], total_votes: int) -> int:
    # Left and right pointers used for binary search
    left = audit_size//2
    right = audit_size

    # Continue searching while pointers are different or stopping size is found
    while left < right:
        # Test stopping size at midpoint
        test_stop = (left+right)//2
        # Get error value for current stop size
        test_error = get_error(test_stop, audit_size, prior, total_votes)

        # If this value meets the risk limit, return this stopping value
        if test_error == risk:
            return test_stop

        # If this value is less than the risk limit, test a samller stopping size
        # More error to work with
        if test_error < risk:
            # Get error for stopping size - 1
            prev_error = get_error(test_stop-1, audit_size, prior, total_votes)
            # If this error meets the risk, return stopping size - 1
            if prev_error == risk:
                return test_stop-1
            # If this error is greater than the risk, the original stopping size
            # is the minimum, return the stopping size
            if prev_error > risk:
                return test_stop
            # Otherwise, test smaller values
            right = test_stop-1
        # If error is greater than risk, test larger values
        else:
            left = test_stop + 1

    # If pointers meet, return
    return left


def main():
    # Generate lookup table for election of 100,000 total votes,
    #   9 escalting audit tiers starting at 200,
    #   3 risk limits
    # This currently matches table 3 from the Bayesian RLA paper
    total_votes = 100000
    audit_tiers = [200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200]
    risk_limits = [0.1, 0.05, 0.005]

    lookup = generate_lookup_table(total_votes, audit_tiers, risk_limits)
    print(lookup)


if __name__ == '__main__':
    main()
