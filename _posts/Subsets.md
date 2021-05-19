---
title: Subsets
date: 2021-01-31 20:35:10
tags:
  - CodingInterview
---
A huge number of coding interview problems involve dealing with _Permutations_ and _Combinations_ of a given set of elements. This pattern describes an efficient **Breadth-First Search** approach to handle all these problems.

## Snippet
```python
"""
Iteration
"""
def subsets_with_dup(nums: List[int]) -> List[List[int]]:
    nums.sort()
    ans = [[]]
    for i in range(len(nums)):
        start = 0
        # handle duplicates
        if i > 0 and nums[i] == nums[i-1]:
            start = end
        end = len(ans)
        for j in range(start, end):
            # deep copy
            ans.append(ans[j] + [nums[i]])
    return ans
"""
Recursion
"""
from functools import lru_cache


def generate_trees(n: int) -> List[TreeNode]:
    @lru_cache(maxsize=None)
    def dfs(start, end):
        if start > end:
            return [None]
        ret = []
        for i in range(start, end + 1):
            # divide and conquer
            l = dfs(start, i - 1)
            r = dfs(i + 1, end)
            for x in l:
                for y in r:
                    root = TreeNode(val=i)
                    root.left = x
                    root.right = y
                    ret.append(root)
        return ret
    
    return dfs(1, n)
```

## LeetCode
[Subsets](https://leetcode.com/problems/subsets/)
[Subsets II](https://leetcode.com/problems/subsets-ii/)
[Permutations](https://leetcode.com/problems/permutations/)
[Letter Case Permutation](https://leetcode.com/problems/letter-case-permutation/)
[Generate Parentheses](https://leetcode.com/problems/generate-parentheses/)
[Different Ways to Add Parentheses](https://leetcode.com/problems/different-ways-to-add-parentheses/)
[Unique Binary Search Trees II](https://leetcode.com/problems/unique-binary-search-trees-ii/)
[Unique Binary Search Trees](https://leetcode.com/problems/unique-binary-search-trees/)
