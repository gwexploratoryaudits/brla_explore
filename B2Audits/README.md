# brla_explore
exploratory code related to ballot-by-ballot (B2) RLAs

We assume two candidates and no invalid votes. 

Read the README for the parent directory, brla_explore, first. 

## Properties of ballot-by-ballot audits
The properties computed are: 

1. **Ballot-by-Ballot Stopping Schedule:** The probability of stopping at each ballot draw for a given underlying election margin. 

2. **Ballot-by-Ballot Risk Schedule:** The above, when the margin is the smallest possible for an incorrect election: a draw (for even-sized elections) or a margin of a single vote in favor of the loser. 

3. **Stopping Probability:** The probability that the audit stops: the sum of the values of the stopping schedule, expected to be one. 

4. **Total Risk:** The total risk of the audit for the worst-case election (draw or margin of one in favour of the loser). Computed as the sum of the values of the risk schedule. 

5. **No of Expected Ballots:** The scalar product of the stopping schedule and the vector of corresponding sample size. 

6. **No of Expected Ballots for Worst-Case Incorrect Election:** The scalar product of the risk schedule and the sample size vector, plus (1-Total Risk)(max number of draws). In the absence of knowledge of the size of the election, this is a lower bound on the value, a sanity check. 

7. **Percentiles:** Desired percentile values may be computed from the stopping schedule and/or the risk schedule. 

To validate our mathematical approach and code we have computed the values of Table 1 in the *BRAVO* paper. See: Tables/BRAVO Table I.pdf for the first five rows and Tables/BRAVO Table II.pdf for the next five rows. The largest fractional difference is smaller than 0.5\%, in estimating the expected number of ballots in simulations of audits for an election with a 1\% margin. 

*Note:* The properties we compute are properties for the entire audit, over all the draws, so we need to make an assumption regarding the number of draws: 

* Audits *with replacement* are computed assuming the maximum number of draws is 6ASN. (ASN is the theoretical expected number of ballots drawn for a BRAVO audit. The theoretical 99th percentile for elections with margins ranging from 40\% to 1\%, corresponds to about 4.36ASN to 4.65ASN ballots drawn). 

* For an audit *without replacement*, the size of the election needs to be provided, and is assumed to be the maximum number of ballots drawn. 

## Specification of an Audit. 

We use the idea of *kmin*s (minimum number of votes for the winner required in the sample to stop the audit) described in the parent directory, brla_explore. 

### Single Audits

  The functions computing *n* and *kmin* for *BRAVO* and *BRAVOLike* are *B2BRAVOkmin* and *B2BRAVOLikekmin* respectively. The former requires only the margin and the risk limit as input, while the latter also requires election size. 

  Try, for example: 

  `[n1, kmin1] = B2BRAVOkmin(0.4, 0.1);`

  to generate two arrays: `n1`: sample sizes and `kmin1`. 
  
  `kmin1(j)` is the minimum number of winner votes required in a sample of size `n1(j)` to stop a *BRAVO* audit with risk limit `0.1` and election margin `0.4`. 

  Similarly, 

  `[n2, kmin2] = B2BRAVOLikekmin(0.4, 0.1, 1000);`

  generates the same arrays for the same margin and risk limit and a `1000`-vote election for the *BRAVOLike* audit. *B2BravoLikekmin* also outputs the LogLikelihoodRatio, which may be used as a sanity check. 

### Multiple Audits

  For much of our code, we have wrappers to compute multiple outputs for different values of margin, risk limit and election size (each input as a row vector). Because arrays for *n* and (hence *kmin*) are not of the same size (the smallest sample size for a decision may not be the same even if some other parameters are), the wrapper code will output many arrays of different sizes in the form of a structured list of these arrays, shaped by the row vectors input representing margin, risk limit and election size. The wrapper code to compute multiple outputs has suffix "Many". We used it to verify the statistical properties of our implemented audits (for example, for the tables in Tables/BRAVO Table I.pdf and Tables/BRAVO Table II.pdf

  For multiple audits, for example, try: 

  `margins = [0.4, 0.3, 0.2, 0.16, 0.1];`

  `alpha = [0.1];`

  `[nBRAVO, kminBRAVO] = B2BRAVOkminMany(margins, alpha);`

  to obtain two lists of *5* arrays: *nBRAVO* and *kminBRAVO*

  `nBRAVO{i,s}` is the array of sample sizes for `margin(i)` and risk limit `alpha(s)`

  `kminBRAVO{i,s}` is the array of corresponding values of minimum winner votes needed to stop. 

  You thus obtain values of *n* and *kmin* for *5* audits, and could obtain *10* audits by using 
  
  `alpha2 = [0.1,0.05];`
  
  and
  
  `[nBRAVO2, kminBRAVO2] = B2BRAVOkminMany(margins, alpha2);`

  to obtain two lists of *10* arrays: *nBRAVO2* and *kminBRAVO2*

  For *BRAVOLike* you would need election size as well: 
  
  `N=[1000]`
  
  `[nBRAVOLike, kminBRAVOLike] = B2BRAVOLikekminMany(margins, alpha, N);`
  
  for a 1000-vote election. 
  
  You could use more than one election size: 
  
 `N2=[1000,10000];`

  and: 
  
 `[nBRAVOLike2, kminBRAVOLike2] = B2BRAVOLikekminMany(margins, alpha2, N2);`
  
  to obtain two 5 X 2 X 2 lists of arrays: *nBRAVOLike* and *kminBRAVOLike*

  `nBRAVOLike2{i,s,t}` is the array of sample sizes for `margin(i)`, risk limit `alpha2(s)` and `N2(t)`

  `kminBRAVOLike2{i,s,t}` is the array of corresponding values of minimum winner votes needed to stop. 

  You thus obtain values of *n* and *kmin* for *20* audits. 

Thus one may input ones own audit(s) defined by one or more pairs of arrays of *n* and corresponding *kmin*, or use our code to generate these arrays for multiple margins, risk limits and election sizes for *BRAVO* or *BRAVOLike* audits (and, hopefully, Bayesian audits in the future). 

## Stopping Probabilities and Risk
B2 audits allow the possibility of stopping at each ballot draw. 

* If the election is incorrect, the possibility of stopping at each draw allows for the incurring of risk at each draw, by erroneously stopping the audit. 

* On the other hand if the election is correct, there is also a probability of (correctly) stopping at each draw. 

In either case, there is a probability of stopping at each draw, which depends on: the *kmin* array, whether the audit is with or without replacement, and the underlying election margin. When the margin is zero, this probability corresponds to worst-case risk. We refer to this sequence of probabilities as the stopping probability schedule or the risk schedule respectively. 

The respective sums give us the total stopping probability of the specified audit for the specified underlying election. When the underlying election has zero margin, this total stopping probability is the risk. Notably, we observe that this is often strictly smaller than the risk limit because the ballot draws are discrete-valued. The audit will not stop at exactly the required value of the likelihood ratio, but at the first value not smaller than it, this leads to a slight reduction in risk for each ballot draw when compared to the risk if the audit always stopped at exactly the required value. 

### Single Audits

We include code for computing these schedules for single audits, called B2Risks. 

Try, using the above computed values of *kmin* and *n*: 

`[StopSched1, StopValue1, ExpectedBallots1] = B2Risks(0.4, N, n1, kmin1, 0)`

to obtain the array `StopSched1` of the *BRAVO* schedule of stopping probabilities, `StopValue1` its sum, expected to be very close to 1 and representing the total probability of the audit stopping, and `ExpectedBallots`, the expected number of ballots drawn, for an underlying election of margin 0.4, which this audit, defined by `n1` and `kmin1`, was designed for. The value `N` is a dummy variable and does not affect the answers. The last argument, `0`, represents an audit with replacement. 

Similarly, you could try: 

`[StopSched2, StopValue2, ExpectedBallots2] = B2Risks(0.4, N, n2, kmin2, 1)`

for the *BRAVOLike* single audit. 

You may also use other values for `margin`, or use `1` (without replacement) to see what you would get were the audit used in a setting different from the one it was designed for. Using `margin=0` will give you the risk schedule, total risk and a lower bound on the number of expected ballot draws when the underlying election is tied. 

`[RiskSched1, RiskValue1, ExpectedBallotsInCorrect1] = B2Risks(0, N, n1, kmin1, 0)`

gives you the risk schedule, total risk and expected ballots for a worst-case incorrect election for the *BRAVO* audit computed for a margin of *0.4* and a risk limit of *0.1*. 

### Multiple Audits

As described earlier for the generation of *kmin* values, we can use wrapper code to perform the above for multiple audits. You may try, for *BRAVO*: 

`[StopSchedBRAVO, StopProbBRAVO, ExpectedBallotsCorrectBRAVO] = B2RisksMany(margins, N, nBRAVO, kminBRAVO, 0);`

`margin_incorrect = zeros(1,size(margins,2));`
`[RiskSchedBRAVO, RiskValueBRAVO, ExpectedBallotsInCorrectBRAVO] = B2RisksMany(margin_incorrect, N, nBRAVO, kminBRAVO, 0);`

and, for *BRAVOLike*: 

`[StopSchedBRAVOLike, StopProbBRAVOLike, ExpectedBallotsCorrectBRAVOLike] = B2RisksMany(margins, N, nBRAVOLike, kminBRAVOLike, 1);`

`[RiskSchedBRAVOLike, RiskValueBRAVOLike, ExpectedBallotsInCorrectBRAVOLike] = B2RisksMany(margin_incorrect, N, nBRAVOLike, kminBRAVOLike, 1);`

You may compare the `ExpectedBallotsCorrectBRAVO` values, also listed in Tables/BRAVO Table I.pdf, with entries in the first five rows of Table 1 in the *BRAVO* paper. 

## Stopping Percentiles

We compute the cumulative distribution function from the stopping or risk schedules, and can then use the inverse CDF to compute a specified percentile. For example, 

`percentiles = [0.25, 0.5, 0.75, 0.9, 0.99];`

`stopping_values = StoppingPercentiles(n1, StopSched1, percentiles)`

will compute the first row of percentiles in Table 1 of the *BRAVO* paper by first computing `CDF = CumDistFunc(StopSched1);` then `stopping_values =InverseCDF(CDF,percentiles);` and then correcting `stopping_values` because `n1(1)` is not *1*, and the first sample size is larger than one, while the `CDF` and `InverseCDF` functions are with respect to array index `j` and not value of `n1(j)`. 

This too can be done for multiple audits, and you can try: 

`BRAVOTable = StoppingPercentilesMany(nBRAVO,StopSchedBRAVO,percentiles);`

to obtain our estimates of the percentile columns of the first five rows of Table 1 of the *BRAVO* paper. `ExpectedBallotsCorrectBRAVO` from the previous computation of `B2Risks` and `ASNmany(margins,[0.1])` will give you the other columns in the Table. 

To obtain a similar five rows for the *BRAVOLike* audit, try: 

`BRAVOLikeTable = StoppingPercentilesMany(nBRAVOLike,StopSchedBRAVOLike, percentiles);`

and `ExpectedBallotsCorrectBRAVOLike` will give you the expected ballots. See: `Tables/BRAVO-BRAVOLike 1K Table 1.pdf` for a comparison of these values.  

We may also compute risk percentiles. It makes most sense to compute the risk percentiles for the risk limit; that is, find values that reach 25\% of the risk limit, 50\% of the risk limit, etc. Try, for example, 

`risk_percentiles = alpha(1,1)*percentiles;`

and

`BRAVORiskTable = StoppingPercentilesMany(nBRAVO,RiskSchedBRAVO, risk_percentiles);`

`BRAVOLikeRiskTable = StoppingPercentilesMany(nBRAVOLike,RiskSchedBRAVOLike, risk_percentiles);`

From the Scripts folder try scripts `B2BRAVOTestScript`, which does all of the above for *BRAVO*, and B2RiskScript which does it all for `BRAVO` and *BRAVOLike*. See our results in the various pdf files in Tables/

## Log-Likelihood (Ignore if not curious)
The *BRAVOLike* audit requires the computation of the ratio of hypergeometric probabilities for the stopping decision, see equation (5), [Risk-Limiting Bayesian Polling Audits for Two Candidate Elections](https://arxiv.org/abs/1902.00999), with beta = 0. Because hypergeometric probabilities can be very small for our values, and because we are really interested in the ratio (each probability is a likelihood, and the ratio is the likelihood ratio) we do not use hypergeometric probability functions. 

Instead, we simplify the expression by canceling out common factors in the numerator and denominator, and compute only the product of ratios that are not too extreme in value. However, we see that there may be too many products and that can also pose a problem. We finally chose to compute these products as sums in the log domain and to obtain the Log-Likelihood Ratio (LLR). Also, we make sure to check for zeros in the denominator, and get a constant value of *kmin* once *kmin* reaches one more than half the number of votes.  

## Verification Through Simulations

This is ongoing by other members of the team. 

See also https://github.com/nealmcb/brla
