---
title: K-Way Merge
tags:
  - CodingInterview
abbrlink: 3169449011
date: 2021-01-31 23:08:23
---
This pattern helps us solve problems that involve a list of sorted arrays.

Whenever we are given "K" sorted arrays, we can use a **min heap** to efficiently perform a sorted traversal of all the elements of all arrays. We can push the smallest (first) element of each sorted array in a min heap to get the overall minimum. While inserting elements to the min heap we **keep track of which array the element came from**. We can, then, remove the top element from the heap to get the smallest element and push the next element from the same array, to which this smallest element belonged, to the heap. We can repeat this process to make a sorted traversal of all elements.

## Snippets
```python
min_heap = []
for row in matrix:
    # keep track by index
    heappush(min_heap, (row[0], 0, row))

n = len(matrix)
for _ in range(k - 1):
    _, idx, row = heappop(min_heap)
    if idx + 1 < n:
        heappush(min_heap, (row[idx+1], idx + 1, row))
return min_heap[0][0]
```

## LeetCode
[23. Merge k Sorted Lists](https://leetcode.com/problems/merge-k-sorted-lists/)
[4. Median of Two Sorted Arrays](https://leetcode.com/problems/median-of-two-sorted-arrays/)
[378. Kth Smallest Element in a Sorted Matrix](https://leetcode.com/problems/kth-smallest-element-in-a-sorted-matrix/)
[632. Smallest Range Covering Elements from K Lists](https://leetcode.com/problems/smallest-range-covering-elements-from-k-lists/)
[373. Find K Pairs with Smallest Sums](https://leetcode.com/problems/find-k-pairs-with-smallest-sums/)
