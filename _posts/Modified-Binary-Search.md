---
title: Modified Binary Search
tags:
  - CodingInterview
abbrlink: 581537989
date: 2021-01-31 20:46:57
---
As we know, whenever we are given **a sorted array or linked list or matrix**, and we are asked to find a certain element, the best algorithm we can use is _Binary Search_.

This pattern describes an efficient way to handle all problems involving _Binary Search_. We will go through a set of problems that will help us build an understanding of this pattern so that we can apply this technique to other problems we might come across in the interviews.

## Snippets
```python
lo, hi = 0, len(nums) - 1
while lo <= hi:
    mid = lo + ((hi - lo) >> 1)
    
    if nums[mid] >= target:
        # find leftmost element
        if mid == 0 or nums[mid-1] < target:
            return mid
        
        hi = mid - 1
    else:
        lo = mid + 1

return len(nums)
```

## LeetCode
[704. Binary Search](https://leetcode.com/problems/binary-search/)
[35. Search Insert Position](https://leetcode.com/problems/search-insert-position/)
[744. Find Smallest Letter Greater Than Target](https://leetcode.com/problems/find-smallest-letter-greater-than-target/)
[34. Find First and Last Position of Element in Sorted Array](https://leetcode.com/problems/find-first-and-last-position-of-element-in-sorted-array/)
[702. Search in a Sorted Array of Unknown Size](https://leetcode.com/problems/search-in-a-sorted-array-of-unknown-size/)
[270. Closest Binary Search Tree Value](https://leetcode.com/problems/closest-binary-search-tree-value/)
[852. Peak Index in a Mountain Array](https://leetcode.com/problems/peak-index-in-a-mountain-array/)
[1095. Find in Mountain Array](https://leetcode.com/problems/find-in-mountain-array/)
[33. Search in Rotated Sorted Array](https://leetcode.com/problems/search-in-rotated-sorted-array/)
[153. Find Minimum in Rotated Sorted Array](https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/)
