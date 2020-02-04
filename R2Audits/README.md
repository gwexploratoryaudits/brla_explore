# brla_explore
exploratory code related to round-by-round RLAs

We assume two candidates and no invalid votes. 

Read the README file for B2Audits first. 

## Properties of round-by-round audits
The properties computed are: 

1. **Round-by-Round Stopping Schedule:** The probability of stopping at each round for a given round schedule and underlying election margin. 

2. **Round-by-Round Risk Schedule:** The above, when the margin is the smallest possible for an incorrect election: a draw (for even-sized elections) or a margin of a single vote in favor of the loser. 

3. **Stopping Probability:** The probability that the audit stops: the sum of the values of the stopping schedule, expected to be one. 

4. **Total Risk:** The total risk of the audit for the worst-case election (draw or margin of one in favor of the loser). Computed as the sum of the values of the risk schedule. 

5. **No of Expected Ballots:** The scalar product of the stopping schedule and the vector of corresponding sample size. 

6. **No of Expected Ballots for Worst-Case Incorrect Election:** The scalar product of the risk schedule and the sample size vector, plus (1-Total Risk)(max number of draws). In the absence of knowledge of the size of the election, this is a lower bound on the value, a sanity check. 

7. **Percentiles:** Desired percentile values may be computed from the stopping schedule and/or the risk schedule. 

*Note:* The properties we compute are properties for the entire audit, over all the draws, so we need to make an assumption regarding the number of draws: 

[AND?]

## Specification of an Audit. 

We use the idea of *kmin*s (minimum number of votes for the winner required in the sample to stop the audit) described in the parent directory, brla_explore. 

### Single Audits

 The functions computing *kmin* for a given round schedule in the form of *n_in* for *BRAVO* and *BRAVOLike* are *R2BRAVOkmin* and *R2BRAVOLikekmin* respectively. The former requires only the margin, risk limit and round schedule as input, while the latter also requires election size. 
 
 For *BRAVO*, unlike in the B2 case where the *kmin* values are computed for as many as 6*ASN ballot draws, in the R2 case we only compute *kmin* for sizes specified by the round schedule (*n_in*). As a consequence, it is possible (though virtually impossible in reality) that none of the rounds will be large enough for the audit to stop (because one will need more than round size ballot draws to make a decision). This does not happen in the B2 case because we ensure we compute *kmin* values for a large enough number of ballot draws (6*ASN). 

  Try, for example: [TBD]

  ### Multiple Audits

  For the *BRAVO* code, we have wrappers to compute multiple outputs for different values of margin, risk limit and round schedule (each input as a row vector). Because arrays for *n* and (hence *kmin*) are not of the same size (the smallest sample size for a decision may not be the same even if some other parameters are), as in B2Audits, the wrapper code will output many arrays of different sizes in the form of a structured list of these arrays, shaped by the row vectors input representing margin, risk limit and round schedule. The wrapper code to compute multiple outputs has suffix "Many".  We anticipate its use in generating statistics to demonstrate the inefficiencies when compared to *B2BRAVO*. 

  For multiple audits, for example, try: [TBD]

## Stopping Probabilities and Risk
R2 audits allow the possibility of stopping at each round. 

* If the election is incorrect, the possibility of stopping at each round allows for the incurring of risk at each round, by erroneously stopping the audit. 

* On the other hand if the election is correct, there is also a probability of (correctly) stopping at each round. 

In either case, there is a probability of stopping at each round, which depends on: the round schedule, corresponding *kmin* schedule, whether the audit is with or without replacement, and the underlying election margin. When the margin is zero, this probability corresponds to worst-case risk. We refer to this sequence of probabilities as the stopping probability schedule (or the risk schedule for zero margin). 

The respective sums give us the total stopping probability of the specified audit for the specified underlying election. When the underlying election has zero margin, this total stopping probability is the risk. Notably, we observe that this is strictly smaller than the risk limit when using *kmin* values derived for B2audits. 

We include code for computing these schedules for single audits, called R2Risks. 

Try, using the above computed values of *kmin* and *n_in*: 

TBD

## Stopping Percentiles

Using code in the B2Audits folder, we may compute the cumulative distribution function from the stopping or risk schedules, and can then use the inverse CDF to compute a specified percentile. For example, 

TBD

## Verification Through Simulations

This is ongoing by other members of the team. 

See also https://github.com/nealmcb/brla
