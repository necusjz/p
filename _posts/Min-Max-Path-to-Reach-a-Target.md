---
title: Min/Max Path to Reach a Target
date: 2021-03-01 14:01:33
tags:
  - CodingInterview
---
## Statement
Given a target find minimum (maximum) cost/path/sum to reach the target.

## Approach
Choose minimum (maximum) path among all possible paths before the current state, then add value for the current state:
> routes\[i] = min(routes\[i-1], routes\[i-2], ..., routes\[i-k]) + cost\[i]

Generate optimal solutions for all values in the target and return the value for the target:
```cpp
for (int i = 1; i <= target; ++i) {
    for (int j = 0; j < ways.size(); ++j) {
        if (ways[j] <= i) {
            dp[i] = min(dp[i], dp[i-ways[j]] + cost/path/sum);
        }
    }
}

return dp[target];
```

## LeetCode
[Min Cost Climbing Stairs](https://leetcode.com/problems/min-cost-climbing-stairs/)
[Minimum Path Sum](https://leetcode.com/problems/minimum-path-sum/)
[Coin Change](https://leetcode.com/problems/coin-change/)
[Minimum Falling Path Sum](https://leetcode.com/problems/minimum-falling-path-sum/)
[Minimum Cost For Tickets](https://leetcode.com/problems/minimum-cost-for-tickets/)
[2 Keys Keyboard](https://leetcode.com/problems/2-keys-keyboard/)
[Perfect Squares](https://leetcode.com/problems/perfect-squares/)
[Last Stone Weight II](https://leetcode.com/problems/last-stone-weight-ii/)
[Triangle](https://leetcode.com/problems/triangle/)
[Ones and Zeroes](https://leetcode.com/problems/ones-and-zeroes/)
[Maximal Square](https://leetcode.com/problems/maximal-square/)
[Tiling a Rectangle with the Fewest Squares](https://leetcode.com/problems/tiling-a-rectangle-with-the-fewest-squares/)
[Dungeon Game](https://leetcode.com/problems/dungeon-game/)
[Minimum Number of Refueling Stops](https://leetcode.com/problems/minimum-number-of-refueling-stops/)
