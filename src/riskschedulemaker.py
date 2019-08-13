# Grant McClearn
# Last Edited: August 13, 2019

''' A program which aids in producing a risk schedule to be used in convolutionauditnew.py.
    The risk schedule is how the risk limit is apportioned or allotted among the rounds.
    For example, a valid risk schedule for a 5-round audit with risk limit 5% is
    [.01, .01, .01, .01, .01], and so each round gets to contribute 1% risk to the
    overall risk limit. '''

class Risk_Schedule:
    
    def __init__(self, risk_limit, schedule_length, schedule_type, schedule_parameter):
        ''' Inputted parameters '''
        self.risk_limit = risk_limit
        self.schedule_length = schedule_length
        self.schedule_type = schedule_type
        self.schedule_parameter = schedule_parameter

        ''' From the inputted parameters we immediately derive the risk schedule. '''
        self.schedule = self.normalize(self.decode_type())
    
    def decode_type(self):
        ''' There are different types of risk schedules, and different risk schedules are optimal
        in different situations (margins). One inputted parameter is the desired type of risk schedule
        (e.g., uniform, increasing arithmetically, decreasing arithmetically, increasing or decreasing
        geometrically). '''
        type_mapping = {
            # Type 0 is the uniform risk schedule. All rounds are allotted the same amount of risk.
            # This is an attractive "baseline" risk schedule. The schedule parameter does not affect the
            # uniform risk schedule.
            0: [1] * self.schedule_length,
            # Type 1 is the increasing arithmetically (linearly) risk schedule. Each round is allotted
            # c more risk than the previous round, where c is a constant (the common difference).
            # If the schedule parameter p (valid when p > -1) is less than 0, the per-round increment
            # is amplified; if p > 0, the per-round increment is dampened (and so if p = infinity we have
            # the uniform risk schedule). If p = 0, then round i (where i is an integer in [1, m] where m
            # is the number of audit tiers) is allotted i times as much risk than the first round.
            1: [i + self.schedule_parameter for i in range(1, self.schedule_length + 1)],
            # Type 2 is the decreasing arithmetically (linearly) risk schedule. One can think of it as
            # the increasingly arithmetically (linearly) risk schedule, except reversed. The schedule
            # parameter behaves as it does in the increasing arithmetically case.
            2: [i + self.schedule_parameter for i in range(self.schedule_length, 0, -1)],
            # Type 3 is the geometric (exponential) risk schedule. Each round is allotted r times more
            # risk than the round before it, where r is the constant (the common ratio).
            # The schedule parameter is r, and it must be > 0.
            3: [self.schedule_parameter ** i for i in range(1, self.schedule_length + 1)]
        }

        return type_mapping[self.schedule_type]
        

    def normalize(self, unnorm_schedule):
        ''' The risk schedule after the type is selected reflects the structure of our desied allottment,
        but the schedule is not yet normalized so as to sum to the risk limit. This method divides each
        element by the amount such that the sum of the risks in the risk schedule equals the risk limit. '''
        sum = 0
        for round_risk in unnorm_schedule:
            sum += round_risk
        return [round_risk / (sum / self.risk_limit) for round_risk in unnorm_schedule]

    def test_sum(self):
        ''' For testing purposes. The sum should be (less than but very close to) the risk limit. '''
        sum = 0
        for round_risk in self.schedule:
            sum += round_risk
        return sum

def main():
    rs = Risk_Schedule(.05, 9, 2, 0)
    print(rs.schedule)
    print(rs.test_sum())


if __name__ == '__main__':
    main()