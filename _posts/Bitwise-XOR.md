---
title: Bitwise XOR
date: 2021-01-31 20:56:43
tags:
  - CodingInterview
---
_XOR_ is a logical bitwise operator that returns 0 (false) if both bits are the same and returns 1 (true) otherwise. In other words, it only returns 1 if exactly one bit is set to 1 out of the two bits in comparison:
![](https://raw.githubusercontent.com/snlndod/mPOST/master/CodingInterview/educative/04.png)

It is surprising to know the approaches that the _XOR_ operator enables us to solve certain problems. For example, let's take a look at the following problem:
> Given an array of n-1 integers in the range from 1 to n, find the one number that is missing from the array.

Example:
```python
Input: 1, 5, 2, 6, 4
Answer: 3
```

A straight forward approach to solve this problem can be:
1. Find the sum of all integers from 1 to n; let's call it: s1;
2. Subtract all the numbers in the input array from s1; this will give us the missing number;

<!--more-->
This is what the algorithm will look like:
```python
def find_missing_number(nums):
    n = len(nums) + 1
    s1 = 0
    # find sum of all numbers from 1 to n
    for num in range(1, n + 1):
        s1 += num
    # subtract all numbers in input from sum
    for num in nums:
        s1 -= num
    # s1, now, is the missing number
    return s1
```

**Time & Space Complexity**: The time complexity of the above algorithm is O(n) and the space complexity is O(1).

> While finding the sum of numbers from 1 to n, we can get integer overflow when n is large.

Remember the important property of XOR that it returns 0 if both the bits in comparison are the same. In other words, XOR of a number with itself will always result in 0. This means that if we XOR all the numbers in the input array with all numbers from the range 1 to n then each number in the input is going to get zeroed out except the missing number. Following are the set of steps to find the missing number using XOR:
1. XOR all the numbers from 1 to n, let's call it: x1;
2. XOR all the numbers in the input array, let's call it: x2;
3. The missing number can be found by x1 XOR x2;

Here is what the algorithm will look like:
```python
def find_missing_number(nums):
    n = len(nums) + 1
    x1 = 1
    # x1 represents XOR of all values from 1 to n
    for num in range(2, n + 1):
        x1 = x1 ^ num
    x2 = nums[0]
    # x2 represents XOR of all values in array
    for num in nums[1:]:
        x2 = x2 ^ num
    # missing number is the XOR of x1 and x2
    return x1 ^ x2
```

**Time & Space Complexity**: The time complexity of the above algorithm is O(n) and the space complexity is O(1). The time and space complexities are the same as that of the previous solution but, in this algorithm, we will not have any integer overflow problem.

Following are some important properties of XOR to remember:
- Taking XOR of a number with itself returns 0, e.g.,
    - 1 ^ 1 = 0;
    - 29 ^ 29 = 0;
- Taking XOR of a number with 0 returns the same number, e.g.,
    - 1 ^ 0 = 1;
    - 31 ^ 0 = 31;
- XOR is Associative & Commutative, which means:
    - (a ^ b) ^ c = a ^ (b ^ c);
    - a ^ b = b ^ a;

## Snippet
```python
def single_number(nums: List[int]) -> List[int]:
    n1xn2 = nums[0]
    for num in nums[1:]:
        n1xn2 = n1xn2 ^ num
    last = 1
    # obtain last one
    while not last & n1xn2:
        last = last << 1
    num1 = num2 = 0
    # divide into two parts
    for num in nums:
        if num & last:
            num1 = num1 ^ num
        else:
            num2 = num2 ^ num
    return [num1, num2]
"""
Two's Complement
"""
def find_complement(num: int) -> int:
    n = num
    bit_cnt = 0
    # obtain bit count
    while n:
        bit_cnt += 1
        n = n >> 1
    all_sets = 2 ** bit_cnt - 1
    return num ^ all_sets
```

## LeetCode
[Single Number](https://leetcode.com/problems/single-number/)
[Single Number III](https://leetcode.com/problems/single-number-iii/)
[Number Complement](https://leetcode.com/problems/number-complement/)
[Flipping an Image](https://leetcode.com/problems/flipping-an-image/)
