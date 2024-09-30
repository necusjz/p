---
title: Tree Depth-First Search
tags:
  - CodingInterview
abbrlink: 2074145294
date: 2021-01-30 17:34:51
---
> 重点掌握左右子树相关和不相关时，两种递归代码的写法。

This pattern is based on the _Depth-First Search_ (DFS) technique to traverse a tree.

We will be using recursion (or we can also use a **stack** for the iterative approach) to keep track of all the previous (parent) nodes while traversing. This also means that the space complexity of the algorithm will be O(H), where "H" is **the maximum height of the tree**.

## Snippets
```python
"""L&R Unrelated"""
def dfs(root, path):
    if not root:
        return
    
    path = path + [root.val]
    if not root.left and not root.right and sum(path) == targetSum:
        ans.append(path)
    
    dfs(root.left, path)
    dfs(root.right, path)

ans = []
dfs(root, [])

return ans
```
```python
"""L&R Related"""
def dfs(root):
    if not root:
        return 0
    
    l = max(0, dfs(root.left))
    r = max(0, dfs(root.right))

    nonlocal ans
    ans = max(ans, l + r + root.val)

    return max(l, r) + root.val

ans = root.val
dfs(root)

return ans
```

## LeetCode
[112. Path Sum](https://leetcode.com/problems/path-sum/)
[113. Path Sum II](https://leetcode.com/problems/path-sum-ii/)
[129. Sum Root to Leaf Numbers](https://leetcode.com/problems/sum-root-to-leaf-numbers/)
[1430. Check If a String Is a Valid Sequence from Root to Leaves Path in a Binary Tree](https://leetcode.com/problems/check-if-a-string-is-a-valid-sequence-from-root-to-leaves-path-in-a-binary-tree/)
[437. Path Sum III](https://leetcode.com/problems/path-sum-iii/)
[543. Diameter of Binary Tree](https://leetcode.com/problems/diameter-of-binary-tree/)
[124. Binary Tree Maximum Path Sum](https://leetcode.com/problems/binary-tree-maximum-path-sum/)
