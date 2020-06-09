from scipy.stats import hypergeom

''' This program calculates k_mins for the BRAVO-like RLA without replacement at points of interest.
    If you are sampling at the extremes, be careful to note that:
        the first k_min is the lowest value such that 
        if all votes sampled were for the reported winner, the audit could stop; 
        and the last k_min is half of N.
    To help with bookkeeping, we print the actual number of k_mins the audit has. This is always less
    than N, because, for instance, after drawing one ballot--even if for the winner--the audit won't stop.'''

class RLA:
    def __init__(self):
        # rhs = 1 / risk limit
        self.rhs = (1) / .05
        self.num = 1
        self.denom = 0
        self.samples = range(0, 10000)
        self.k_mins = []

        self.N = 10000
        self.p1N = 5500
        self.halfN = int(self.N/2)

        self.calculate_k_mins()

    def calculate_k_mins(self):
        # For each point at which we want to compute the BRAVO-like k_min without replacement...
        for sample in self.samples:
            # we do a linear search for the lowest k_min satisfying the likelihood ratio.
            for k in range(int(sample/2), sample + 1):
                self.num = hypergeom.pmf(k, self.N, self.p1N, sample)
                self.denom = hypergeom.pmf(k, self.N, self.halfN, sample)

                if self.denom == 0:
                    break

                if self.num/self.denom >= self.rhs:
                    self.k_mins.append(k)
                    #print("Completed k_min for sample", sample, "and it is", k)
                    break
        print(self.k_mins)
        print("There are", len(self.k_mins), "k_mins. ")

def main():
    bravo_rla = RLA()

if __name__ == '__main__':
    main()