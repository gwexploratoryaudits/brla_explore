# Athena
exploratory code related to the *Athena* class of round-by-round RLAs

The code here assumes sampling with replacement. That is, we assume two candidates and no invalid votes. 

The folder Scripts contains scripts for use in elections with multiple candidates and irrelevant (including invalid) votes. These scripts call the appropriate code for two candidates and no invalid votes, using the appropriate parameters. The folder also contains some of the data for real elections, including the 2016 Presidential election by state, and the 2020 primaries for Montgomery County, Ohio, and our first round estimates for their audits. The folder Tables contains comparisons of first round sizes for Athena and R2 *BRAVO*, for some chosen states that might perform ballot polling audits for the 2020 Presidential election. 

## The *Athena* Class of Audits

*BRAVO* and *Bayesian* audits are designed for use as B2 audits; their stopping rules may be viewed as comparison tests of ratios of likelihood or posterior probabilities respectively. The *Athena* class of audits, on the other hand, is based on ratios of the tails of distributions. We can show that this greatly improves efficiency. In fact, when compared to *R2 BRAVO*, *Athena* requires only about half the number of ballots for a 90\% stopping probability across a wide range of margins. It also improves upon the efficiency of *BRAVO* rules apply ballot-by-ballot when applied to ballots drawn in rounds, which implies that, when ballots are drawn in rounds, keeping track of the order of the samples is not useful for the stopping condition. 

Consider a two-contestant contest with no invalid votes. Let `x` be the announced fractional tally for the winner. 

Suppose the risk limit of the audit is <img src="https://render.githubusercontent.com/render/math?math= \large \alpha=0.1">

Suppose `n1` ballots are drawn in the first round. Denote by `k1` the number of votes drawn for the winner. Suppose `n1=50` and `x=0.75` (corresponding to a margin of `0.5`). Figure 1 shows the probability distributions of `k1` given that the election is (a) as announced for `x = 0.75` (blue solid curve), and (b) a tie (red dashed curve). Recall that the tied election is the wrong election outcome that is hardest to distinguish from the announced one, and hence defines the worst-case risk. (See [Risk-Limiting Bayesian Polling Audits for Two Candidate Elections](https://arxiv.org/abs/1902.00999)). Observe that, if `k1=32`, `Pr[k1=32 | margin=0.5] = 0.0264` and `Pr[k1=32 | margin=0] = 0.0160`. 
 
![Figure 1: Probability Distribution of Winner Votes for `x=0.75` and `n1=50`: First Round](fig/graph_athena_tails.png)

The *BRAVO* p-value is defined as the ratios of the probabilities: 

<img src="https://render.githubusercontent.com/render/math?math=\Large \frac{Prob(k1=32 \mid margin = 0)}{Prob(k1=32 \mid margin = 0.5)} = \frac{0.0160}{0.0264} = 0.6076 > \alpha">

Thus the sample does not satisfy the stopping condition for *BRAVO*. 

The *Athena* p-value is defined as the ratio of the tails, (red solid tail divided by blue semi-transparent tail)

<img src="https://render.githubusercontent.com/render/math?math=\Large \frac{Prob(k1 \geq 32 \mid margin = 0)}{Prob(k1 \geq 32 \mid margin = 0.5)} = \frac{0.0325}{0.9713} = 0.0334 < \alpha">

And the sample satisfies the *Athena* stopping condition. 

The above provides an explanation for the simplest application of the *Athena* class of audits: the first round. The math for later rounds is somewhat more complicated, and we get to it soon. 

## Why do we claim that *Athena* is risk-limiting? 

We have shown in [Risk-Limiting Bayesian Polling Audits for Two Candidate Elections](https://arxiv.org/abs/1902.00999) that the ratio

<img src="https://render.githubusercontent.com/render/math?math=\Large \frac{Prob(k1 \mid margin=0)}{Prob(k1 \mid margin)}">

decreases with `k1` if `margin > 0.5`. That is, the tied election is less likely than the announced one for larger `k1`. Thus if we choose to stop for a particular value of `k1=32`, we should stop for larger values as well, because the announced election is even more likely for those. 

So if we decide to stop at `k1=32`: 

* The *stopping probability* (the probability that the audit will stop given that the election is as announced) is the tail of the solid blue curve, the translucent blue area, because it includes the probabilities of larger values of `k1`. 

<img src="https://render.githubusercontent.com/render/math?math=\large S_1 = Prob(k1 \geq 32 \mid margin = 0.5)">

where <img src="https://render.githubusercontent.com/render/math?math=\large S_i"> denotes the stopping probability for round *i*. 

* The *risk* (the probability that the audit will stop given that the election is tied) is the tail of the dashed red curve, the solid red area, because it includes the probabilities of larger values of `k1`. 

<img src="https://render.githubusercontent.com/render/math?math=\large R_1 = Prob(k1 \geq 32 \mid margin = 0)">

where <img src="https://render.githubusercontent.com/render/math?math=\large R_i"> denotes the risk for round *i*.  

Our stopping condition ensures that the risk is smaller than <img src="https://render.githubusercontent.com/render/math?math=\large \alpha"> times the stopping probability: 

<img src="https://render.githubusercontent.com/render/math?math=\large R_1 \leq \alpha S_1">

If we can guarantee this for every round, that is, if our stopping condition ensures that: 

<img src="https://render.githubusercontent.com/render/math?math=\large R_i \leq \alpha S_i \forall i">

then: 

<img src="https://render.githubusercontent.com/render/math?math=\large R = \sum _i R_i \leq \alpha \sum _i S_i  = \alpha S \leq \alpha ">

where <img src="https://render.githubusercontent.com/render/math?math=\large R, S"> are the total risk and stopping probability respectively, and, as stopping probability of the audit, <img src="https://render.githubusercontent.com/render/math?math= \large S \leq 1">. 

That is, the total risk will be the sum of the risks of each individual round. Each of these risks is smaller than <img src="https://render.githubusercontent.com/render/math?math=\large \alpha"> times the corresponding stopping probability. Adding all the risks gives us the total risk, which is smaller than <img src="https://render.githubusercontent.com/render/math?math=\large \alpha"> times the total stopping probability. Because the total stopping probability cannot be larger than one, the total risk cannot be larger than <img src="https://render.githubusercontent.com/render/math?math=\large \alpha">. 

See also https://github.com/nealmcb/brla
