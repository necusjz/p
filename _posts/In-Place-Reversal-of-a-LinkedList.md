---
title: In-Place Reversal of a LinkedList
date: 2021-01-30 17:09:24
tags:
  - CodingInterview
---
In a lot of problems, we are asked to reverse the links between a set of nodes of a LinkedList. Often, the constraint is that we need to do this in-place, i.e., using the existing node objects and without using extra memory.

In-Place Reversal of a LinkedList pattern describes an efficient way to solve the above problem.

## Snippet
```python
def reverseBetween(self, head: ListNode, left: int, right: int) -> ListNode:
    # set sentinel
    dummy, dummy.next = ListNode(), head
    # obtain previous node
    prev = dummy
    for _ in range(left - 1):
        prev = prev.next
    # reverse from left to right
    rev, curr = None, prev.next
    for _ in range(right - left + 1):
        temp = curr.next
        curr.next = rev
        rev = curr
        curr = temp
    # merge three parts
    prev.next.next = curr
    prev.next = rev
    return dummy.next

```

## LeetCode
[Reverse Linked List](https://leetcode.com/problems/reverse-linked-list/)
[Reverse Linked List II](https://leetcode.com/problems/reverse-linked-list-ii/)
[Reverse Nodes in k-Group](https://leetcode.com/problems/reverse-nodes-in-k-group/)
[Rotate List](https://leetcode.com/problems/rotate-list/)
