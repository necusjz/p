---
title: Fast & Slow Pointers
tags:
  - CodingInterview
abbrlink: 3580079225
date: 2021-01-30 16:11:29
---
> 掌握判环以及判环的变形。while 循环的条件往往是 r and r.next 存在，过程中可以顺便获取 middle pointer。

The _Fast & Slow Pointers_ approach is a pointer algorithm that uses two pointers which move through the array (or linked list) at different speeds. This approach is quite useful when dealing with cyclic linked lists or arrays.

By moving at different speeds (say, in a cyclic linked list), the algorithm proves that **the two pointers are bound to meet**. The fast pointer should catch the slow pointer once both the pointers are in a cyclic loop.

## Snippets
```python
def next(num):
    ret = 0
    while num:
        num, mod = divmod(num, 10)
        ret += mod * mod

    return ret

l = r = n  
while r != 1 and next(r) != 1:
    l = next(l)
    r = next(next(r))
    
    if l == r:
        return False

return True
```

## LeetCode
[141. Linked List Cycle](https://leetcode.com/problems/linked-list-cycle/)
[142. Linked List Cycle II](https://leetcode.com/problems/linked-list-cycle-ii/)
[202. Happy Number](https://leetcode.com/problems/happy-number/)
[876. Middle of the Linked List](https://leetcode.com/problems/middle-of-the-linked-list/)
[234. Palindrome Linked List](https://leetcode.com/problems/palindrome-linked-list/)
[143. Reorder List](https://leetcode.com/problems/reorder-list/)
[457. Circular Array Loop](https://leetcode.com/problems/circular-array-loop/)
