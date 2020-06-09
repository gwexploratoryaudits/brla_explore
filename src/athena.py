from typing import List
from scipy.stats import binom
from scipy.signal import fftconvolve
from scipy.signal import convolve
import copy
from datetime import datetime

class Athena:
    """ Computes an Athena audit.
    
        This class allows for the instantiation of an Athena audit object, 
        for two candidates with no invalid votes in the polling case, including the
        parameters for the total number of ballots cast, the reported winner tally, and
        the round and k_min schedules, from which the risk of the audit is derived.

    Attributes
        N (int): Total number of ballots cast for the two candidates.
        Ha_tally (int): The reported number of ballots for the reported winner.
        round_sched (List[int]): The cumulative round schedule of the audit.
        alpha (float): The risk limit of the audit.
        pr_H0_sched (List[float]): Bookkeeps the denominators of Wald's likelihood ratio.
        pa_Ha_sched (List[float]): Bookkeeps the numerators of Wald's likelihood ratio.
        risk_sched (List[float]): Bookkeeps the reciprocal of Wald's likelihood ratio,
            that is, the lowest alpha for which the audit would stop.
        k_min_sched (List[int]): A list of stopping rules respective to the round sizes.
    """
    
    N: int
    Ha_tally: int
    round_sched: List[int]
    alpha: float
    m: int
    H0_tally: int
    pr_H0_sched: List[float]
    pr_Ha_sched: List[float]
    risk_sched: List[float]
    k_min_sched: List[int]

    def __init__(self, N: int, Ha_tally: int, round_sched: List[int], alpha: float):
        self.N = N
        self.Ha_tally = Ha_tally
        self.round_sched = round_sched
        self.alpha = alpha

        self.check_params()

        self.m = len(round_sched)
        self.H0_tally = self.N // 2
        self.pr_H0_sched = [0] * self.m
        self.pr_Ha_sched = [0] * self.m
        self.risk_sched = [0] * self.m
        self.k_min_sched = [0] * self.m

        # For internal use
        self.H0_dists = []
        self.Ha_dists = []

    def check_inc_sched(self, sched):
        """ Returns True iff a list of numbers (the schedule) is strictly increasing.

        Args
            sched (List[int]): A schedule of round sizes (which should be strictly
            increasing).

        Returns
            bool: Whether the passed schedule is strictly increasing.
        """

        for i in range(1, len(sched)):
            if sched[i] <= sched[i - 1]:
                return False
        
        return True

    def check_params(self):
        """ Prints out notices about bad parameters.

        This method prints out a notice for obvious errors in the audit parameters,
        such as a negative N, or an out-of-bounds alpha.
        """
        
        # TODO: More cases?

        if self.N <= 0:
            print('Bad Parameter: N')
        
        if self.Ha_tally <= 0 or self.Ha_tally > self.N:
            print('Bad Parameter: Reported winner tally')
        
        if len(self.round_sched) < 1 or not self.check_inc_sched(self.round_sched):
            print('Bad Parameter: Round Schedule')

        if self.alpha <= 0 or self.alpha >= .5:
            print('Bad Parameter: Alpha')
    
    def compute_audit(self):
        """ The body of the audit procedure.

        The audit computation proceeds in three steps (twice over for each hypothesis):
        1. The distribution for the current round is computed as the distribution for the
        current draws convolved with the previous round's distribution.
        2. The stopping probability for the given k_min is summed.
        3. Values >= k_min are truncated, because they should not contribute to the future
        rounds' risks.
        """
        
        time = datetime.now()
        H0_dist = []
        Ha_dist = []

        for i in range(0, self.m):
            
            H0_dist = self.next_round_dist(True, H0_dist, i)
            Ha_dist = self.next_round_dist(False, Ha_dist, i)

            self.decide_k_min(H0_dist, Ha_dist, i)

            #self.truncate_dist(H0_dist, i)
            H0_dist = H0_dist[:self.k_min_sched[i]]
            #self.truncate_dist(Ha_dist, i)
            Ha_dist = Ha_dist[:self.k_min_sched[i]]
        
        #print("The outputs: k_mins, LR denominator, LR numerator, 1 / LR (or alpha').")
        #print(self.k_min_sched, '\n', self.pr_H0_sched, '\n', self.pr_Ha_sched, '\n', 
            #self.risk_sched)
        print("Output suppressed. Use instance variables k_min_sched, pr_H0_sched, pr_Ha_sched, risk_sched")

        print("Time elapsed:", datetime.now() - time)

    def next_round_dist(self, H0, dist, rnd_index):
        """ Calculates the distribution of the next round.

        This method calculates the probability distribution of the next round, given the
        probability distribution of the previous round (used for convolution).

        Args
            H0 (bool): Which hypothesis' distribution, True if the null.
            dist (List[float]): The previous round's probability distribution.
            rnd_index (int) The index of the next round. The first round has rnd_index 0.

        Returns
            List[float]: The next round's probability distribution for the given
                hypothesis.
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
            return convolve(dist, draws_dist, method='direct')
            #return fftconvolve(dist, draws_dist)

    def decide_k_min(self, H0_dist, Ha_dist, rnd_index):
        """ Decides the k_min of the round subject to the likelihood ratio constraint.

        A linear search finds the minimal k such that the likelihood ratio > 1 / alpha.
        Nothing is returned, rather the appropriate schedules (k_min, pr_H0, pr_Ha, risk)
        are all populated.

        Args
            H0_dist (List[float]): The null hypothesis' probability distribution.
            Ha_dist (List[float]): The alternative hypothesis' probability distribution.
            rnd_index (int): The index of the round. The first round has rnd_index 0.
        """

        self.H0_dists.append(copy.deepcopy(H0_dist))
        self.Ha_dists.append(copy.deepcopy(Ha_dist))
        #print("Deciding kmin for round index", rnd_index)

        # If you change the end bound to len(H0_dist) then that's an issue

        for k in range(self.round_sched[rnd_index] // 2 + 1, self.round_sched[rnd_index] + 1):
            #print("kmin?:", k)
            LR_num = 0
            LR_denom = 0
            for i in range(k, len(H0_dist)):
                LR_num += Ha_dist[i]
                LR_denom += H0_dist[i]
            
            delta = 1

            # FOR METIS
            #if (LR_num + self.pr_Ha_sched[max(rnd_index-1, 0)])/ (LR_denom + self.pr_H0_sched[max(rnd_index-1, 0)])> 1 / self.alpha:

            # FOR ATHENA
            #if LR_num / LR_denom > 1 / self.alpha and Ha_dist[k] > delta * H0_dist[k]:
            
            # The case of equality essentially only happens when both sides are 0. Then there's no harm
            # in calling it a kmin (since it necessarily won't contribute to the risk), in spite of the fact
            # that the ratio criterion cannot be satisfied because of division by zero.
            # GRANT COULD ALSO BE DENOM = 0 OR ALPHA NUM > DENOM short circuit



            # SENTINELS FOR WHEN THERE'S NO KMIN! if we get to the
            # end of the dist and there's no satisfaction just return SENTINEL

            # FOR MINERVA
            if self.alpha * LR_num >= LR_denom:

                self.k_min_sched[rnd_index] = k

                cumulative_H0_sched = self.pr_H0_sched[max(rnd_index-1, 0)]
                cumulative_Ha_sched = self.pr_Ha_sched[max(rnd_index-1, 0)]

                self.pr_H0_sched[rnd_index] = LR_denom + cumulative_H0_sched
                self.pr_Ha_sched[rnd_index] = LR_num + cumulative_Ha_sched

                # FOR MINERVA
                self.risk_sched[rnd_index] = LR_denom / LR_num

                # FOR METIS
                #self.risk_sched[rnd_index] = self.pr_H0_sched[rnd_index] / self.pr_Ha_sched[rnd_index]
                return


    def truncate_dist(self, dist, rnd_index):
        """ Truncates (or "lops off") the part of distributions >= k_min.

        So that certain sequences of ballots are not counted towards the risk more than
        once, this method truncates the tail of a given distribution.

        Args
            dist (List[float]): The round's probability distribution.
            rnd_index (int): The index of the round. The first round has rnd_index 0.
        """

        #for i in range(self.k_min_sched[rnd_index], self.round_sched[rnd_index]+1):
            #dist[i] = 0
        dist = dist[:self.k_min_sched[rnd_index]]

    def next_round(self, H0_dist, Ha_dist, cumulative_sprob):
        """
        # All of the past audi parameters can be gleaned from just the distributions.
        assert(len(H0_dist) == len(Ha_dist))
        last_round_size = len(H0_dist) - 1
        last_round_sprob = 0
        for y in Ha_dist:
            last_round_sprob += y
        last_round_sprob = 1 - last_round_sprob

        if last_round_sprob > cumulative_sprob:
            print("This cumulative stopping probability has already been attained.")

        # Start searching for satisfactory round sizes at last_round_size + 10, and
        # stop searching at last_round_size * 10 (surely there ought to be intermediate
        # rounds).
        for possible_round_size in range(last_round_size + 10, last_round_size * 10):
            draws = possible_round_size - last_round_size
            next_round_H0_dist = fftconvolve(binom.pdf(range(0, draws + 1), draws, 
                self.H0_tally / self.N), H0_dist)
            next_round_Ha_dist = fftconvolve(binom.pdf(range(0, draws + 1), draws,
                self.Ha_tally / self.N), Ha_dist)
        """

        # TODO: Finish implementation, including a refactoring of code that reduces
        # dependency on a round indices (because in next_round calculations none may
        # be available).

        # NOTE: All relevant parameters / properties of an audit can be gleaned from its
        # twin distributions: the most recent round size, the cumulative risk expended, 
        # and the cumulative stopping probability. The past round's k_min can be deduced
        # from the precipitous drop to a probability of 0.
            

def main():
    print("Currently this exploratory tool must be used in the interactive environment.")
    print("Type \"python3\" then \"from athena import *\" then:")
    print("x = Athena(N, reported winner tally, round schedule, k_min schedule)")
    print("And finally \"x.compute_risk()\"")
    print("The output will be the denominator of the LR, the numerator, and 1 / LR.")

if __name__== '__main__':
    main()