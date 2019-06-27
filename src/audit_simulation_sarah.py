from multivariate_hypergeom_sample import multivhyper
from brla_sarah import brla
import numpy as np

"""
Class for simulating Bayesian RLA.
Can be used on 2-candidate or multi-candidate elections with or without invalid votes.
"""


class auditsim:

    def __init__(self, total_votes: int, vote_dist, audit_tier: int, invalid: bool = False):
        """
        Create audit simulation object.

            @param total_votes: Total number of ballots cast in election.

            @param vote_dist: True underlying distribution of votes in election.
            Can be list of integer counts of votes, or dict with integer count values.
            * First count in distribution represents announced winner.
            * Last count in distribution represents invalid votes (if applicable)

            @param audit_tier: First audit tier to use in audit, must be integer.

            @param invalid: indidicates if invalid votes are present in election.
            (Optional, default = False).

            @return: Audit object which allows simulation of many audits on same
            election.
        """
        # type check parameters
        if type(total_votes) is not int:
            raise TypeError("Total ballots cast in election must be integer.")
        if type(vote_dist) is not list and type(vote_dist) is not dict:
            raise TypeError("Vote distribution is election must be list or dict.")
        if type(vote_dist) is list and not all(isinstance(n, int) for n in vote_dist):
            raise TypeError("Vote distribution must be integer counts")
        if type(vote_dist) is dict and not all(isinstance(n, int) for n in list(vote_dist.values())):
            raise TypeError("Vote distribution must be integer counts")
        if type(audit_tier) is not int:
            raise TypeError("Audit tier must be integer.")
        if type(invalid) is not bool:
            raise TypeError("Invalid must be True/False")

        # Set attributes
        self.total_votes = total_votes
        self.vote_dist = vote_dist
        self.invalid = invalid
        self.audit_tier = audit_tier

        # TODO: audit tier is currently first audit tier, then doubles after
        #   could modify to accept list of integer audit tiers

        # Get number of candidates in election
        if invalid:
            self.num_candidates = len(vote_dist)-1
        else:
            self.num_candidates = len(vote_dist)

    def run(self, risk_limit: float) -> bool:
        """
        Run (simulate) Bayesian RLA.

        @param risk_limit: float value (between 0 and 1) to use in audit.

        @return: Returns True is audit stops, i.e. confirming anounced outcome
        of election. False if audit must progress to a full recount.

        Testing

        >>> auditsim(10000, [9000, 1000], 100).run(0.1)
        True
        >>> auditsim(10000, [5000, 5000], 100).run(0.1)
        False
        >>> auditsim(10000, [4000, 6000], 100).run(0.1)
        False
        """
        # Type check risk limit
        if type(risk_limit) is not float:
            raise TypeError("Risk limit must be float")
        if risk_limit >= 1.0 or risk_limit <= 0.0:
            raise ValueError("Risk limit must be between 0 and 1.0")

        # Create distribution object to sample from ballots in election
        ballots = multivhyper(self.vote_dist)

        # Initialize array to hold audit counts for each type of vote
        audit_counts = np.zeros(len(self.vote_dist), dtype=int)

        # Set initial audit tier and sample size
        audit_tier = self.audit_tier
        sample_size = self.audit_tier

        # Create auditing object for calculations
        audit_lookup = brla(self.total_votes)

        # Run audit until stop or full recount
        while True:
            # Get a sample of ballots
            sample = ballots.sample(sample_size)

            # Add ballots in new sample to running count of votes in audit
            audit_counts = audit_counts + sample

            # Handle invalid votes if necessary
            if self.invalid:
                invalid = int(audit_counts[-1])
            else:
                invalid = 0

            # Audit comparisons
            if self.num_candidates == 2:
                # Two candidate comparison
                kmin = audit_lookup.get_stopping_size(audit_tier, risk_limit, invalid)

                if audit_counts[0] > kmin:
                    # print("Audit stopped at size ", audit_tier)
                    return True
            else:
                # Multicandidate comparison
                stop = True
                # pairwise comparisons
                for i in range(1, self.num_candidates):
                    pair_invalid = audit_tier-(audit_counts[0]+audit_counts[i])
                    kmin = audit_lookup.get_stopping_size(audit_tier, risk_limit, pair_invalid)

                    if audit_counts[0] <= kmin:
                        stop = False
                        break

                # if all comparisons pass, stop audit
                if stop:
                    # print("Audit stopped at size ", audit_tier)
                    return True

            # Test for recount
            if audit_tier >= self.total_votes//2:
                # print("You must progress to a full recount")
                return False

            # Update sample and audit sizes
            sample_size = audit_tier
            audit_tier *= 2

        return False


def main():
    import doctest
    doctest.testmod()


if __name__ == '__main__':
    main()
