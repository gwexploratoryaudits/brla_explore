'''
# Sarah Morin
# Last Edited: 9/4/2019

Class to compare kmin values and stopping probabilities of the convlution audit
and a BRAVO audit where the audit is limited to 1 round of a given size.
'''

import numpy as np
from scipy.stats import hypergeom, binom
import matplotlib.pyplot as plt
from convolutionaudit import Convolution_Audit as conv
import math


class stoppingcompare:

    def __init__(self, N: int, margin: float, rounds, risk_limit: float):
        '''
        Initialize object with election information and round sizes to investigate

        @param N: Size of election, i.e. total votes cast

        @param margin: Reported winning margin (or tally) of the election

        @param rounds: Round sizes for which to calculate kmin and an associated
        stopping probability

        @param risk_limit: Risk limit for each audit
        '''

        # Initialize basic paramete values
        self.N = N
        self.margin = margin
        self.rounds = rounds
        self.risk_limit = risk_limit

        # Create arrays to hold kmin and sprob values
        self.bravo_kmins = np.zeros(len(rounds), dtype=int)
        self.conv_kmins = np.zeros(len(rounds), dtype=int)
        self.conv_sprobs = np.zeros(len(rounds), dtype=float)
        self.bravo_sprobs = np.zeros(len(rounds), dtype=float)
        self.bravo_sprobs_unique = np.zeros(len(rounds), dtype=float)

    def makegraphs(self):
        '''
        Create 2 graphs: 1 comparing kmins, 1 comparing stopping probabilities
        for those kmins
        '''

        # Get BRAVO kmin value and stopping porbability for each round for margin
        # Calculated as BRAVO w/ replacement
        win_portion = (self.margin+1.)/2.
        kw = math.log(win_portion/0.5)
        kl = math.log((1-win_portion)/0.5)
        stop = math.log(1/self.risk_limit)

        for i in range(len(self.rounds)):
            # Calculate kmin value
            self.bravo_kmins[i] = (stop-self.rounds[i]*kl)/(kw-kl)

            # Calculate stopping porbability
            self.bravo_sprobs[i] = self.bravo_sprob_all(self.rounds[i], self.bravo_kmins[i])

            # Alternate stopping porbability for true ballot by ballot idea
            '''
            kmin_1 = (stop-(self.rounds[i]-1)*kl)/(kw-kl)
            self.bravo_sprobs_unique[i] = self.bravo_sprob_unique(self.rounds[i], self.bravo_kmins[i], kmin_1)
            '''

        # Get convlution audit kmins and stopping probabilities
        # using 1 round audit for each given round size
        for i in range(len(self.rounds)):
            # Get kmin using convolutionaudit.py
            audit = conv(self.N, [self.rounds[i]], [self.risk_limit])
            audit.conduct_audit()
            self.conv_kmins[i] = audit.k_mins[0]

            # Get stopping probability for kmin and given margin
            # Get distribution for election with given margin
            margin_dist = hypergeom.pmf(range(0, self.rounds[i]+1), self.N, win_portion*self.N, self.rounds[i])

            # Get stopping probability assuming given margin
            sprob = 0
            for k in range(self.conv_kmins[i], self.rounds[i]+1):
                sprob += margin_dist[k]

            self.conv_sprobs[i] = sprob

        # Display both graphs
        self.display_graphs()

        # Alternate, display graphs separately (mostly for testing)
        # self.kmins_graph()
        # self.sprobs_graph()

    def bravo_sprob_all(self, n, kmin):
        '''
        Function to calculate stopping porbability of BRAVO audit using simple
        unorded sampling with replacement (Binomial Distribution). Essentially
        get the probability of getting at least kmin successes in a sample of n.

        @param n: round size (or number of trials/selections in binomial dist.)

        @param kmin: kmin calculated by BRAVO audit for n

        @return: probability of getting at least kmin votes for winner in sample
        of n, i.e. probability of stopping. (Sum of binomial pmf from kmin on)
        '''
        binomial_dist = binom.pmf(range(0, n+1), n, (self.margin+1.)/2.)
        return sum(binomial_dist[kmin:])

    def bravo_sprob_unique(self, n, kmin, kmin_1):
        '''
        Function to calculate stopping porbability of BRAVO if executed ballot
        by ballot. Calculates the porbability of the last ballot being drawn for
        winner and reaching the stopping value at that ballot, never before.

        Ex: We can only reach a sample of 200 ballots if we do not have enough
        ballots for the winner at 199. So before drawing the 200th ballot we can
        have at most 1 less than the kmin at 199. In order to stop at 200, the
        200th ballot must be for the winner and kmin at 199 = kmin at 200.
        This will be 0 in many cases.

        @param n: current round/sample size

        @param kmin: kmin value for n ballots

        @param kmin_1: kmin value for n-1 ballots

        @return: probability of stopping at exactly the nth ballot.
        '''
        if kmin != kmin_1:
            return 0.
        prev_round = binom.pmf(kmin_1-1, n-1, (self.margin+1.)/2.)
        return prev_round*(self.margin+1.)/2.

    def kmins_graph(self):
        '''
        Function for formatting and displaying kmin graph.
        '''
        plt.plot(self.rounds, self.bravo_kmins, 'ro', label='BRAVO')
        plt.plot(self.rounds, self.conv_kmins, 'bo', label='Convolution')

        plt.xlabel('Round Size')
        plt.ylabel('Kmin')
        plt.legend(loc='best')
        plt.grid()
        plt.suptitle('Kmins (given margin)')
        plt.show()

    def sprobs_graph(self):
        '''
        Function for formatting and displaying stopping prob graph.
        '''
        plt.plot(self.rounds, self.bravo_sprobs, 'ro', label='BRAVO')
        plt.plot(self.rounds, self.conv_sprobs, 'bo', label='Convolution')

        plt.xlabel('Round Size')
        plt.ylabel('Stopping Probability')
        plt.legend(loc='best')
        plt.grid()
        plt.suptitle('Stopping Probabilities (given margin)')
        plt.show()

    def display_graphs(self):
        '''
        Function for formatting and displaying both graphs at once.
        '''
        plt.figure(1)

        plt.subplot(121)
        plt.plot(self.rounds, self.bravo_kmins, 'ro', label='BRAVO')
        plt.plot(self.rounds, self.conv_kmins, 'bo', label='Convolution')

        plt.xlabel('Round Size')
        plt.ylabel('Kmin')
        plt.legend(loc='best')
        plt.grid()
        plt.title('Kmins (given margin)')

        plt.subplot(122)
        plt.plot(self.rounds, self.bravo_sprobs, 'ro', label='BRAVO')
        plt.plot(self.rounds, self.conv_sprobs, 'bo', label='Convolution')

        plt.xlabel('Round Size')
        plt.ylabel('Stopping Probability')
        plt.legend(loc='best')
        plt.grid()
        plt.title('Stopping Probabilities (given margin)')

        plt.show()


def main():
    tester = stoppingcompare(100000, 0.2, [100, 200, 400, 800, 1600, 3200], 0.05)
    tester.makegraphs()

    # Printing true data
    print("Convolution")
    print(tester.conv_kmins)
    print(tester.conv_sprobs)
    print()
    print("BRAVO")
    print(tester.bravo_kmins)
    print(tester.bravo_sprobs)


if __name__ == '__main__':
    main()
