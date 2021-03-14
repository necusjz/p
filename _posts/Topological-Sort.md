---
title: Topological Sort
date: 2021-01-31 23:14:52
tags:
  - CodingInterview
---
Topological Sort is used to find a linear ordering of elements that have dependencies on each other. For example, if event "B" is dependent on event "A", "A" comes before "B" in topological ordering.

This pattern defines an easy way to understand the technique for performing topological sorting of a set of elements and then solves a few problems using it.

## Snippet
```python
from collections import defaultdict, deque

def findMinHeightTrees(self, n: int, edges: List[List[int]]) -> List[int]:
    # handle single vertex
    if n == 1:
        return [0]
    graph, degree = defaultdict(list), defaultdict(int)
    # initialize graph
    for u, v in edges:
        graph[u].append(v)
        graph[v].append(u)
        degree[u] += 1
        degree[v] += 1
    sources = deque()
    # obtain sources
    for num in range(n):
        if degree[num] == 1:
            sources.append(num)
    while n > 2:
        curr_len = len(sources)
        n -= curr_len
        for _ in range(curr_len):
            u = sources.popleft()
            for v in graph[u]:
                degree[v] -= 1
                if degree[v] == 1:
                    sources.append(v)
    return sources  
```

## LeetCode
[Course Schedule](https://leetcode.com/problems/course-schedule/)
[Course Schedule II](https://leetcode.com/problems/course-schedule-ii/)
[Minimum Height Trees](https://leetcode.com/problems/minimum-height-trees/)
