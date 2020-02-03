# brla_explore
exploratory code related to ballot-by-ballot RLAs and their approximations: round-by-round RLAs

We assume two candidates and no invalid votes. 

The folder B2 Audits contains code to compute (without simulation) properties of audits that sample *ballot-by-ballot* (as opposed to *round-by-round*). Ballot-by-Ballot (or B2) audits make decisions (re: whether to stop the audit or not) at every ballot draw. For example, the theoretical versions of [*BRAVO*](https://www.usenix.org/system/files/conference/evtwote12/evtwote12-final27.pdf) and [*Bayesian Risk Limiting Audits*](https://arxiv.org/abs/1902.00999) are B2 audits.  

The folder R2 Audits contains code to compute (without simulation) properties of audits that sample *round-by-round*, making decisions (re: whether to stop the audit or not) after drawing a round of tens of ballots (in a single location) or even thousands across a state. Many real election audits are R2 audits, applying decision rules developed for B2 audits. This results in considerable inefficiency. 

## The specification of an audit for our code
One may think of an audit as a set of rounds: a round is defined as a the sampling of a number of ballots (the round size) followed by a decision of whether to: 

(a) stop drawing ballots and declare the election outcome correct or

(b) begin another round--draw some more ballots. 

For example: 

* A B2 audit consists of many rounds, each of size one ballot. After each ballot draw, a decision is made whether to stop the audit or draw one more ballot. 

* An R2 audit with rounds of sizes 100, 400 and 1000 ballots will allow stopping decisions only at 100, 400 and 1000 ballots, and not after, say, drawing the first 50 ballots. 

As described in [Risk-Limiting Bayesian Polling Audits for Two Candidate Elections](https://arxiv.org/abs/1902.00999), we specify an audit by an array of sample sizes and corresponding values of *kmin* (minimum number of votes for the winner required to stop the audit). Thus, for the above examples, 

* The B2 audit will allow stopping decisions at each draw. It will be specified by an array of sample sizes: 1, 2, 3, ..., *N* where *N* is the maximum number of ballots drawn. The corresponding values of *kmin* will be determined by the stopping rule. For example, the *BRAVO* stopping rule is *likelihood ratio > 1/alpha* where *alpha* is the risk limit, and the likelihood ratio depends on the size of the sample, the number of votes for the winner and the election margin. 

* The audit with sample sizes 100, 400 and 1000 will be specified by an array of sample sizes: 100, 400 and 1000. It may have *kmin* values of 60, 230 and 520 respectively, which imply that one would stop the audit in the first round if and only if the number of ballots for the winner in the sample were 60 or larger; in the second round if it were 230 or larger and in the last round if it were 520 or larger. 

Clearly, such a specification only works for audits whose stopping criteria are monotonic with the number of winner ballots in the sample. 

We include code for computing:

* *n*: array of sample sizes beginning with the smallest size where a decision to stop is possible (usually all votes need to be for the winner to stop for the smallest possible sample size) and going on to the maximum number of ballots draws. 

* *kmin*: a corresponding array of minimum votes required for the winner to stop the audit. That is, *kmin(j)* is the minimum number of votes required for the winner in a sample of size *n(j)*.  

At the moment, we support two types of audits: 

* *BRAVO* and 
* *BRAVOLike*:  
  *BRAVO* without replacement, where the likelihood ratio is also computed assuming ballots are drawn without replacement. 
  
  We have fuzzy plans to incorporate Bayesian audits: both [*Bayesian RLAs*](https://arxiv.org/abs/1902.00999) and more general [*Bayesian Audits*](https://arxiv.org/abs/1801.00528). 

See also https://github.com/nealmcb/brla
