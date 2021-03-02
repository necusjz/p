---
title: Decision Making
date: 2021-03-01 15:12:37
tags:
  - CodingInterview
---
## Statement
Given a set of values find an answer with an option to choose or ignore the current value.

## Approach
If you decide to choose the current value use the previous result where the value was ignored; vice versa, if you decide to ignore the current value use previous result where value was used:
```cpp
// i: indexing a set of values
// j: options to ignore j values
for (int i = 1; i < n; ++i) {
    for (int j = 1; j <= k; ++j) {
        dp[i][j] = max({dp[i][j], dp[i-1][j] + arr[i], dp[i-1][j-1]});
        dp[i][j-1] = max({dp[i][j-1], dp[i-1][j-1] + arr[i], arr[i]});
    }
}
```
<!--more-->

## LeetCode
[House Robber](https://leetcode.com/problems/house-robber/)
[Best Time to Buy and Sell Stock](https://leetcode.com/problems/best-time-to-buy-and-sell-stock/)
[Best Time to Buy and Sell Stock with Transaction Fee](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-with-transaction-fee/)
[Best Time to Buy and Sell Stock with Cooldown](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-with-cooldown/)
[Best Time to Buy and Sell Stock III](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iii/)
[Best Time to Buy and Sell Stock IV](https://leetcode.com/problems/best-time-to-buy-and-sell-stock-iv/)
