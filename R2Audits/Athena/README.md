# Athena
exploratory code related to the *Athena* class of round-by-round RLAs

The code here assumes sampling with replacement. That is, we assume two candidates and no invalid votes. 

The folder Scripts contains scripts for use in elections with multiple candidates and irrelevant (including invalid) votes. These scripts call the appropriate code for two candidates and no invalid votes, using the appropriate parameters. It also contains some of the data for real elections, including the 2016 Presidential election by state, and the 2020 primaries for Montgomery County, Ohio. 

The folder Tables contains our comparisons of first round sizes for Athena and R2 *BRAVO*, for some states that might perform ballot polling audits for the Presidential election in 2020, using data from the 2016 Presidential election. The data for the 2016 Presidential election and estimated first round sizes for all states are in the Scripts folder.  

## The *Athena* Class of Audits

*BRAVO* and *Bayesian* audits are designed for use as B2 audits; their stopping rules may be viewed as comparison tests of ratios of likelihood or posterior probabilities respectively. The *Athena* class of audits, on the other hand, is based on ratios of the tails of distributions. We can show that this can greatly improve efficiency. In fact, when compared to *BRAVO*, *Athena* requires only about half the number of ballots for a 90\% stopping probability across a wide range of margins. 

Consider a two-contestant contest with no invalid votes. Let `p` be the announced fractional tally for the winner. Suppose `n1` ballots are drawn in the first round. Denote by `k1` the number of votes drawn for the winner. Suppose `n1=300` and `p=0.75` (corresponding to a margin of `0.5`). Figure 1 shows the probability distribution of `k1` given that the election is (a) as announced for `p = 0.75`, and (b) a tie. Recall that the tied election is the wrong election outcome that is hardest to distinguish from the announced one. (See [Risk-Limiting Bayesian Polling Audits for Two Candidate Elections](https://arxiv.org/abs/1902.00999)). Observe that, if `k1=30`, `Pr[k1=30|margin=0.5] = 0.0077` and `Pr[k1=30|margin=0.5] = 0.0419`. 
 
![Figure 1: Probability Distribution of Winner Votes for `p=0.75` and `n1=300`: First Round](fig/round1.png)

See also https://github.com/nealmcb/brla
