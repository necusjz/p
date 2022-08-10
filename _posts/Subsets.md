---
title: Subsets
tags:
  - CodingInterview
abbrlink: 2189758150
date: 2021-01-31 20:35:10
---
A huge number of coding interview problems involve dealing with _Permutations_ and _Combinations_ of a given set of elements. This pattern describes an efficient **breadth-first search** approach to handle all these problems.

## Snippets
```python
"""Iteration"""
queue = deque([[]])

for num in sorted(nums):
    curr_len = len(queue)
    for _ in range(curr_len):
        element = queue.popleft()
        cand = element + [num]
        # skip duplicates
        if cand not in queue:
            queue.append(cand)
        
        queue.append(element)

return queue
```
```python
"""Recursion"""
@cache
def build(start, end):
    if start > end:
        return [None]
    
    ret = []
    for val in range(start, end + 1):
        # divide & conquer
        l = build(start, val - 1)
        r = build(val + 1, end)
        for x in l:
            for y in r:
                root = TreeNode(val)
                root.left = x
                root.right = y
                ret.append(root)
    return ret

return build(1, n)
```

## LeetCode
[78. Subsets](https://leetcode.com/problems/subsets/)
[90. Subsets II](https://leetcode.com/problems/subsets-ii/)
[46. Permutations](https://leetcode.com/problems/permutations/)
[784. Letter Case Permutation](https://leetcode.com/problems/letter-case-permutation/)
[22. Generate Parentheses](https://leetcode.com/problems/generate-parentheses/)
[320. Generalized Abbreviation](https://leetcode.com/problems/generalized-abbreviation/)
[241. Different Ways to Add Parentheses](https://leetcode.com/problems/different-ways-to-add-parentheses/)
[95. Unique Binary Search Trees II](https://leetcode.com/problems/unique-binary-search-trees-ii/)
[96. Unique Binary Search Trees](https://leetcode.com/problems/unique-binary-search-trees/)
