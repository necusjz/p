---
title: Merge Intervals
tags:
  - CodingInterview
abbrlink: 1924995809
date: 2021-01-30 16:38:37
---
> 两个区间之间存在 6 种可能情况。取交集时，start = max(a.start, b.start); end = min(a.end, b.end)。

This pattern describes an efficient technique to deal with overlapping intervals. In a lot of problems involving intervals, we either need to find overlapping intervals or merge intervals if they overlap.

Given two intervals ("a" and "b"), there will be **six different ways** the two intervals can relate to each other:
![](https://raw.githubusercontent.com/necusjz/p/master/CodingInterview/educative/03.png)

Understanding the above six cases will help us in solving all intervals related problems.

## Snippets
```python
n = len(intervals)
ans = []

i = 0
# case 1
while i < n and intervals[i][1] < newInterval[0]:
    ans.append(intervals[i])
    i += 1
# case 2-5
while i < n and intervals[i][0] <= newInterval[1]:
    newInterval[0] = min(newInterval[0], intervals[i][0])
    newInterval[1] = max(newInterval[1], intervals[i][1])
    i += 1
ans.append(newInterval)
# case 6
while i < n:
    ans.append(intervals[i])
    i += 1

return ans
```

## LeetCode
[56. Merge Intervals](https://leetcode.com/problems/merge-intervals/)
[57. Insert Interval](https://leetcode.com/problems/insert-interval/)
[986. Interval List Intersections](https://leetcode.com/problems/interval-list-intersections/)
[435. Non-overlapping Intervals](https://leetcode.com/problems/non-overlapping-intervals/)
[253. Meeting Rooms II](https://leetcode.com/problems/meeting-rooms-ii/)
[1094. Car Pooling](https://leetcode.com/problems/car-pooling/)
[759. Employee Free Time](https://leetcode.com/problems/employee-free-time/)
