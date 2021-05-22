---
title: Top K Elements
date: 2021-01-31 22:56:12
tags:
  - CodingInterview
---
Any problem that asks us to find the _Top K Elements_ among a given set falls under this pattern.

The best data structure that comes to mind to keep track of "K" elements is **Heap**. This pattern will make use of the Heap to solve multiple problems dealing with "K" elements at a time from a set of given elements.

## Snippet
```python
from heapq import heappush, heappop


def reorganize_string(s: str) -> str:
    freq = dict()
    for char in s:
        freq[char] = freq.get(char, 0) + 1
    max_heap = []
    for char in freq:
        heappush(max_heap, (-freq[char], char))
    ans = ""
    while max_heap:
        # store popped elements
        queue, n = [], 2
        while n > 0 and max_heap:
            count, char = heappop(max_heap)
            count = -count - 1
            if count > 0:
                queue.append((-count, char))
            ans += char
            n -= 1
        if n > 0:
            break
        # push back
        for element in queue:
            heappush(max_heap, element)
    return ans if len(ans) == len(s) else ""
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
