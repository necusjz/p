---
title: Top K Elements
date: 2021-01-31 22:56:12
tags:
  - CodingInterview
---
Any problem that asks us to find the top/smallest/frequent "K" elements among a given set falls under this pattern.

The best data structure that comes to mind to keep track of "K" elements is `Heap`. This pattern will make use of the Heap to solve multiple problems dealing with "K" elements at a time from a set of given elements.

## Snippet
```python
from heapq import heappush, heappop

def reorganizeString(self, S: str) -> str:
    freq = dict()
    # obtain frequency map
    for char in S:
        freq[char] = freq.get(char, 0) + 1
    max_heap = []
    # initialize max heap
    for char, count in freq.items():
        heappush(max_heap, (-count, char))
    result = ""
    prev_char, prev_count = "", 0
    while max_heap:
        count, char = heappop(max_heap)
        if prev_count > 0:
            heappush(max_heap, (-prev_count, prev_char))
        result += char
        prev_char = char
        prev_count = -count - 1
    return result if len(result) == len(S) else ""
    
```

## LeetCode
[Kth Largest Element in an Array](https://leetcode.com/problems/kth-largest-element-in-an-array/)
[K Closest Points to Origin](https://leetcode.com/problems/k-closest-points-to-origin/)
[Top K Frequent Elements](https://leetcode.com/problems/top-k-frequent-elements/)
[Sort Characters By Frequency](https://leetcode.com/problems/sort-characters-by-frequency/)
[Kth Largest Element in a Stream](https://leetcode.com/problems/kth-largest-element-in-a-stream/)
[Find K Closest Elements](https://leetcode.com/problems/find-k-closest-elements/)
[Reorganize String](https://leetcode.com/problems/reorganize-string/)
[Task Scheduler](https://leetcode.com/problems/task-scheduler/)
[Maximum Frequency Stack](https://leetcode.com/problems/maximum-frequency-stack/)
