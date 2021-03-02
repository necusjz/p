---
title: Dynamic Programming on Strings
date: 2021-03-01 15:00:41
tags:
  - CodingInterview
---
## Statement
Given two strings s1 and s2, return some result.

## Approach
Most of the problems on this pattern requires a solution that can be accepted in O(n^2) complexity:
```cpp
for (int i = 1; i <= n; ++i) {
    for (int j = 1; j <= m; ++j) {
        if (s1[i-1] == s2[j-1]) {
            dp[i][j] = /* code */;
        } else {
            dp[i][j] = /* code */;
        }
    }
}
```

If you are given one string s the approach may little vary:
```cpp
for (int l = 1; l < n; ++l) {
    for (int i = 0; i < n-l; ++i) {
        int j = i + l;
        if (s[i] == s[j]) {
            dp[i][j] = /* code */;
        } else {
            dp[i][j] = /* code */;
        }
    }
}
```

## LeetCode
[Longest Common Subsequence](https://leetcode.com/problems/longest-common-subsequence/)
[Palindromic Substrings](https://leetcode.com/problems/palindromic-substrings/)
[Longest Palindromic Subsequence](https://leetcode.com/problems/longest-palindromic-subsequence/)
[Shortest Common Supersequence](https://leetcode.com/problems/shortest-common-supersequence/)
[Edit Distance](https://leetcode.com/problems/edit-distance/)
[Distinct Subsequences](https://leetcode.com/problems/distinct-subsequences/)
[Minimum ASCII Delete Sum for Two Strings](https://leetcode.com/problems/minimum-ascii-delete-sum-for-two-strings/)
[Longest Palindromic Substring](https://leetcode.com/problems/longest-palindromic-substring/)
