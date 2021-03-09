---
title: Cyclic Sort
date: 2021-01-30 16:55:01
tags:
  - CodingInterview
---
This pattern describes an interesting approach to deal with problems involving arrays containing numbers in a given range. For example, take the following problem:
> You are given an unsorted array containing numbers taken from the range "1" to "n". The array can have duplicates, which means that some numbers will be missing. Find all the missing numbers.

To efficiently solve this problem, we can use the fact that the input array contains numbers in the range of "1" to "n". For example, to efficiently sort the array, we can try placing each number in its correct place, i.e., placing "1" at index "0", placing "2" at index "1", and so on. Once we are done with the sorting, we can iterate the array to find all indices that are missing the correct numbers. These will be our required numbers.

## Snippet
```python
def firstMissingPositive(self, nums: List[int]) -> int:
    max_value = len(nums) + 1
    # remove useless items
    for i in range(len(nums)):
        if nums[i] < 1 or nums[i] > len(nums):
            nums[i] = 0
    nums.append(0)
    # record frequency
    for num in nums[:-1]:
        nums[num % max_value] += max_value
    # obtain missing
    for i in range(1, max_value):
        if nums[i] // max_value == 0:
            return i
    return max_value
    
```

## LeetCode
[Missing Number](https://leetcode.com/problems/missing-number/)
[Find All Numbers Disappeared in an Array](https://leetcode.com/problems/find-all-numbers-disappeared-in-an-array/)
[Find the Duplicate Number](https://leetcode.com/problems/find-the-duplicate-number/)
[Find All Duplicates in an Array](https://leetcode.com/problems/find-all-duplicates-in-an-array/)
[Set Mismatch](https://leetcode.com/problems/set-mismatch/)
[First Missing Positive](https://leetcode.com/problems/first-missing-positive/)
