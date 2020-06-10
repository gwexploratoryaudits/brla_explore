from scipy.stats import binom
from scipy.signal import fftconvolve

class Sprob:
    """ Computes an Athena audit.
    
        This class allows for the instantiation of an Athena audit object, 
        for two candidates with no invalid votes in the polling case, including the
        parameters for the total number of ballots cast, the reported winner tally, and
        the round and k_min schedules, from which the risk of the audit is derived.
    ..  note:: 
    
        This is equivalent to "AURROR 2.0."
        
    ..  note:: 
    
        Throughout the class, the null hypothesis of the reported loser winning (or tying)
        is abbreviated as "H0", which has its own assumed tally and distribution distinct
        from the alternative hypothesis "Ha" of the reported winner really winning.
    """
    
    N: int
    Ha_tally: int
    round_sched: list
    k_min_sched: list
    pr_H0_sched: list
    pr_Ha_sched: list
    risk_sched: list

    def __init__(self, N, Ha_tally, round_sched, k_min_sched):
        self.N = N
        self.Ha_tally = Ha_tally
        self.round_sched = round_sched
        self.k_min_sched = k_min_sched

        self.check_params()

        self.m = len(round_sched)
        self.H0_tally = self.N // 2
        self.pr_H0_sched = [0] * self.m
        self.pr_Ha_sched = [0] * self.m
        self.risk_sched = [0] * self.m

    def check_inc_sched(self, sched):
        """ Returns True iff a list of numbers is strictly increasing.
        :param sched: Presumably a round or k_min schedule.
        :type: sched: list.
        :returns: bool
        """
        
        if type(sched) != list:
            return False
        
        for i in range(1, len(sched)):
            if sched[i] <= sched[i - 1]:
                return False
        
        return True

    def check_params(self):
        """ Prints out notices about bad parameters.
        This method prints out a notice for obvious errors in the audit parameters,
        such as a negative N, a mismatch between the lengths of the round and k_min
        schedules, etc.
        """
        
        # TODO: More cases, especially confirming appropriate types.

        if self.N <= 0:
            print('Bad Parameter: N')
        
        if self.Ha_tally <= 0 or self.Ha_tally > self.N:
            print('Bad Parameter: Reported winner tally')
        
        if len(self.round_sched) < 1 or not self.check_inc_sched(self.round_sched):
            print('Bad Parameter: Round Schedule')

        if len(self.k_min_sched) < 1 or not self.check_inc_sched(self.k_min_sched):
            print('Bad Parameter: k_min Schedule')

        if len(self.round_sched) != len(self.k_min_sched):
            print('Bad Parameter: Schedule mismatch')
    
    def compute_risk(self):
        """ The body of the audit procedure.
        The audit computation proceeds in three steps (twice over for each hypothesis):
        1. The distribution for the current round is computed as the distribution for the
        current draws convolved with the previous round's distribution.
        2. The stopping probability for the given k_min is summed.
        3. Values >= k_min are truncated, because they should not contribute to the future
        rounds' risks.
        """
        
        H0_dist = []
        Ha_dist = []

        for i in range(0, self.m):
            
            H0_dist = self.next_round_dist(True, H0_dist, i)
            Ha_dist = self.next_round_dist(False, Ha_dist, i)

            self.pr_H0_sched[i] = self.compute_sprob(H0_dist, i)
            self.pr_Ha_sched[i] = self.compute_sprob(Ha_dist, i)
            self.risk_sched[i] = self.pr_H0_sched[i] / self.pr_Ha_sched[i]

            self.truncate_dist(H0_dist, i)
            self.truncate_dist(Ha_dist, i)
        
        print('RISK CONSUMED SCHEDULE:', self.pr_H0_sched, '\n STOPPING PROB SCHEDULE', 
            self.pr_Ha_sched, '\n RATIO SCHEDULE (lowest value = risk limit of audit w/ these kmins)', self.risk_sched)

    def next_round_dist(self, H0, dist, rnd_index):
        """ Calculates the distribution of the next round.
        This method calculates the probability distribution of the next round, given the
        probability distribution of the previous round (used for convolution).
        :param H0: Which hypothesis' distribution, true if the null.
        :type: H0: bool.
        :param dist: The previous round's probability distribution.
        :type: dist: list.
        :param rnd_index: The index of the next round. The first round has rnd_index 0.
        :type: rnd_index: int.
        :returns: list
        """

        if H0:
            tally = self.H0_tally
        else:
            tally = self.Ha_tally
        
        if rnd_index == 0:
            draws = self.round_sched[rnd_index]
        else:
            draws = self.round_sched[rnd_index] - self.round_sched[rnd_index - 1]
        
        p = tally/self.N

        draws_dist = binom.pmf(range(0, draws + 1), draws, p)
        
        if rnd_index == 0:
            return draws_dist
        else:
            return fftconvolve(dist, draws_dist)

    def compute_sprob(self, dist, rnd_index):
        """ Computes the stopping probability of a round.
        Given the round's distribution and its index (from which we ascertain the k_min),
        this method calculates the round's stopping probability.
        :param dist: The round's probability distribution.
        :type: dist: list.
        :param rnd_index: The round index. The first round has rnd_index 0.
        :type: rnd_index: int.
        :returns: float
        """

        sprob = 0
        for i in range(self.k_min_sched[rnd_index], self.round_sched[rnd_index] + 1):
            sprob += dist[i]
        
        return sprob

    def truncate_dist(self, dist, rnd_index):
        """ Truncates (or "lops off") the part of distributions >= k_min.
        So that certain sequences of ballots are not counted towards the risk more than
        once, this method truncates the tail of a given distribution.
        :param dist: The round's probability distribution.
        :type: dist: list.
        :param rnd_index: The round index. The first round has rnd_index 0.
        :type: rnd_index: int.
        """

        for i in range(self.k_min_sched[rnd_index], self.round_sched[rnd_index]+1):
            dist[i] = 0