---
title: Two Heaps
tags:
  - CodingInterview
abbrlink: 3727509945
date: 2021-01-30 17:46:46
---
In many problems, where we are given a set of elements such that we can divide them into two parts. To solve the problem, we are interested in knowing the largest element in one part and the smallest element in the other part. This pattern is an efficient approach to solve such problems.

This pattern uses _Two Heaps_ to solve these problems; A **max heap** to find the largest element and a **min heap** to find the smallest element.

## Snippets
```python
class MedianFinder:
    def __init__(self):
        self.max_heap = []
        self.min_heap = []

    def add_num(self, num: int) -> None:
        if not self.max_heap or num <= -self.max_heap[0]:
            heappush(self.max_heap, -num)
        else:
            heappush(self.min_heap, num)
        # re-balance
        if len(self.max_heap) > len(self.min_heap) + 1:
            heappush(self.min_heap, -heappop(self.max_heap))
        if len(self.min_heap) > len(self.max_heap):
            heappush(self.max_heap, -heappop(self.min_heap))

    def find_median(self) -> float:
        if len(self.max_heap) == len(self.min_heap):
            return (-self.max_heap[0] + self.min_heap[0]) / 2
        
        return -self.max_heap[0] / 1
```

## LeetCode
[295. Find Median from Data Stream](https://leetcode.com/problems/find-median-from-data-stream/)
[480. Sliding Window Median](https://leetcode.com/problems/sliding-window-median/)
[502. IPO](https://leetcode.com/problems/ipo/)
[436. Find Right Interval](https://leetcode.com/problems/find-right-interval/)
