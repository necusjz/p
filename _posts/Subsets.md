---
title: Subsets
date: 2021-01-31 20:35:10
tags:
  - CodingInterview
---
A huge number of coding interview problems involve dealing with `Permutations` and `Combinations` of a given set of elements. This pattern describes an efficient Breadth-First Search (BFS) approach to handle all these problems.

## Snippet
```python
# iteration
def subsetsWithDup(self, nums: List[int]) -> List[List[int]]:
    subsets = [[]]
    nums.sort()
    for i in range(len(nums)):
        start = 0
        # handle duplicates
        if i > 0 and nums[i] == nums[i-1]:
            start = end + 1
        end = len(subsets) - 1
        for j in range(start, end + 1):
            subsets.append(subsets[j] + [nums[i]])
    return subsets

# recursion
def __init__(self):
    self.map = dict()

def numTrees(self, n: int) -> int:
    if n <= 1:
        return 1
    if n in self.map:
        return self.map[n]
    count = 0
    for i in range(1, n + 1):
        cnt_l = self.numTrees(i - 1)
        cnt_r = self.numTrees(n - i)
        count += cnt_l * cnt_r
    # memorization
    self.map[n] = count
    return count

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
