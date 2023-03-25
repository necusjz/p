---
title: Top K Elements
tags:
  - CodingInterview
abbrlink: 1492973727
date: 2021-01-31 22:56:12
---
Any problem that asks us to find the _Top K Elements_ among a given set falls under this pattern.

The best data structure that comes to mind to keep track of "K" elements is **heap**. This pattern will make use of the heap to solve multiple problems dealing with "K" elements at a time from a set of given elements.

## Snippets
```python
freq = dict()
for char in s:
    freq[char] = freq.get(char, 0) + 1

max_heap = []
for char in freq:
    heappush(max_heap, (-freq[char], char))

ans = ""
while max_heap:
    queue, k = [], 2  # store pop-up items
    while max_heap and k > 0:
        count, char = heappop(max_heap)
        ans += char
        if -count - 1 > 0:
            queue.append((count + 1, char))
        k -= 1
    
    if k != 0 and queue:
        return ""
    # push back
    for item in queue:
        heappush(max_heap, item)
return ans
```

## LeetCode
[692. Top K Frequent Words](https://leetcode.com/problems/top-k-frequent-words/)
[215. Kth Largest Element in an Array](https://leetcode.com/problems/kth-largest-element-in-an-array/)
[973. K Closest Points to Origin](https://leetcode.com/problems/k-closest-points-to-origin/)
[1167. Minimum Cost to Connect Sticks](https://leetcode.com/problems/minimum-cost-to-connect-sticks/)
[347. Top K Frequent Elements](https://leetcode.com/problems/top-k-frequent-elements/)
[451. Sort Characters By Frequency](https://leetcode.com/problems/sort-characters-by-frequency/)
[703. Kth Largest Element in a Stream](https://leetcode.com/problems/kth-largest-element-in-a-stream/)
[658. Find K Closest Elements](https://leetcode.com/problems/find-k-closest-elements/)
[1481. Least Number of Unique Integers after K Removals](https://leetcode.com/problems/least-number-of-unique-integers-after-k-removals/)
[1508. Range Sum of Sorted Subarray Sums](https://leetcode.com/problems/range-sum-of-sorted-subarray-sums/)
[767. Reorganize String](https://leetcode.com/problems/reorganize-string/)
[358. Rearrange String k Distance Apart](https://leetcode.com/problems/rearrange-string-k-distance-apart/)
[621. Task Scheduler](https://leetcode.com/problems/task-scheduler/)
[895. Maximum Frequency Stack](https://leetcode.com/problems/maximum-frequency-stack/)
