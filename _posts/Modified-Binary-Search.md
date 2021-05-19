---
title: Modified Binary Search
date: 2021-01-31 20:46:57
tags:
  - CodingInterview
---
As we know, whenever we are given a sorted **Array** or **LinkedList** or **Matrix**, and we are asked to find a certain element, the best algorithm we can use is the _Binary Search_.

This pattern describes an efficient way to handle all problems involving _Binary Search_. We will go through a set of problems that will help us build an understanding of this pattern so that we can apply this technique to other problems we might come across in the interviews.

## Snippet
```python
def search(nums: List[int], target: int) -> bool:
    lo, hi = 0, len(nums) - 1
    while lo <= hi:
        mid = lo + ((hi - lo) >> 1)
        if nums[mid] == target:
            return True
        # handle duplicates
        if nums[lo] == nums[mid] == nums[hi]:
            lo += 1
            hi -= 1
        elif nums[lo] <= nums[mid]:
            if nums[lo] <= target < nums[mid]:
                hi = mid - 1
            else:
                lo = mid + 1
        else:
            if nums[mid] < target <= nums[hi]:
                lo = mid + 1
            else:
                hi = mid - 1
    return False
```

## LeetCode
[Find Smallest Letter Greater Than Target](https://leetcode.com/problems/find-smallest-letter-greater-than-target/)
[Find First and Last Position of Element in Sorted Array](https://leetcode.com/problems/find-first-and-last-position-of-element-in-sorted-array/)
[Search in Rotated Sorted Array](https://leetcode.com/problems/search-in-rotated-sorted-array/)
[Search in Rotated Sorted Array II](https://leetcode.com/problems/search-in-rotated-sorted-array-ii/)
[Find Minimum in Rotated Sorted Array](https://leetcode.com/problems/find-minimum-in-rotated-sorted-array/)
[Find Minimum in Rotated Sorted Array II](https://leetcode.com/problems/find-minimum-in-rotated-sorted-array-ii/)
