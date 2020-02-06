"""
Sarah Morin
6/11/2019

Class for working with Bayesian RLAs in elections with multiple candidate elections and/or invalid votes.
"""


from scipy.stats import hypergeom as hg
import numpy as np


class brla:

    def __init__(self, total_votes: int):
        """
        Initialize election for audit using Bayesian RLA.
            @param total_votes: Total number of votes cast in a given election.

            @return: Election audit object with given total size and Bayesian RLA
            prior distribution as NumPy array

        Testing

        >>> audit = brla(1.5)
        Traceback (most recent call last):
            ...
        TypeError: Total votes in election must be integer value
        >>> audit = brla(10000)
        >>> audit.total_votes
        10000
        >>> audit.prior
        array([0.    , 0.    , 0.    , ..., 0.0001, 0.0001, 0.0001])
        """
        # Type check total vote count for integer
        if type(total_votes) is not int:
            raise TypeError('Total votes in election must be integer value')

        self.total_votes = total_votes
        # Bayesian RLA prior
        self.get_prior()

    def get_error(self, stop: int, audit: int, invalid: int = 0) -> float:
        """
        Get error value assosciated with stopping size and audit round.
        Error is calcualted using a prior distribution (as described above)
        and a posterior ditribution generated using the hypergeometric distribution
        and prior distribution. The posterior distribution is then normalized and
        the assocaited error (or risk) is calculated.

            @param stop: (integer) stopping value to calculate error for. Should have
            stop < audit.

            @param audit: Size of current audit round, i.e. size of sample which will
            be taken during audit.

            @param invalid: Accounts for invalid votes found during audit.
            Optional, default set to 0

            @return: error value assosciated with given audit round and stopping size.
            Calcualted using method described in Bayesian RLA paper (Vora).

        Testing

        >>> brla(100000).get_error(120, 200)
        0.09300233755889373
        >>> brla(100000).get_error(2.5, 10)
        Traceback (most recent call last):
            ...
        TypeError: Parameters stop, audit, invalid must be integers values.
        >>> brla(100000).get_error(10, 10.5)
        Traceback (most recent call last):
            ...
        TypeError: Parameters stop, audit, invalid must be integers values.
        >>> brla(100000).get_error(25, 100, 2.7)
        Traceback (most recent call last):
            ...
        TypeError: Parameters stop, audit, invalid must be integers values.
        """
        # type checking
        if type(stop) is not int or type(audit) is not int or type(invalid) is not int:
            raise TypeError("Parameters stop, audit, invalid must be integers values.")

        if invalid > 0:
            # Recalculate prior for invlaid votes
            self.get_prior(invalid)

        # Get posterior distribution
        posterior = np.array(hg.pmf(stop, self.total_votes-invalid, range(0, (self.total_votes-invalid)+1), audit-invalid))
        posterior = posterior*self.prior
        posterior /= sum(posterior)

        return sum(posterior[range((self.total_votes-invalid)//2 + 1)])

    def get_stopping_size(self, audit_size: int, risk: float, invalid: int = 0) -> int:
        """
        Get stopping size for audit round which meets given risk limit using prior
        distribution for Bayesian RLA. Uses binary search to test various stopping size
        values and verify that calcualted error is less than or equal to risk limit.

            @param audit_size: (integer) number of votes sampled from all votes in
            election

            @param risk: Risk limit for audit. Risk (error) associated with stopping
            value should be less than or equal to risk.

            @param ivalid: Accounts for invalid votes found during audit.
            Optional, default set to 0

            @return: (integer) number of votes needed to stop audit at given audit size
            and risk limit

        Testing

        >>> brla(10000).get_stopping_size(100, 0.1)
        64
        >>> brla(10000).get_stopping_size(10.5, 0.1)
        Traceback (most recent call last):
            ...
        TypeError: Parameters audit_size and invalid must be integer values.
        >>> brla(10000).get_stopping_size(10, 0.1, 0.6)
        Traceback (most recent call last):
            ...
        TypeError: Parameters audit_size and invalid must be integer values.
        >>> brla(10000).get_stopping_size(10, 10, 10)
        Traceback (most recent call last):
            ...
        TypeError: Parameter risk must be float.
        """
        # type checking
        if type(audit_size) is not int or type(invalid) is not int:
            raise TypeError("Parameters audit_size and invalid must be integer values.")
        if type(risk) is not float:
            raise TypeError("Parameter risk must be float.")

        # Left and right pointers used for binary search
        left = (audit_size-invalid)//2
        right = audit_size-invalid

        # Continue searching while pointers are different or stopping size is found
        while left < right:
            # Test stopping size halfway between pointers
            test_stop = (left+right)//2
            # Get error value for current stop size
            test_error = self.get_error(test_stop, audit_size, invalid)

            # If this value meets the risk limit, return this stopping value
            if test_error == risk:
                return test_stop

            # If this value is less than the risk limit, test a samller stopping size
            # More error to work with
            if test_error < risk:
                # Get error for stopping size - 1
                prev_error = self.get_error(test_stop-1, audit_size, invalid)
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

    def get_prior(self, invalid: int = 0) -> np.ndarray:
        """
        Get Bayesian RLA prior distribution. Represents worst case scenario where
        election is a tie or margin of one vote.

            @param invalid: integer value of invalid votes found during audit.
            Default set to 0.

            @return: updates prior attribute to new prior distribution
            (possible given invalid vote value)

        Testing

        >>> brla(10000).get_prior(20)
        >>> brla(10000).get_prior(12.5)
        Traceback (most recent call last):
            ..
        TypeError: Invalid vote count must be an integer
        """
        if type(invalid) is not int:
            raise TypeError("Invalid vote count must be an integer")

        self.prior = np.concatenate((np.zeros((self.total_votes-invalid)//2, dtype=float), np.array([0.5]), np.array(
            [(0.5/((self.total_votes-invalid)-((self.total_votes-invalid)//2))) for j in range((self.total_votes-invalid)-((self.total_votes-invalid)//2))])), axis=None)

    def lookup_table(self, audit_rounds: np.ndarray, risk_limits: np.ndarray, invalid: int = 0, print_table=False) -> np.ndarray:
        """
        Generate lookup table of kmin vlaues for audit.

            @param audit_rounds: array/list of integer audit round sizes.
            Columns of lookup table.

            @param risk_limits: array/list of risk limits (floats).
            Rows of lookup table.

            @param invalid: integer number of invalid votes found in election.
            (Optional, default = 0)

            @param print_table: Option to print (with better formatting than simple
            print() function) table instead of simply return table.
            (Optional, default set to False)

        Testing

        >>> brla(100000).lookup_table([200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200], [0.1, 0.05, 0.005])
        array([[  120,   230,   443,   863,  1691,  3331,  6585, 13049, 25897],
               [  122,   232,   447,   868,  1698,  3339,  6596, 13063, 25913],
               [  127,   239,   456,   880,  1715,  3363,  6627, 13103, 25957]])
        >>> brla(100000).lookup_table([200, 400, 800, 1600, 3200, 6400, 12800, 25600, 51200], [0.1, 0.05, 0.005], 20)
        array([[  109,   219,   433,   853,  1681,  3321,  6574, 13039, 25887],
               [  111,   221,   436,   857,  1687,  3329,  6585, 13053, 25903],
               [  115,   228,   445,   870,  1704,  3352,  6617, 13093, 25947]])
        >>> brla(10).lookup_table([2.5, 10], [0.1])
        Traceback (most recent call last):
            ...
        TypeError: Audit rounds must be integers.
        >>> brla(10).lookup_table([5, 10], [2, 3])
        Traceback (most recent call last):
            ...
        TypeError: Risk limits must be floats
        >>> brla(10).lookup_table([5, 10], [0.1], 10, 10)
        Traceback (most recent call last):
            ...
        TypeError: print_table must be boolean (True/False)
        """

        # Type checking
        if not all(isinstance(n, int) for n in audit_rounds):
            raise TypeError('Audit rounds must be integers.')
        if not all(isinstance(n, float) for n in risk_limits):
            raise TypeError('Risk limits must be floats')
        if type(invalid) is not int and type(invalid) is not float:
            raise TypeError('Invalid vote count must be integer or float.')
        if type(print_table) is not bool:
            raise TypeError('print_table must be boolean (True/False)')

        lookup = np.zeros((len(risk_limits), len(audit_rounds)), dtype=int)

        for r in range(len(risk_limits)):
            for a in range(len(audit_rounds)):
                if type(invalid) is int:
                    lookup[r][a] = self.get_stopping_size(audit_rounds[a], risk_limits[r], invalid)
                else:
                    lookup[r][a] = self.get_stopping_size(audit_rounds[a], risk_limits[r], int(audit_rounds[a]*invalid))

        if print_table:
            col = np.concatenate((np.array([0]), np.array(risk_limits)), axis=None)
            col = np.reshape(col, (len(col), 1))
            rows = np.concatenate((np.array((audit_rounds), ndmin=2), lookup), axis=0)
            table = np.concatenate((col, rows), axis=1)
            np.set_printoptions(suppress=True)
            print(table)

        return lookup


def main():
    import doctest
    doctest.testmod()


if __name__ == '__main__':
    main()
