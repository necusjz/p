---
title: Designing Facebook's Newsfeed
date: 2021-02-26 16:28:27
tags:
  - SystemDesign
---
## What is Facebook's Newsfeed?
A Newsfeed is the constantly updating list of stories in the middle of Facebook’s homepage. It includes status updates, photos, videos, links, app activity, and "likes" from people, pages, and groups that a user follows on Facebook. In other words, it is a compilation of a complete scrollable version of your friends' and your life story from photos, videos, locations, status updates, and other activities.
For any social media site you design - Twitter, Instagram, or Facebook - you will need a newsfeed system to display updates from friends and followers.

## Requirements and Goals of the System
Let's design a newsfeed for Facebook with the following requirements:
- **Functional Requirements**:
    1. Newsfeed will be generated based on the posts from the people, pages, and groups that a user follows;
    2. A user may have many friends and follow a large number of pages/groups;
    3. Feeds may contain images, videos, or just text;
    4. Our service should support appending new posts as they arrive to the newsfeed for all active users;
- **Non-Functional Requirements**:
    1. Our system should be able to generate any user's newsfeed in real-time - maximum latency seen by the end user would be 2s;
    2. A post shouldn't take more than 5s to make it to a use's feed assuming a new newsfeed request comes in;

## Capacity Estimation and Constraints
Let's assume on average a user has 300 friends and follows 200 pages.

**Traffic estimates**: Let's assume 300M daily active users with each user fetching their timeline an average of five times a day. This will result in 1.5B newsfeed requests per day or approximately 17,500 requests per second.

**Storage estimates**: On average, let's assume we need to have around 500 posts in every user's feed that we want to keep in memory for a quick fetch. Let's also assume that on average each post would be 1KB in size. This would mean that we need to store roughly 500KB of data per user. To store all this data for all the active users we would need 150TB of memory. If a server can hold 100GB we would need around 1500 machines to keep the top 500 posts in memory for all active users.

## System APIs

## Database Design

## High-Level System Design

## Detailed Component Design

## Feed Ranking

## Data Partitioning
