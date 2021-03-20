---
title: Merging Intervals
date: 2021-03-01 14:48:39
tags:
  - CodingInterview
---
## Statement
Given a set of numbers find an optimal solution for a problem considering the current number and the best you can get from the left and right sides.

## Approach
Find all optimal solutions for every interval and return the best possible answer:
> dp\[i]\[j] = dp\[i]\[k] + result\[k] + dp\[k+1]\[j]

Get the best from the left and right sides and add a solution for the current position:
```cpp
for (int l = 1; l < n; ++l) {
    for (int i = 0; i < n - l; ++i) {
        int j = i + l;
        for (int k = i; k < j; ++k) {
            dp[i][j] = max(dp[i][j], dp[i][k] + result[k] + dp[k+1][j]);
        }
    }
}
return dp[0][n-1];
```
<!--more-->

## LeetCode
[Minimum Cost Tree From Leaf Values](https://leetcode.com/problems/minimum-cost-tree-from-leaf-values/)
[Unique Binary Search Trees](https://leetcode.com/problems/unique-binary-search-trees/)
[Minimum Score Triangulation of Polygon](https://leetcode.com/problems/minimum-score-triangulation-of-polygon/)
[Remove Boxes](https://leetcode.com/problems/remove-boxes/)
[Minimum Cost to Merge Stones](https://leetcode.com/problems/minimum-cost-to-merge-stones/)
[Burst Balloons](https://leetcode.com/problems/burst-balloons/)
[Guess Number Higher or Lower II](https://leetcode.com/problems/guess-number-higher-or-lower-ii/)
