---
title: Designing Twitter Search
date: 2021-02-24 22:37:32
tags:
  - SystemDesign
---
## What is Twitter Search?
Twitter users can update their status whenever they like. Each status (called tweet) consists of plain text and our goal is to design a system that allows searching over all the user tweets.

## Requirements and Goals of the System
We need to design a system that can efficiently store and query tweets:
- Let's assume Twitter has 1.5 billion total users with 800 million daily active users;
- On average Twitter gets 400 million tweets every day;
- The average size of a tweet is 300 bytes;
- Let's assume there will be 500M searches every day;
- The search query will consist of multiple words combined with AND/OR;

## Capacity Estimation and Constraints
Since we have 400 million new tweets every day and each tweet on average is 300 bytes, the total storage we need, will be:
> 400M * 300 = 120 GB/day

Total storage per second:
> 120GB / 24hours / 3600sec ≈ 1.38 MB/second

## System APIs
We can have SOAP or REST APIs to expose the functionality of our service; following could be the definition of the search API:
```cpp
search(api_dev_key, search_terms, maximum_results_to_return, sort, page_token)
```

**Parameters**:
- api_dev_key: The API developer key of a registered account. This will be used to, among other things, throttle users based on their allocated quota;
- search_terms: A string containing the search terms;
- maximum_results_to_return: Number of tweets to return;
- sort: Latest first (0 - default), Best matched (1), Most liked (2);
- page_token: This token will specify a page in the result set that should be returned;

**Return**: A JSON containing information about a list of tweets matching the search query. Each result entry can have the user ID & name, tweet text, tweet ID, creation time, number of likes, etc.

## High Level Design
At the high level, we need to store all the tweets in a database and also build an index that can keep track of which word appears in which tweet. This index will help us quickly find tweets that the users are trying to search for:
![](https://raw.githubusercontent.com/was48i/mPOST/master/SystemDesign/educative/56.png)

## Detailed Component Design

## Fault Tolerance

## Cache

## Load Balancing

## Ranking
