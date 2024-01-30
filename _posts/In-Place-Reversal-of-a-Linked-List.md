---
title: In-Place Reversal of a Linked List
tags:
  - CodingInterview
abbrlink: 3232636938
date: 2021-01-30 17:09:24
---
> 除了掌握反转链表的写法外，设置哨兵节点（前一个节点）、由远及近地处理 next pointer 也很重要。

In a lot of problems, we are asked to reverse the links between a set of nodes of a linked list. Often, the constraint is that we need to do this **in-place**, i.e., using the existing node objects and without using extra memory.

_In-Place Reversal of a Linked List_ pattern describes an efficient way to solve the above problem.

## Snippets
```python
dummy, dummy.next = ListNode(), head  # set sentinel
ptr = dummy

for _ in range(left - 1):
    ptr = ptr.next

prev, curr = None, ptr.next
for _ in range(right - left + 1):
    curr.next, prev, curr = prev, curr, curr.next

# link
ptr.next.next = curr
ptr.next = prev

return dummy.next
```

## LeetCode
[206. Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/)
[92. Reverse Linked List II](https://leetcode.com/problems/reverse-linked-list-ii/)
[25. Reverse Nodes in k-Group](https://leetcode.com/problems/reverse-nodes-in-k-group/)
[2074. Reverse Nodes in Even Length Groups](https://leetcode.com/problems/reverse-nodes-in-even-length-groups/)
[61. Rotate List](https://leetcode.com/problems/rotate-list/)
