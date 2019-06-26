import numpy as np

"""
Multivaraite Hypergeometric Distribution Sampling
"""


class multivhyper:

    def __init__(self, counts):
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

        Testing

        >>> multivhyper([1, 2, 3.5])
        Traceback (most recent call last):
            ...
        TypeError: Unsupported type for counts: must be list of ints or dict with int values
        >>> multivhyper({'A':2, 'B':1, 'C':3.66})
        Traceback (most recent call last):
            ...
        TypeError: Unsupported type for counts: must be list of ints or dict with int values
        >>> audit1 = multivhyper([10, 20, 10])
        >>> audit1.counts
        array([10, 20, 10])
        >>> audit1.types
        >>> audit1.size
        40
        >>> audit1.props
        array([0.25, 0.5 , 0.25])
        >>> audit2 = multivhyper({'A':10, 'B':20, 'C':10})
        >>> audit2.counts
        array([10, 20, 10])
        >>> audit2.types
        array(['A', 'B', 'C'], dtype='<U1')
        >>> audit2.size
        40
        >>> audit2.props
        array([0.25, 0.5 , 0.25])
        """
        # Type checking for list or dict and integer values
        if type(counts) is list and all(isinstance(n, int) for n in counts):
            self.counts = np.array(counts, dtype=int)
            self.types = None
        elif type(counts) is dict and all(isinstance(n, int) for n in list(counts.values())):
            self.types = np.array(list(counts.keys()))
            self.counts = np.array(list(counts.values()), dtype=int)
        else:
            raise TypeError('Unsupported type for counts: must be list of ints or dict with int values')

        self.size = sum(self.counts)
        self.props = self.counts/self.size

    def sample(self, size: int, print_sample: bool = False) -> np.ndarray:
        """
        Sample from distribtion.

            @param size: Size of desired sample (integer)

            @param print_sample: Boolean, determines if sample (and types if applicable)
            should be printed before returning sample. Good for testing.

            @return: Sample (as NumPy array of integer counts) from distribution. Each
            entry in list represents count of that element type in sample.

        Testing

        >>> audit = multivhyper([10, 20, 10])
        >>> audit.sample(10.5)
        Traceback (most recent call last):
            ...
        TypeError: Sample size must be integer value
        >>> audit.sample(100)
        Traceback (most recent call last):
            ...
        ValueError: Sample size is too large
        >>> audit = multivhyper({'A':10, 'B':20, 'C':10})
        >>> audit.sample(10.5)
        Traceback (most recent call last):
            ...
        TypeError: Sample size must be integer value
        >>> audit.sample(100)
        Traceback (most recent call last):
            ...
        ValueError: Sample size is too large
        """
        # Test for integer size
        if type(size) is not int:
            raise TypeError("Sample size must be integer value")
        # Test if sample size is too large, return if canot get large enough sample from current dist.
        if size > self.size:
            raise ValueError('Sample size is too large')

        # Initiliaze empty list of sample counts and set initial sample size to 0
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

    def cdf(self) -> np.ndarray:
        """
        Calcualte CDF of current distribution

            @return: NumPy array (of floats) with length equal to the number of
            element types in distribution which represents the CDF.

        Testing

        >>> audit = multivhyper([10, 20, 10])
        >>> audit.cdf()
        array([0.25, 0.75, 1.  ])
        """

        return np.array([sum(self.props[:i+1]) for i in range(len(self.props))])

    def print_status(self):
        """
        Method to print current status of dsitribution. Mainly for testing,
        useful after sampling.
        """
        print("Current total size: ", self.size, '\n')
        print("Counts: ")
        if self.types is not None:
            print(self.types)
        print(self.counts, '\n')
        print("Distribution: ", self.props.round(3), '\n')


def main():
    import doctest
    doctest.testmod()


if __name__ == '__main__':
    main()
