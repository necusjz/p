---
title: Bitwise XOR
tags:
  - CodingInterview
abbrlink: 836241768
date: 2021-01-31 20:56:43
---
_Bitwise XOR_ returns 0 (false) if both bits are the same and returns 1 (true) otherwise. In other words, it only returns 1 if exactly one bit is set to 1 out of the two bits in comparison:
![](https://raw.githubusercontent.com/necusjz/p/master/CodingInterview/educative/04.png)

It is surprising to know the approaches that the XOR operator enables us to solve certain problems. For example, let's take a look at the following problem:
> Given an array of n-1 integers in the range from 1 to n, find the one number that is missing from the array.

Example:
```python
Input: 1, 5, 2, 6, 4
Answer: 3
```

A straight forward approach to solve this problem can be:
1. Find the sum of all integers from 1 to n; let's call it: s1.
2. Subtract all the numbers in the input array from s1; this will give us the missing number.

<!--more-->
This is what the algorithm will look like:
```python
def find_missing_number(nums):
    n = len(nums) + 1
    # find sum of all numbers from 1 to n
    s1 = 0
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

Remember the important property of XOR that it returns 0 if both the bits in comparison are the same. In other words, **XOR of a number with itself will always result in 0**. This means that if we XOR all the numbers in the input array with all numbers from the range 1 to n then each number in the input is going to get zeroed out except the missing number. Following are the set of steps to find the missing number using XOR:
1. XOR all the numbers from 1 to n, let's call it: x1.
2. XOR all the numbers in the input array, let's call it: x2.
3. The missing number can be found by x1 XOR x2.

Here is what the algorithm will look like:
```python
def find_missing_number(nums):
    n = len(nums) + 1
    # x1 represents XOR of all values from 1 to n
    x1 = 0
    for num in range(1, n + 1):
        x1 = x1 ^ num
    # x2 represents XOR of all values in array
    x2 = 0
    for num in nums:
        x2 = x2 ^ num
    # missing number is the XOR of x1 and x2
    return x1 ^ x2
```

**Time & Space Complexity**: The time complexity of the above algorithm is O(n) and the space complexity is O(1). The time and space complexities are the same as that of the previous solution but, in this algorithm, we will not have any integer overflow problem.

Following are some important properties of XOR to remember:
- Taking XOR of a number with itself returns 0, e.g.,
    - 1 ^ 1 = 0
    - 29 ^ 29 = 0
- Taking XOR of a number with 0 returns the same number, e.g.,
    - 1 ^ 0 = 1
    - 29 ^ 0 = 29
- XOR is Associative & Commutative, which means:
    - (a ^ b) ^ c = a ^ (b ^ c)
    - a ^ b = b ^ a

## Snippets
```python
n1xn2 = 0
for num in nums:
    n1xn2 ^= num
# isolate rightmost 1-bit
low_bit = n1xn2 & -n1xn2

n1, n2 = 0, 0
for num in nums:
    if num & low_bit:
        n1 ^= num
    else:
        n2 ^= num
return [n1, n2]
```

## LeetCode
[136. Single Number](https://leetcode.com/problems/single-number/)
[260. Single Number III](https://leetcode.com/problems/single-number-iii/)
[476. Number Complement](https://leetcode.com/problems/number-complement/)
[832. Flipping an Image](https://leetcode.com/problems/flipping-an-image/)
