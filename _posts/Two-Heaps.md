---
title: Two Heaps
date: 2021-01-30 17:46:46
tags:
  - CodingInterview
---
In many problems, where we are given a set of elements such that we can divide them into two parts. To solve the problem, we are interested in knowing the largest element in one part and the smallest element in the other part. This pattern is an efficient approach to solve such problems.

This pattern uses _Two Heaps_ to solve these problems; A **Max Heap** to find the largest element and a **Min Heap** to find the smallest element.

## Snippet
```python
from heapq import heappush, heappop


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
        elif len(self.max_heap) < len(self.min_heap):
            heappush(self.max_heap, -heappop(self.min_heap))

    def find_median(self) -> float:
        if len(self.max_heap) == len(self.min_heap):
            return (-self.max_heap[0] + self.min_heap[0]) / 2.0
        return -self.max_heap[0] / 1.0
```

## LeetCode
[Find Median from Data Stream](https://leetcode.com/problems/find-median-from-data-stream/)
[Sliding Window Median](https://leetcode.com/problems/sliding-window-median/)
[IPO](https://leetcode.com/problems/ipo/)
[Find Right Interval](https://leetcode.com/problems/find-right-interval/)
