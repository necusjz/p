---
title: Tree Depth-First Search
date: 2021-01-30 17:34:51
tags:
  - CodingInterview
---
This pattern is based on the _Depth-First Search_ technique to traverse a tree.

We will be using recursion (or we can also use a **Stack** for the iterative approach) to keep track of all the previous (parent) nodes while traversing. This also means that the space complexity of the algorithm will be O(H), where "H" is the **maximum height of the tree**.

## Snippet
```python
"""
No Return Value
"""
def path_sum(root: TreeNode, target: int) -> List[List[int]]:
    def dfs(node, path):
        if not node:
            return
        # deep copy
        path = path + [node.val]
        if not node.left and not node.right and sum(path) == target:
            self.ans.append(path)
        dfs(node.left, path)
        dfs(node.right, path)
    
    self.ans = []
    dfs(root, [])
    return self.ans
"""
Has a Return Value
"""
def max_path_sum(root: TreeNode) -> int:
    def dfs(node):
        if not node:
            return 0
        # obtain intermediate results
        l = max(dfs(node.left), 0)
        r = max(dfs(node.right), 0)
        self.ans = max(self.ans, l + r + node.val)
        return max(l, r) + node.val
    
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
