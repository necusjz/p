---
title: Two Pointers
tags:
  - CodingInterview
abbrlink: 1858691252
date: 2021-01-30 15:49:52
---
> 一个很灵活的模式，有序与否都有应用的场景。需要根据题意来决定，while 循环的条件是 l < r 还是 l <= r。

In problems where we deal with sorted arrays (or linked lists) and need to find a set of elements that fulfill certain constraints, the _Two Pointers_ approach becomes quite useful. The set of elements could be a pair, a triplet or even a subarray. For example, take a look at the following problem:
> Given an array of sorted numbers and a target sum, find a pair in the array whose sum is equal to the given target.

To solve this problem, we can consider each element one by one (pointed out by the first pointer) and iterate through the remaining elements (pointed out by the second pointer) to find a pair with the given sum. The time complexity of this algorithm will be O(N^2) where "N" is the number of elements in the input array.

Given that the input array is **sorted**, an efficient way would be to start with one pointer in the beginning and another pointer at the end. At every step, we will see if the numbers pointed by the two pointers add up to the target sum. If they do not, we will do one of two things:
- If the sum of the two numbers pointed by the two pointers is greater than the target sum, this means that we need a pair with a less sum. So, to try more pairs, we can decrement the end-pointer;
- If the sum of the two numbers pointed by the two pointers is less than the target sum, this means that we need a pair with a greater sum. So, to try more pairs, we can increment the start-pointer;

<!--more-->
Here is the visual representation of this algorithm:
![](https://raw.githubusercontent.com/necusjz/p/master/CodingInterview/educative/02.png)

The time complexity of the above algorithm will be O(N).

## Snippets
```python
nums.sort()
n = len(nums)

ans = []
for i in range(n):
    # handle duplicates
    if i > 0 and nums[i] == nums[i-1]:
        continue
    
    l, r = i + 1, n - 1
    while l < r:
        curr_sum = nums[i] + nums[l] + nums[r]
        if curr_sum == 0:
            ans.append([nums[i], nums[l], nums[r]])
            
            # move both pointers
            l += 1
            r -= 1
            while l < r and nums[l] == nums[l-1]:
                l += 1
            while l < r and nums[r] == nums[r+1]:
                r -= 1
        
        elif curr_sum < 0:
            l += 1
        else:
            r -= 1

return ans
```

## LeetCode
[167. Two Sum II - Input Array Is Sorted](https://leetcode.com/problems/two-sum-ii-input-array-is-sorted/)
[26. Remove Duplicates from Sorted Array](https://leetcode.com/problems/remove-duplicates-from-sorted-array/)
[977. Squares of a Sorted Array](https://leetcode.com/problems/squares-of-a-sorted-array/)
[15. 3Sum](https://leetcode.com/problems/3sum/)
[16. 3Sum Closest](https://leetcode.com/problems/3sum-closest/)
[259. 3Sum Smaller](https://leetcode.com/problems/3sum-smaller/)
[713. Subarray Product Less Than K](https://leetcode.com/problems/subarray-product-less-than-k/)
[75. Sort Colors](https://leetcode.com/problems/sort-colors/)
[18. 4Sum](https://leetcode.com/problems/4sum/)
[844. Backspace String Compare](https://leetcode.com/problems/backspace-string-compare/)
[581. Shortest Unsorted Continuous Subarray](https://leetcode.com/problems/shortest-unsorted-continuous-subarray/)
