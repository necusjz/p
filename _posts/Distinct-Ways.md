---
title: Distinct Ways
date: 2021-03-01 14:20:31
tags:
  - CodingInterview
---
## Statement
Given a target find a number of distinct ways to reach the target.

## Approach
Sum all possible ways to reach the current state:
> routes\[i] = routes\[i-1] + routes\[i-2] + ... + routes\[i-k]

Generate sum for all values in the target and return the value for the target:
```cpp
for (int i = 1; i <= target; ++i) {
    for (int j = 0; j < ways.size(); ++j) {
        if (ways[j] <= i) {
            dp[i] += dp[i-ways[j]];
        }
    }
}
 
return dp[target];
```

**Note**:
> Some questions point out the number of repetitions, in that case, add one more loop to simulate every repetition.

<!--more-->
## LeetCode
[Climbing Stairs](https://leetcode.com/problems/climbing-stairs/)
[Unique Paths](https://leetcode.com/problems/unique-paths/)
[Number of Dice Rolls With Target Sum](https://leetcode.com/problems/number-of-dice-rolls-with-target-sum/)
[Knight Probability in Chessboard](https://leetcode.com/problems/knight-probability-in-chessboard/)
[Target Sum](https://leetcode.com/problems/target-sum/)
[Combination Sum IV](https://leetcode.com/problems/combination-sum-iv/)
[Knight Dialer](https://leetcode.com/problems/knight-dialer/)
[Dice Roll Simulation](https://leetcode.com/problems/dice-roll-simulation/)
[Partition Equal Subset Sum](https://leetcode.com/problems/partition-equal-subset-sum/)
[Soup Servings](https://leetcode.com/problems/soup-servings/)
[Domino and Tromino Tiling](https://leetcode.com/problems/domino-and-tromino-tiling/)
[Minimum Swaps To Make Sequences Increasing](https://leetcode.com/problems/minimum-swaps-to-make-sequences-increasing/)
[Number of Longest Increasing Subsequence](https://leetcode.com/problems/number-of-longest-increasing-subsequence/)
[Unique Paths II](https://leetcode.com/problems/unique-paths-ii/)
[Out of Boundary Paths](https://leetcode.com/problems/out-of-boundary-paths/)
[Number of Ways to Stay in the Same Place After Some Steps](https://leetcode.com/problems/number-of-ways-to-stay-in-the-same-place-after-some-steps/)
[Count Vowels Permutation](https://leetcode.com/problems/count-vowels-permutation/)
