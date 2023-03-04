---
title: Tree Breadth-First Search
tags:
  - CodingInterview
abbrlink: 2304129997
date: 2021-01-30 17:22:57
---
This pattern is based on the _Breadth-First Search_ (BFS) technique to traverse a tree.

Any problem involving the traversal of a tree in a level-by-level order can be efficiently solved using this approach. We will use a **queue** to keep track of all the nodes of a level before we jump onto the next level. This also means that the space complexity of the algorithm will be O(W), where "W" is **the maximum number of nodes on any level**.

## Snippets
```python
if not root:
    return None

queue = deque([root])
while queue:
    curr_len = len(queue)
    for idx in range(curr_len):
        node = queue.popleft()
        if idx != curr_len - 1:
            node.next = queue[0]
        # bfs
        if node.left:
            queue.append(node.left)
        if node.right:
            queue.append(node.right)

return root
```

## LeetCode
[102. Binary Tree Level Order Traversal](https://leetcode.com/problems/binary-tree-level-order-traversal/)
[107. Binary Tree Level Order Traversal II](https://leetcode.com/problems/binary-tree-level-order-traversal-ii/)
[103. Binary Tree Zigzag Level Order Traversal](https://leetcode.com/problems/binary-tree-zigzag-level-order-traversal/)
[637. Average of Levels in Binary Tree](https://leetcode.com/problems/average-of-levels-in-binary-tree/)
[111. Minimum Depth of Binary Tree](https://leetcode.com/problems/minimum-depth-of-binary-tree/)
[429. N-ary Tree Level Order Traversal](https://leetcode.com/problems/n-ary-tree-level-order-traversal/)
[117. Populating Next Right Pointers in Each Node II](https://leetcode.com/problems/populating-next-right-pointers-in-each-node-ii/)
[116. Populating Next Right Pointers in Each Node](https://leetcode.com/problems/populating-next-right-pointers-in-each-node/)
[199. Binary Tree Right Side View](https://leetcode.com/problems/binary-tree-right-side-view/)
