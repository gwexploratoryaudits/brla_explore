# brla_explore
exploratory code related to ballot-by-ballot RLAs and their approximations: round-by-round RLAs

We assume two candidates and no invalid votes. Using other code in the brla_explore library, one may incorporate invalid votes. We believe we are also able to extend to multiple candidates, but that is for another day. 

## Properties of ballot-by-ballot audits
The folder BSquare Audits contains code to compute (without simulation) properties of audits that sample ballot by ballot. These are properties for the entire audit, over all the draws, so we need to make an assumption regarding the number of draws. 

* Audits *with replacement* are computed assuming the maximum number of draws is 6ASN. (ASN is the theoretical expected number of ballots drawn for a BRAVO audit. About 4.5ASN is the theoretical 99th percentile). 

* For an audit *without replacement*, the size of the election needs to be provided, and is assumed to be the maximum number of ballots drawn. 

The properties computed are: 

1. **Ballot-by-Ballot Stopping Schedule:** Incrementing by one ballot each time, the probability of stopping at a ballot draw for a given underlying election margin. 

2. **Ballot-by-Ballot Risk Schedule:** The above, when the margin is the smallest possible for an incorrect election: a draw (for even-sized elections) or a margin of a single vote in favor of the loser. 

3. **Stopping Probability:** The probability that the audit stops: the sum of the values of the stopping schedule, expected to be one. 

4. **Total Risk:** The total risk of the audit for the worst-case election (draw or margin of one in favour of the loser). Computed as the sum of the values of the risk schedule. Notably, this is smaller than the risk limit because the ballot draws are discrete-valued. (The audit will not stop at exactly the required value of the likelihood ratio, but at the first value not smaller than it, this leads to a slight reduction in risk for each ballot draw). 

5. **No of Expected Ballots:** The scalar product of the stopping schedule and the vector of corresponding sample size. 

6. **No of Expected Ballots for Worst-Case Incorrect Election:** The scalar product of the risk schedule and the sample size vector, plus (1-Total Risk)(max number of draws). This is a lower bound on the value, a sanity check. 

7. **Percentiles:** Desired percentile values may be computed from the stopping schedule and/or the risk schedule. 

To validate our mathematical approach and code we have computed the values of Table 1 in the *BRAVO* paper. See: Tables/BRAVO Table I.pdf for the first five rows and Tables/BRAVO Table I.pdf for the next five rows. We have not yet completed the verification for a 1% margin. 

## The specification of a ballot-by-ballot audit for our code
As in Poorvi L. Vora, [Risk-Limiting Bayesian Polling Audits for Two Candidate Elections](https://arxiv.org/abs/1902.00999), an audit is specified by an array of sample sizes where stopping decisions are allowed, and corresponding values of *kmin* (minimum number of votes for the winner required to stop the audit). 

* For example, an audit with rounds of sizes 100, 400 and 1000 ballots will have an array of sample sizes 100, 400 and 1000. It may have *kmin* values of 60, 230 and 520 respectively, which imply that one would stop the audit in the first round if and only if the number of ballots for the winner in the sample were 60 or larger; in the second round if it were 230 or larger and in the last round if it were 520 or larger. 

* For another example, a ballot-by-ballot audit will allow stopping decisions at each draw and its array of sample sizes will be: 1, 2, 3, ..., *N* where *N* is the maximum number of ballots drawn. The corresponding values of *kmin* will be determined by the stopping rule. For example, the *BRAVO* stopping rule is likelihood ratio > 1/\alpha where \alpha is the risk limit, and the likelihood ratio depends on the size of the sample, the number of votes for the winner and the election margin. 

We include code for computing:

* *n*: array of sample sizes beginning with the smallest size where a decision to stop is possible (usually all votes need to be for the winner to stop for the smallest possible sample size) and going on to the maximum number of ballots draws. 

* *kmin*: a corresponding array of minimum votes required for the winner to stop the audit.  

At the moment, we support two types of audits: 

* *BRAVO* and 
* *BRAVOLike* (*BRAVO* without replacement, where the likelihood ratio is also computed assuming ballots are drawn without replacement). 

We have the following for computing *n* and *kmin*: 

* The functions computing *n* and *kmin* for *BRAVO* and *BRAVOLike* are *BSquareBRAVOkmin* and *BSquareBRAVOLikekmin* respectively. The former requires only the margin and the risk limit as input, while the latter also requires election size. 

  Try, for example: 

  `[n, kmin] = BSquareBRAVOkmin(0.4, 0.1);`

  to generate two arrays: `n`: sample sizes and `kmin`, the corresponding minimum number of winning votes needed to stop a *BRAVO* audit with risk limit `0.1` for an election with margin `0.4`. 

  Similarly, 

  `[n, kmin] = BSquareBRAVOLikekmin(0.4, 0.1, 1000);`

  generates the same arrays for the same margin and risk limit and a `1000`-vote election. 

* For much of our code, we have wrappers to compute multiple outputs for different values of margin, risk limit and election size (each input as a row vector). Because arrays for *n* and (hence *kmin*) are not of the same size (the smallest sample size for a decision may not be the same even if some other parameters are), the wrapper code will output many arrays of different sizes in the form of a structured list of these arrays, shaped by the row vectors input representing margin, risk limit and election size. The wrapper code to compute multiple outputs has suffix "Many". 

  For multiple audits, for example, try: 

  `margins = [0.4, 0.3, 0.2, 0.16, 0.1];`

  `alpha = [0.1, 0.05];`

  `[nBRAVO, kminBRAVO] = BSquareBRAVOkminMany(margins, alpha);`

  to obtain two 5 X 2 lists of arrays: *nBRAVO* and *kminBRAVO*

  `nBRAVO{i,s}` is the array of sample sizes for `margin(i)` and risk limit `alpha(s)`

  `kmin{i,s}` is the array of corresponding values of minimum winner votes needed to stop. 

  You thus obtain values of *n* and *kmin* for *10* audits. 

  For *BRAVOLike* you would need election size as well, and might wish to add: 

  `N=[1000,10000];`

  and: 

  `[nBRAVOLike, kminBRAVOLike] = BSquareBRAVOLikekminMany(margins, alpha, N);`

  to obtain two 5 X 2 X 2 lists of arrays: *nBRAVOLike* and *kminBRAVOLike*

  `nBRAVO{i,s,t}` is the array of sample sizes for `margin(i)`, risk limit `alpha(s)` and `N(t)`

  `kmin{i,s,t}` is the array of corresponding values of minimum winner votes needed to stop. 

  You thus obtain values of *n* and *kmin* for *20* audits. 

Thus one may input ones own audit(s) defined by one or more pairs of arrays of *n* and corresponding *kmin*, or use our code to generate these arrays for multiple margins, risk limits and election sizes for *BRAVO* or *BRAVOLike* audits. 

## To be continued. 


See also https://github.com/nealmcb/brla
