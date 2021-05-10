---
title: Tree Breadth-First Search
date: 2021-01-30 17:22:57
tags:
  - CodingInterview
---
This pattern is based on the _Breadth-First Search_ technique to traverse a tree.

Any problem involving the traversal of a tree in a level-by-level order can be efficiently solved using this approach. We will use a **Queue** to keep track of all the nodes of a level before we jump onto the next level. This also means that the space complexity of the algorithm will be O(W), where "W" is the **maximum number of nodes on any level**.

## Snippet
```python
from collections import deque


def average_of_levels(root: TreeNode) -> List[float]:
    if not root:
        return root
    ans = []
    queue = deque([root])
    while queue:
        curr_sum, curr_len = 0.0, len(queue)
        for _ in range(curr_len):
            node = queue.popleft()
            curr_sum += node.val
            if node.left:
                queue.append(node.left)
            if node.right:
                queue.append(node.right)
        ans.append(curr_sum / curr_len)
    return ans
```

## LeetCode
[Binary Tree Level Order Traversal](https://leetcode.com/problems/binary-tree-level-order-traversal/)
[Binary Tree Level Order Traversal II](https://leetcode.com/problems/binary-tree-level-order-traversal-ii/)
[Binary Tree Zigzag Level Order Traversal](https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/)
[Average of Levels in Binary Tree](https://leetcode.com/problems/average-of-levels-in-binary-tree/)
[Minimum Depth of Binary Tree](https://leetcode.com/problems/minimum-depth-of-binary-tree/)
[Maximum Depth of Binary Tree](https://leetcode.com/problems/maximum-depth-of-binary-tree/)
[Populating Next Right Pointers in Each Node II](https://leetcode.com/problems/populating-next-right-pointers-in-each-node-ii/)
[Binary Tree Right Side View](https://leetcode.com/problems/binary-tree-right-side-view/)
