# brla_explore
exploratory code related to ballot-by-ballot RLAs and their approximations: round-by-round RLAs

We assume two candidates and no invalid ballots. Using other code in the brla_explore library, one may incorporate invalid votes. We believe we are also able to extend to multiple candidates, but that is for another day. 

## Properties of ballot-by-ballot audits
The folder BSquare Audits contains code to compute (without simulation) properties of audits that sample ballot by ballot. 

* Audits *with replacement* are computed assuming the maximum number of draws is 6ASN. (ASN is the theoretical expected number of ballots drawn for a BRAVO audit. About 4.5ASN is the theoretical 99th percentile). 

* For an audit *without replacement*, the size of the election needs to be provided, and is assumed to be the maximum number of ballots drawn. 

The properties computed are: 

1. **Stopping schedule:** For each sample size, beginning from a first sample size and incrementing by one ballot each time, the probability of stopping at that ballot draw for a given underlying election margin. 

2. **Risk schedule:** The above, when the margin is the smallest possible for an incorrect election. A draw (for even-sized elections) or a margin of a single vote in favor of the loser. 

3. **Stopping Probability:** the sum of the values of the stopping schedule, expected to be one. 

4. **Risk:** The sum of the values of the risk schedule, which, notably is smaller than the risk limit because the ballot draws are discrete-valued and hence the audit will not stop at exactly the required value of the likelihood ratio, but will stop at the first value that is not smaller than it. 

5. **No of Expected Ballots:** The scalar product of the stopping schedule and the vector of corresponding sample size. 

6. **No of Expected Ballots for Worst-Case Incorrect Election:** The scalar product of the risk schedule and the sample size vector, plus (1-Risk)(max number of draws). This is a lower bound on the value, and this is intended only as a sanity check. 

7. **Percentiles:** Desired percentile values may be computed from the stopping schedule and the risk schedule. 

To validate our mathematical approach and code we have computed these values for the BRAVO audit to compare them with Table 1 in the *BRAVO* paper. See: Tables/BRAVO Table I.pdf for the first five rows and Tables/BRAVO Table I.pdf for the next five rows. We have not yet completed the verification for a 1% margin. 

## The specification of a ballot-by-ballot audit for our code
As in Poorvi L. Vora, [Risk-Limiting Bayesian Polling Audits for Two Candidate Elections](https://arxiv.org/abs/1902.00999), an audit is specified by an array of sample sizes where stopping decisions are allowed, and corresponding values of *kmin* (minimum number of votes for the winner required to stop the audit). 

For example, an audit with rounds of sizes 100, 400 and 1000 ballots will have an array of sample sizes 100, 400 and 1000, which a ballot-by-ballot audit will allow stopping decisions at each draw and its array of sample sizes will be: 1, 2, 3, ..., *N* where *N* is the maximum number of ballots drawn. The corresponding values of *kmin* will be determined by the stopping rule. For example, the *BRAVO* stopping rule is likelihood ratio > 1/\alpha where \alpha is the risk limit, and the likelihood ratio depends on the size of the sample, the number of votes for the winner and the election margin. 

We include code for computing *n* and *kmin*, arrays for sample sizes beginning with the smallest size where a decision to stop is possible (usually all votes need to be for the winner to stop for the smallest possible sample size) and going on to the maximum number of ballots draws. At the moment, we support two types of audits: *BRAVO* and *BRAVOLike* (*BRAVO* without replacement, where the likelihood ratio is computed assuming without replacement). 

* The functions computing *n* and *kmin* for *BRAVO* and *BRAVOLike* are *BSquareBRAVOkmin* and *BSquareBRAVOLikekmin* respectively. The former requires only the margin and the risk limit as input, while the latter also requires election size. 

* For much of our code, we have wrappers to compute multiple outputs for different values of margin, risk limit and election size (each input as a row vector). Because arrays for *n* and (hence *kmin*) are not of the same size (the smallest sample size for a decision may not be the same even if some other parameters are), the wrapper code will output many arrays of different sizes in the form of a structured list of these arrays, shaped by the row vectors input representing margin, risk limit and election size. The code to compute many outputs has suffix "Many". 

To be completed. 


See also https://github.com/nealmcb/brla
