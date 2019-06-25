import numpy as np

"""
Multivaraite Hypergeometric Distribution Sampling
"""


class multivhyper:

    """
    Initialize multiv. hyperg. distribution object.

        @param counts: Can be list of integers or dict of element type names
        (keys) and integers (values). The list or dict values are the counts of
        each type elementin the distribution. Length of list indidicates number
        of element types. Total sum of intgers of list gives initial size of
        distribution.

        @return: multivaratie hypergeometic distribution object with following
        attributes:
            - counts: Numpy array of current element counts (integers)
            - types: (if initialized using dict) numpy array of element types
                    (if initialized using list) None
            - size: current size of distribution, i.e. total number of elements
            in distribution (integer)
            - props: Numpy array of proportions of each element within the
            distribution (floats)
    """

    def __init__(self, counts):
        # Type checking for list or dict and integer values
        if type(counts) is list and all(isinstance(n, int) for n in counts):
            self.counts = np.array(counts, dtype=int)
            self.types = None
        elif type(counts) is dict and all(isinstance(n, int) for n in list(counts.values())):
            self.types = np.array(list(counts.keys()))
            self.counts = np.array(list(counts.values()), dtype=int)
        else:
            print('Unsupported type for counts: must be list of ints or dict with int values')
            return

        self.size = sum(self.counts)
        self.props = self.counts/self.size

    """
    Sample from distribtion.

        @param size: Size of desired sample (integer)

        @param print_sample: Boolean, determines if sample (and types if applicable)
        should be printed before returning sample. Good for testing.

        @return: Sample (as NumPy array of integer counts) from distribution. Each
        entry in list represents count of that element type in sample.
    """

    def sample(self, size: int, print_sample: bool = False) -> np.ndarray:
        # Test for integer size
        if type(size) is not int:
            print("Sample size must be integer value")
            return None
        # Test if sample size is too large, return if canot get large enough sample from current dist.
        if size > self.size:
            print("Sample size too large")
            return None

        # Initiliaze empty list of sample counts and set initial sample size to 0
        # sample_counts = [0 for i in self.counts]
        sample_counts = np.zeros(len(self.counts), dtype=int)
        sample_size = 0

        # Sample from distribution until we reach the requested sample size
        while(sample_size < size):

            # Generate random float between 0 and 1
            #   will determine which element type to add to the sample
            rand = np.random.random()
            # Calculate CDF of current dsitribution
            cdf = self.cdf()

            # Select an element type to add to th current sample
            for i in range(len(self.counts)):

                # If the random number is in a given element types CDF range
                # and there are elemtns of that type remaining in the distribtion
                if rand < cdf[i] and self.counts[i] > 0:
                    # Add current element type to sample
                    sample_counts[i] += 1
                    # Remove from dsitribution
                    self.counts[i] -= 1
                    # Recaucluate proportions in distribution
                    self.props = self.counts/self.size
                    # increment sample size
                    sample_size += 1
                    # decrement distribution size
                    self.size -= 1
                    break

        if print_sample:
            print("Sample of ", size)
            if self.types is not None:
                print(self.types)
            print(sample_counts)

        return sample_counts

    """
    Calcualte CDF of current distribution

        @return: NumPy array (of floats) with length equal to the number of
        element types in distribution which represents the CDF.
    """

    def cdf(self) -> np.ndarray:
        # Return list of runing total of proportions at each element type
        return np.array([sum(self.props[:i+1]) for i in range(len(self.props))])

    """
    Method to print current status of dsitribution. Mainly for testing,
    useful after sampling.
    """

    def print_status(self):
        print("Current total size: ", self.size, '\n')
        print("Counts: ")
        if self.types is not None:
            print(self.types)
        print(self.counts, '\n')
        print("Distribution: ", self.props.round(3), '\n')


if __name__ == '__main__':
    # Test the creation of distribution and sampling
    dist1 = multivhyper([40000, 40000, 20000])
    dist1.print_status()
    # dist1.sample(100, True)

    dist2 = multivhyper({'A': 20, 'B': 12, 'C': 30})
    dist2.print_status()
    dist2.sample(2000000, True)
    # dist2.sample(10, True)

    dist3 = multivhyper({'A': 1, 'B': 1.2, 'C': 3})
