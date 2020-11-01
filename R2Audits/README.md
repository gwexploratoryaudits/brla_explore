# brla_explore/R2Audits
exploratory code related to round-by-round RLAs

We assume two candidates and no invalid votes. Almost all our R2 work is for audits with replacement. Most of our code for BRAVO as an R2 audit is for EoR (end-of-round) BRAVO. This directory contains more general code for round-by-round audits. For code specific to Athena, see the Athena subdirectory. 

Read the README file for B2Audits first. 

## Properties of round-by-round audits
The properties computed are: 

1. **Round-by-Round Stopping Schedule:** The probability of stopping at each round for a given round schedule and underlying election margin. 

2. **Round-by-Round Risk Schedule:** The above, when the margin is the smallest possible for an incorrect election: a draw (for even-sized elections) or a margin of a single vote in favor of the loser. For audits without replacement, as in the literature, we always assume a winning vote fraction of a half (margin of zero)

3. **Stopping Probability:** The probability that the audit stops: the sum of the values of the stopping schedule. Unlike for B2 audits, where we compute a large enough schedule ensuring that the audit ends, in this case the value need not be one. 

4. **Total Risk:** The total risk of the audit for the worst-case election (draw or margin of one in favor of the loser). Computed as the sum of the values of the risk schedule. For an RLA, we would expect this to be smaller than the risk limit. 

5. **No of Expected Ballots:** The scalar product of the stopping (or risk) schedule and the sample size vector, plus (1-Total Risk)*N (or (1-Stopping)*N when we consider that the underlying election is not tied), which assumes that once the given round schedule is exhausted, if the election has not stopped, there will be a full hand count of `N` ballots. 

6. **Percentiles:** Desired percentile values may be computed from the stopping schedule and/or the risk schedule. 

## Specification of an Audit. 

We use the idea of `kmin`s (minimum number of votes for the winner required in the sample to stop the audit) described in the parent directory, brla_explore. 

### Single Audits

 The functions computing `kmin` for a given round schedule in the form of `n_in` for *BRAVO* is `R2BRAVOkmin`. We also wrote code for *BRAVOLike* audits, `R2BRAVOLikekmin`, but have not tested it and it now lies in the Unused folder. `R2BRAVOkmin` requires only the margin, risk limit and round schedule as input. 
 
 For *BRAVO*, unlike in the B2 case where the `kmin` values are computed for as many as 6*ASN ballot draws, in the R2 case we only compute `kmin` for sizes specified by the round schedule (`n_in`). Thus the audit may not stop by the end of the schedule. *BRAVO* in this instance refers to EoR (end-of-round) BRAVO, where the BRAVO stopping condition is tested on the final sample for the round. 
 
  Try, for example: 
  
  `[kmslope,kmintercept,n_out,kmin] = R2BRAVOkmin(0.4, 0.1, [1, 7, 56, 106]);`
  
  And notice that `n_out` is smaller than `n_in` because a round size of `1` will not stop at all. Further, notice that the first value in `kmin` is exactly the first value of `n_out`, thus, for this round size all votes will need to be for the winner to stop. 

  ### Multiple Audits

  For the *BRAVO* code, `R2BRAVOkminMany`, we have wrappers to compute multiple outputs for different values of margin, risk limit and round schedule (each input as a row vector). Because arrays for `n` and (hence `kmin`) are not of the same size (the smallest sample size for a decision may not be the same even if some other parameters are), as in B2Audits, the wrapper code will output many arrays of different sizes in the form of a structured list of these arrays, shaped by the row vectors input representing margin, risk limit and round schedule. We anticipate its use in generating statistics to demonstrate the inefficiencies when compared to *B2BRAVO*. 

  For multiple audits, for example, try: 
  
  
 `margins = [0.4, 0.3, 0.2];`
 
  `alpha = 0.1;`
  
  `n_in_Many{1,1} = [1, 7, 56, 106];`
  
 `n_in_Many{2,1} = [1, 9, 58];` 
 
 `n_in_Many{3,1} = [1, 13, 62];`
 
 `[n_out_Many,kmin_Many] = R2BRAVOkminMany(margins, alpha, n_in_Many);`


## Stopping Probabilities and Risk
R2 audits allow the possibility of stopping at each round. 

* If the election is incorrect, the possibility of stopping at each round allows for the incurring of risk at each round, by erroneously stopping the audit. 

* On the other hand if the election is correct, there is also a probability of (correctly) stopping at each round. 

In either case, there is a probability of stopping at each round, which depends on: the round schedule, corresponding `kmin` schedule, whether the audit is with or without replacement, and the underlying election margin. When the margin is zero, this probability corresponds to worst-case risk. We refer to this sequence of probabilities as the stopping probability schedule (or the risk schedule for zero margin). 

The respective sums give us the total stopping probability of the specified audit for the specified underlying election. When the underlying election has zero margin, this total stopping probability is the risk. Notably, we observe that this is strictly smaller than the risk limit when using `kmin` values derived for B2audits. This behavior is described at length in our [*Athena*](https://arxiv.org/abs/2008.02315) paper. 

We include code for computing these schedules for single audits, called `R2RisksConvolution`, which uses the convolution of the current probability distribution of winner votes and the distribution of the winner votes in the new draw to compute a new probability distribution which will be used for risk and stopping probability computations. In the directory R2Audits/Athena is code to perform the same computation using the Fourier transform, `R2RisksWithReplacement`. The RiskSched computed by both should be the same, however we have not performed extensive checks to confirm this. 

Try, using the above computed values of `kmin` and `n_out`, to compute the RiskSched for a tied election: 

`[RiskSched, RiskValue, ExpectedBallots] = R2RisksConvolution(0, 1000, n_out_Many{1,1}, kmin_Many{1,1}, 0);`

and compare it to the same computed using the Fourier Transform: 

`[RiskSched2, CurrentTier] = R2RisksWithReplacement(0, n_out_Many{1,1}, kmin_Many{1,1});`

The variable `CurrentTier` returned is the pdf of winner votes after the round schedule is complete. 

## Stopping Percentiles

Using code in the B2Audits folder, we may compute the cumulative distribution function from the stopping or risk schedules, and can then use the inverse CDF to compute a specified percentile. For example, 

`percentiles = [0.5, 0.7, 0.8];`

`stopping_values = StoppingPercentiles(n_out_Many{1,1}, RiskSched, percentiles);`

## Verification Through Simulations

This is ongoing by other members of the team. 

See also https://github.com/nealmcb/brla
