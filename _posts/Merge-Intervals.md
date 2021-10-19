---
title: Merge Intervals
date: 2021-01-30 16:38:37
tags:
  - CodingInterview
---
This pattern describes an efficient technique to deal with overlapping intervals. In a lot of problems involving intervals, we either need to find overlapping intervals or merge intervals if they overlap.

Given two intervals ("a" and "b"), there will be six different ways the two intervals can relate to each other:
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/CodingInterview/educative/03.png)

Understanding the above six cases will help us in solving all intervals related problems.

## Snippet
```python
def insert(intervals: List[List[int]], newInterval: List[int]) -> List[List[int]]:
    i = 0
    ans = []
    # merge left part
    while i < len(intervals) and intervals[i][1] < newInterval[0]:
        ans.append(intervals[i])
        i += 1
    # merge middle part
    while i < len(intervals) and intervals[i][0] <= newInterval[1]:
        newInterval[0] = min(newInterval[0], intervals[i][0])
        newInterval[1] = max(newInterval[1], intervals[i][1])
        i += 1
    ans.append(newInterval)
    # merge right part
    while i < len(intervals):
        ans.append(intervals[i])
        i += 1
    return ans
```

## LeetCode
[Merge Intervals](https://leetcode.com/problems/merge-intervals/)
[Insert Interval](https://leetcode.com/problems/insert-interval/)
[Interval List Intersections](https://leetcode.com/problems/interval-list-intersections/)
