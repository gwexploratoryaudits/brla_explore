# Improving Round Size Estimates by Considering Irrelevant Ballots in Stopping Probability Calculations

> When auditing election results, election officials often want to only have to draw one round of ballots instead of continuing to go back a draw more and more rounds. Because of this, we provide round size estimates that give estimations of how many ballots must be drawn in a round in order to have a certain percent chance of the audit stopping. The stopping probability of a certain round is the probability of drawing kmin or greater number of ballots for the winner, where kmin is the minimum number of ballots for the winner for the round size that satisfies the audits stopping condition (read brla_explore and R2Audits READMEs for more detail). But, in a real election, there is the added possibility of irrelevant/invalid ballots, which we must consider when caluclating the stopping probabilites and round size estimates.

### Table of Contents

- [Description](#description)
- [My Code](#mycode)
- [Conclusions](#conclusions)

## Description
### Irrelevant Ballots

Consider a multi-candidate plurality election. When performing an audit on such an election, irrelevant ballots are ballots in the sample to be drawn from that do not pertain to/provide information to the audit being performed. It is also important to note that when auditing a multi-candidate election with one declared winner, the overall audit consists of multiple pairwise audits between the announced winner and each of the announced losers individually. If the announced winner passes each individual audit, then the overall audit passes. Irrelevant ballots are both: 

- Ballots that are improperly marked (i.e. no candidate selected, >1 candidate selected)
- If the number of candidates running is >2, ballots that are for a candidate that is not one of the two candidates that the audit is currently focusing on

Irrelevant ballots are important to consider because when estimating how many ballots have to be drawn in order to meet a certain stopping percentile, we have to consider the probability of drawing an irrelevant ballot as well as the probabilities of drawing ballots for the winner or losers (relevant ballots).

Consider a three-candidate plurality election using the following notation. For this example 

- w votes for announced winner
- li votes for announced losers
- b total ballots 

The way that the fraction of irrelevant ballots is calculated for a pairwise audit between w, li : The way that the fraction of irrelevant ballots is calculated for a pairwise audit between w, li :

Irrelevant fraction = (b - w - li) / b

### My approach

Therefore, you can calculate the stopping probability for a given round size n using a multinomial distribution where:

- w votes for the winner 
- li votes for the loser
- i irrelevant ballots
- pw probability of drawing a winner ballot
- pli probability of drawing a loser ballot
- pi probability of drawing an irrelevant ballot (irrelevant fraction)

Note that votes for the loser li = (n – w – i).

*Put Equation Here

## My Code

**RangeNextRoundSizes_IrrelevantBallots.m**

My version of RangeNextRoundSizes.m using the new approach to irrelevant ballots. Although, as it turns out, a range is no longer needed with the new approach.

**StopProb_IrrelevantBallots.m**

My version of StopProb.m using the new approach to irrelevant ballots.

**TrinomialDistribution.m**

The multinomial distribution calcualtions for the new approach.

**../Scripts/2020MontgomeryPrimary/Irrelevant_ballots_tests**

This folder contains an interactive test that uses data from the 2020 Montgomery County primary election and takes inputs and computes only first round sizes. This code is similar to one already written for the original approach, interactive_tests_Montgomery.m. This folder also contains code that generates graphs of stopping probabilites vs round sizes using the new irrelevant ballots approach and the same data mentioned above. 

**../Scripts/2016_Presidential/Irrelevant_ballots_tests**

This folder contains two tests that compute first round sizes using the new irrelevant ballot approach and the 2016 presidential primary election results for each state. These values computed are compared to those computed on the same data using the origianl approach. 

## Conclusions

My new approach is an improvement because instead of assuming the average amount of irrelevant ballots are drawn in a round, it actually calculates the stopping probability for each possible combination of relevant and irrelevant ballots in a round size and then takes the weighted average of all of these stopping probabilities, weighting each by the probability that that combination of relevant irrelevant ballots is drawn. This approach produces  smooth rather than a jagged curve, which also makes more logical sense. As the round size increases, meaning more ballots are drawn and we gain more information about the underlying election, the probability of stopping should increase. With the current approach, this is not always the case, whereas with my approach, this is the case. Finally, because the current approach produces a range of values, often in order to be safe, we take the max of that range as the round size to draw. The round size estimates that my approach produces are almost always less than or equal to this max value, saving election officials from drawing more ballots than necessary to meet a certain probability of stopping.

