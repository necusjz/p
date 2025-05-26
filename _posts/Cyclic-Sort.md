---
title: Cyclic Sort
tags:
  - CodingInterview
abbrlink: 1292284163
date: 2021-01-30 16:55:01
---
> 常用但鲜为人知的循环排序。核心理念是：将元素交换到正确的位置，继而获取某个 range 内缺失的数字。其中，缺失数字为索引值，已有数字为元素值。警惕 desired index 可能造成的数组越界。

This pattern describes an interesting approach to deal with problems involving arrays **containing numbers in a given range**. For example, take the following problem:
> You are given an unsorted array containing numbers taken from the range "1" to "n". The array can have duplicates, which means that some numbers will be missing. Find all the missing numbers.

To efficiently solve this problem, we can use the fact that the input array contains numbers in the range of "1" to "n". For example, to efficiently sort the array, we can try placing each number in its correct place, i.e., placing "1" at index "0", placing "2" at index "1", and so on. Once we are done with the sorting, we can iterate the array to find all indices that are missing the correct numbers. These will be our required numbers.

## Snippets
```python
n = len(nums)

i = 0
while i < n:
    j = nums[i] - 1
    if 0 <= j < n and nums[i] != nums[j]:  # avoid index out of bounds
        nums[i], nums[j] = nums[j], nums[i]
        continue

    i += 1

for i in range(n):
    if nums[i] != i + 1:
        return i + 1

return n + 1
```

## LeetCode
[765. Couples Holding Hands](https://leetcode.com/problems/couples-holding-hands/)
[268. Missing Number](https://leetcode.com/problems/missing-number/)
[448. Find All Numbers Disappeared in an Array](https://leetcode.com/problems/find-all-numbers-disappeared-in-an-array/)
[287. Find the Duplicate Number](https://leetcode.com/problems/find-the-duplicate-number/)
[442. Find All Duplicates in an Array](https://leetcode.com/problems/find-all-duplicates-in-an-array/)
[645. Set Mismatch](https://leetcode.com/problems/set-mismatch/)
[41. First Missing Positive](https://leetcode.com/problems/first-missing-positive/)
[1539. Kth Missing Positive Number](https://leetcode.com/problems/kth-missing-positive-number/)
