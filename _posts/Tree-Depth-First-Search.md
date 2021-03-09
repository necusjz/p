---
title: Tree Depth-First Search
date: 2021-01-30 17:34:51
tags:
  - CodingInterview
---
This pattern is based on the Depth-First Search (DFS) technique to traverse a tree.

We will be using recursion (or we can also use a stack for the iterative approach) to keep track of all the previous (parent) nodes while traversing. This also means that the space complexity of the algorithm will be O(H), where "H" is the maximum height of the tree.

## Snippet
```python
"""
One Direction
"""
def __init__(self):
    self.paths = []

def obtain_path(self, root, targetSum, curr_path):
    if not root:
        return None
    curr_path.append(root.val)
    if not root.left and not root.right and root.val == targetSum:
        self.paths.append(curr_path[:])
    targetSum -= root.val
    # DFS
    self.obtain_path(root.left, targetSum, curr_path)
    self.obtain_path(root.right, targetSum, curr_path)
    # backtracking
    curr_path.pop()

def pathSum(self, root: TreeNode, targetSum: int) -> List[List[int]]:
    self.obtain_path(root, targetSum, [])
    return self.paths

"""
Both Directions
"""
def __init__(self):
    self.max_sum = -sys.maxsize

def calc_max(self, root):
    if not root:
        return 0
    # DFS
    l_max = max(0, self.calc_max(root.left))
    r_max = max(0, self.calc_max(root.right))
    curr_sum = l_max + r_max + root.val
    self.max_sum = max(self.max_sum, curr_sum)
    return max(l_max, r_max) + root.val

def maxPathSum(self, root: TreeNode) -> int:
    self.calc_max(root)
    return self.max_sum

```

## LeetCode
[Path Sum](https://leetcode.com/problems/path-sum/)
[Path Sum II](https://leetcode.com/problems/path-sum-ii/)
[Binary Tree Paths](https://leetcode.com/problems/binary-tree-paths/)
[Sum Root to Leaf Numbers](https://leetcode.com/problems/sum-root-to-leaf-numbers/)
[Path Sum III](https://leetcode.com/problems/path-sum-iii/)
[Diameter of Binary Tree](https://leetcode.com/problems/diameter-of-binary-tree/)
[Binary Tree Maximum Path Sum](https://leetcode.com/problems/binary-tree-maximum-path-sum/)
