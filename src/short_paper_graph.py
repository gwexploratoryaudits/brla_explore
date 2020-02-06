# Sarah Morin
# Code for generating data amd graph
# for shorter version of paper

import math
import csv
import numpy as np 
import matplotlib.pyplot as plt
from scipy.stats import hypergeom as hg

def sprt_replacement(N, p, alpha, beg, end):
    """
    SPRT RLA with replacement 
    """ 
    kmins = np.zeros(((end-beg)+1), dtype=int)
    tolerance = (1-alpha)/alpha # Corresponds to beta = alpha 

    for n in range(beg, end+1):
        half_n = int(math.floor(n/2))
        for k in range(half_n, n+1):
            ratio = ((p**k)*((1-p)**(n-k)))/(0.5**n)
            if ratio > tolerance:
                kmins[n-beg] = k
                break 
            elif k == n:
                kmins[n-beg] = n

    return kmins

def sprt_no_replacement(N, p, alpha, beg, end):
    """
    SPRT RLA without replacement 
    """
    kmins = np.zeros(((end-beg)+1), dtype=int)
    # TODO rest of this test 
    return None

def brla(N, alpha, beg, end):
    """
    Bayesian RLA with uniform prior
    """
    prior = np.concatenate((np.zeros(N//2, dtype=float), np.array([0.5]), np.array(
            [(0.5/(N//2)) for j in range(N//2)])), axis=None)
    kmins = np.zeros(((end-beg)+1), dtype=int)
    
    for n in range(beg, end+1):
        half_n = int(math.floor(n/2))
        half_N = int(math.floor(N/2))
        for k in range(half_n, n+1):
            dist = [hg.pmf(k, N, s, n) for s in range(N+1)]
            bayes_posterior = np.array(dist, dtype=float)
            bayes_posterior*= prior 
            bayes_posterior = bayes_posterior/sum(bayes_posterior)
            risk = sum(bayes_posterior[:half_N+1])
            if risk < alpha:
                kmins[n-beg] = k
                break
            elif k == n:
                kmins[n-beg] = n

    return kmins

def bayesian(N, alpha, beg, end):
    """
    Bayesian audit with uniform prior 
    """
    prior = np.ones((N+1), dtype=float)*(1/N+1)
    kmins = np.zeros(((end-beg)+1), dtype=int)
    
    for n in range(beg, end+1):
        half_n = int(math.floor(n/2))
        half_N = int(math.floor(N/2))
        for k in range(half_n, n+1):
            # bayes_posterior = np.array((hg.pmf(k, N, s, n) for s in range(0, N+1)), dtype=float)
            dist = [hg.pmf(k, N, s, n) for s in range(N+1)]
            bayes_posterior = np.array(dist, dtype=float)
            bayes_posterior*= prior 
            bayes_posterior = bayes_posterior/sum(bayes_posterior)
            risk = sum(bayes_posterior[:half_N+1])
            if risk < alpha:
                kmins[n-beg] = k
                break
            elif k == n:
                kmins[n-beg] = n

    return kmins

if __name__=="__main__":
    """
    Generate table of data and graphs for each of the 4 audits for an election where:
        N = 100 total ballots
        alpha = 0.001 
        beg = 9
        end = 75
        sample sizes = increment by 1 from beg to end
        p = 0.75 
    """
    
    rounds = np.arange(9, 76)

    """ Generating Data 
    sprt_repl_data = sprt_replacement(100, 0.75, 0.001, 9, 75)
    sprt_norepl_data = sprt_no_replacement(100, 0.75, 0.001, 9, 75)
    brla_data = brla(100, 0.001, 9, 75)
    bayesian_data = bayesian(100, 0.001, 9, 75)

    with open('short_paper_data.csv', mode='w') as csv_file:
        fields = ['audit']
        sprt_repl_row = ['sprt_repl']
        sprt_norepl_row = ['sprt_norepl']
        brla_row = ['brla']
        bayesian_row = ['bayesian']
        for i in range(len(rounds)):
            fields.append(str(rounds[i]))
            sprt_repl_row.append(str(sprt_repl_data[i]))
            # sprt_norepl_row.append(str(sprt_norepl_data[i]))
            brla_row.append(str(brla_data[i]))
            bayesian_row.append(str(bayesian_data[i]))
            

        print(fields)
        writer = csv.writer(csv_file, delimiter=',', quotechar='"', quoting=csv.QUOTE_MINIMAL)
        
        writer.writerow(fields)
        writer.writerow(sprt_repl_row)
        writer.writerow(sprt_norepl_row)
        writer.writerow(brla_row)
        writer.writerow(bayesian_row)
    """

    """ Plotting Data """
    with open('short_paper_data.csv', mode='r') as csv_file:
        reader = csv.reader(csv_file, delimiter=',')
        ln = -1
        for row in reader:
            ln += 1
            if ln == 0:
                continue
            elif ln == 1:
                sprt_repl_data = np.array(row[1:], dtype=int)
            elif ln == 2:
                sprt_norepl_data = np.array(row[1:], dtype=int)
            elif ln == 3:
                brla_data = np.array(row[1:], dtype=int)
            else:
                bayesian_data = np.array(row[1:], dtype=int)

    plt.plot(rounds, sprt_repl_data, 'm+', label='SPRT (with replacement)')
    # plt.plot(rounds, sprt_norepl_data, 'yo', label='SPRT (without replacement)')
    plt.plot(rounds, brla_data, 'bo', label='Bayesian RLA')
    plt.plot(rounds, bayesian_data, 'c*', label='Bayesian')    
    plt.plot(rounds, rounds, 'k-', label='n = k')

    plt.xlabel('Sample Size, n')
    plt.ylabel('Minimum number of votes for winner to accept, k')
    plt.legend(loc='best')
    plt.title('Number of winner votes needed to stop audit as a function of sample size; 100 votes cast, 2 candidates')
    
    # --------- Graph Options -------------
    # Fitted axis limits
    plt.axis([5, 80, 5, 60])

    # Gridlines
    plt.grid()

    # -------------------------------------
    plt.show()   


