---
title: Tree Depth-First Search
tags:
  - CodingInterview
abbrlink: 2074145294
date: 2021-01-30 17:34:51
---
This pattern is based on the _Depth-First Search_ technique to traverse a tree.

We will be using recursion (or we can also use a **Stack** for the iterative approach) to keep track of all the previous (parent) nodes while traversing. This also means that the space complexity of the algorithm will be O(H), where "H" is the **maximum height of the tree**.

## Snippet
```python
"""
No Return Value
"""
def path_sum(root: TreeNode, target: int) -> List[List[int]]:
    def dfs(root, path):
        if not root:
            return
        # deep copy
        path = path + [root.val]
        if not root.left and not root.right and sum(path) == target:
            ans.append(path)
        dfs(root.left, path)
        dfs(root.right, path)
    
    ans = []
    dfs(root, [])
    return ans
"""
Has a Return Value
"""
def max_path_sum(root: TreeNode) -> int:
    def dfs(root):
        if not root:
            return 0
        # obtain intermediate results
        l = max(dfs(root.left), 0)
        r = max(dfs(root.right), 0)
        self.ans = max(self.ans, l + r + root.val)
        return max(l, r) + root.val
    
    self.ans = -sys.maxsize
    dfs(root)
    return self.ans
```

## LeetCode
[Path Sum](https://leetcode.com/problems/path-sum/)
[Path Sum II](https://leetcode.com/problems/path-sum-ii/)
[Binary Tree Paths](https://leetcode.com/problems/binary-tree-paths/)
[Sum Root to Leaf Numbers](https://leetcode.com/problems/sum-root-to-leaf-numbers/)
[Path Sum III](https://leetcode.com/problems/path-sum-iii/)
[Diameter of Binary Tree](https://leetcode.com/problems/diameter-of-binary-tree/)
[Binary Tree Maximum Path Sum](https://leetcode.com/problems/binary-tree-maximum-path-sum/)
