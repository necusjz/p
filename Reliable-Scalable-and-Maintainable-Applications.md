---
title: 'Reliable, Scalable, and Maintainable Applications'
date: 2020-08-09 22:27:01
tags:
  - DDIA
---
![](https://raw.githubusercontent.com/was48i/mPOST/master/DDIA/01.png)

A data-intensive application is typically built from standard building blocks that provide commonly needed functionality. For example, many applications need to:
- Store data so that they, or another application, can find it again later (`databases`);
- Remember the result of an expensive operation, to speed up reads (`caches`);
- Allow users to search data by keyword or filter it in various ways (`search indexes`);
- Send a message to another process, to be handled asynchronously (`stream processing`);
- Periodically crunch a large amount of accumulated data (`batch processing`);

<!--more-->
## Thinking About Data Systems
Many new tools for data storage and processing have emerged in recent years. They are optimized for a variety of different use cases, and they no longer neatly fit into traditional categories. For example, there are datastores that are also used as message queues (Redis), and there are message queues with database-like durability guarantees (Apache Kafka). **The boundaries between the categories are becoming blurred**.

Secondly, increasingly many applications now have such demanding or wide-ranging requirements that a single tool can no longer meet all of its data processing and storage needs. Instead, the work is broken down into tasks that can be performed efficiently on a single tool, and **those different tools are stitched together using application code**.

In this book, we focus on three concerns that are important in most software systems:
- `Reliability`: The system should continue to work correctly (performing the correct function at the desired level of performance) even in the face of adversity (hardware or software faults, and even human error);
- `Scalability`: As the system grows (in data volume, traffic volume, or complexity), there should be reasonable ways of dealing with that growth;
- `Maintainability`: Over time, many different people will work on the system (engineering and operations, both maintaining current behavior and adapting the system to new use cases), and they should all be able to work on it productively;

## Reliability
Note that a `fault` is not the same as a `failure`. A fault is usually defined as one component of the system deviating from its spec, whereas a failure is when the system as a whole stops providing the required service to the user. It is impossible to reduce the probability of a fault to zero; therefore it is usually best to **design fault-tolerance mechanisms** that prevent faults from causing failures. In this book we cover several techniques for building reliable systems from unreliable parts.

### Hardware Faults
Hard disks are reported as having a mean time to failure (`MTTF`) of about 10 to 50 years. Thus, on a storage cluster with 10,000 disks, we should expect on average one disk to die per day.

Until recently, **redundancy of hardware components was sufficient for most applications**, since it makes total failure of a single machine fairly rare. As long as you can restore a backup onto a new machine fairly quickly, the downtime in case of failure is not catastrophic in most applications. Thus, multi-machine redundancy was only required by a small number of applications for which high availability was absolutely essential.

Hence there is a move toward systems that can tolerate the loss of entire machines, **by using software fault-tolerance techniques in preference or in addition to hardware redundancy**. Such systems also have operational advantages: a single-server system requires planned downtime if you need to reboot the machine (to apply operating system security patches, for example), whereas a system that can tolerate machine failure can be patched one node at a time, without downtime of the entire system.

### Software Errors
Another class of fault is a systematic error within the system. Such faults are harder to anticipate, and because they are correlated across nodes, **they tend to cause many more system failures than uncorrelated hardware faults**.

There is no quick solution to the problem of systematic faults in software. **Lots of small things can help:** carefully thinking about assumptions and interactions in the system; thorough testing; process isolation; allowing processes to crash and restart; measuring, monitoring, and analyzing system behavior in production. If a system is expected to provide some guarantee (for example, in a message queue, that the number of incoming messages equals the number of outgoing messages), it can constantly check itself while it is running and raise an alert if a discrepancy is found.

### Human Errors
Humans design and build software systems, and the operators who keep the systems running are also human. Even when they have the best intentions, **humans are known to be unreliable**. For example, one study of large internet services found that configuration errors by operators were the leading cause of outages, whereas hardware faults (servers or network) played a role in only 10–25% of outages.

### How Important Is Reliability?
There are situations in which we may choose to sacrifice reliability in order to reduce development cost (e.g., when developing a prototype product for an unproven market) or operational cost (e.g., for a service with a very narrow profit margin)—but **we should be very conscious of when we are cutting corners**.

## Scalability
Even if a system is working reliably today, that doesn’t mean it will necessarily work reliably in the future. **One common reason for degradation is increased load**: perhaps the system has grown from 10,000 concurrent users to 100,000 concurrent users, or from 1 million to 10 million. Perhaps it is processing much larger volumes of data than it did before.

### Describing Load
First, we need to succinctly describe the current load on the system; only then can we discuss growth questions (what happens if our load doubles?). Load can be described with a few numbers which we call `load parameters`. The best choice of parameters depends on the architecture of your system: it may be requests per second to a web server, the ratio of reads to writes in a database, the number of simultaneously active users in a chat room, the hit rate on a cache, or something else. Perhaps the average case is what matters for you, or perhaps your bottleneck is dominated by a small number of extreme cases.

To make this idea more concrete, let’s consider Twitter as an example, using data published in November 2012. Two of Twitter’s main operations are:
- **Post tweet**: A user can publish a new message to their followers (4.6k requests/sec on average, over 12k requests/sec at peak);
- **Home timeline**: A user can view tweets posted by the people they follow (300k requests/sec);

> **fan-out**: A term borrowed from electronic engineering, where it describes the number of logic gate inputs that are attached to another gate’s output. The output needs to supply enough current to drive all the attached inputs. In transaction processing systems, we use it to describe the number of requests to other services that we need to make in order to serve one incoming request.

Simply handling 12,000 writes per second (the peak rate for posting tweets) would be fairly easy. However, Twitter’s scaling challenge is not primarily due to tweet volume, but due to `fan-out`—each user follows many people, and each user is followed by many people. There are broadly two ways of implementing these two operations:
1. Posting a tweet simply inserts the new tweet into a global collection of tweets. When a user requests their home timeline, **look up all the people they follow, find all the tweets for each of those users**, and merge them (sorted by time). In a relational database like in Figure 1-2, you could write a query such as:
```
SELECT tweets.*, users.* 
FROM tweets
    JOIN users ON tweets.sender_id = users.id 
    JOIN follows ON follows.followee_id = users.id 
WHERE follows.follower_id = current_user
```
2. Maintain a cache for each user’s home timeline—like a mailbox of tweets for each recipient user (see Figure 1-3). When a user posts a tweet, **look up all the people who follow that user, and insert the new tweet into each of their home timeline caches**. The request to read the home timeline is then cheap, because its result has been computed ahead of time.

![](https://raw.githubusercontent.com/was48i/mPOST/master/DDIA/02.png)

![](https://raw.githubusercontent.com/was48i/mPOST/master/DDIA/03.png)

The first version of Twitter used approach 1, but the systems struggled to keep up with the load of home timeline queries, so the company switched to approach 2. This works better because the average rate of published tweets is almost two orders of magnitude lower than the rate of home timeline reads, and so in this case **it’s preferable to do more work at write time and less at read time**.

The final twist of the Twitter anecdote: now that approach 2 is robustly implemented, Twitter is moving to a hybrid of both approaches. Most users’ tweets continue to be fanned out to home timelines at the time when they are posted, but a small number of users with a very large number of followers (i.e., celebrities) are excepted from this fan-out. **Tweets from any celebrities that a user may follow are fetched separately and merged with that user’s home timeline when it is read, like in approach 1**. This hybrid approach is able to deliver consistently good performance.

### Describing Performance
Once you have described the load on your system, you can investigate what happens when the load increases. You can look at it in two ways:
- When you increase a load parameter and keep the system resources (CPU, memory, network bandwidth, etc.) unchanged, how is the performance of your system affected?
- When you increase a load parameter, how much do you need to increase the resources if you want to keep performance unchanged?

In a batch processing system such as Hadoop, we usually care about `throughput`—the number of records we can process per second, or the total time it takes to run a job on a dataset of a certain size. In online systems, what’s usually more important is the service’s `response time`—that is, the time between a client sending a request and receiving a response.

> **Latency** and **response time** are often used synonymously, but they are not the same. The response time is what the client sees: besides the actual time to process the request (the service time), it includes network delays and queueing delays. Latency is the duration that a request is waiting to be handled—during which it is latent, awaiting service.

Even if you only make the same request over and over again, you’ll get a slightly different response time on every try. In practice, in a system handling a variety of requests, the response time can vary a lot. We therefore need to think of response time not as a single number, but as **a distribution of values that you can measure**.

![](https://raw.githubusercontent.com/was48i/mPOST/master/DDIA/04.png)

Usually it is better to use `percentiles`. If you take your list of response times and sort it from fastest to slowest, then the `median` is the halfway point: for example, if your median response time is 200 ms, that means half your requests return in less than 200 ms, and half your requests take longer than that.

High percentiles of response times, also known as `tail latencies`, are important because they **directly affect users’ experience of the service**. For example, Amazon describes response time requirements for internal services in terms of the 99.9th percentile, even though it only affects 1 in 1,000 requests. This is because the customers with the slowest requests are often those who have the most data on their accounts because they have made many purchases—that is, they’re the most valuable customers.

For example, percentiles are often used in `service level objectives` (SLOs) and `service level agreements` (SLAs), contracts that define the expected performance and availability of a service. An SLA may state that the service is considered to be up if it has a median response time of less than 200 ms and a 99th percentile under 1 s (if the response time is longer, it might as well be down).

Queueing delays often account for a large part of the response time at high percentiles. As **a server can only process a small number of things in parallel** (limited, for example, by its number of CPU cores), it only takes a small number of slow requests to hold up the processing of subsequent requests—an effect sometimes known as `head-of-line blocking`. Even if those subsequent requests are fast to process on the server, the client will see a slow overall response time due to the time waiting for the prior request to complete. Due to this effect, **it is important to measure response times on the client side**.

The naïve implementation is to keep a list of response times for all requests within the time window and to sort that list every minute. If that is too inefficient for you, there are algorithms that can calculate a good approximation of percentiles at minimal CPU and memory cost, such as `forward decay`, `t-digest`, or `HdrHistogram`. Beware that **averaging percentiles**, e.g., to reduce the time resolution or to combine data from several machines, **is mathematically meaningless**—the right way of aggregating response time data is to add the histograms.

### Approaches for Coping with Load
People often talk of a dichotomy between **scaling up (vertical scaling, moving to a more powerful machine)** and **scaling out (horizontal scaling, distributing the load across multiple smaller machines)**. Distributing load across multiple machines is also known as a `shared-nothing` architecture. A system that can run on a single machine is often simpler, but high-end machines can become very expensive, so very intensive workloads often can’t avoid scaling out. In reality, **good architectures usually involve a pragmatic mixture of approaches**: for example, using several fairly powerful machines can still be simpler and cheaper than a large number of small virtual machines.

Some systems are `elastic`, meaning that they can automatically add computing resources when they detect a load increase, whereas other systems are scaled manually (a human analyzes the capacity and decides to add more machines to the system). **An elastic system can be useful if load is highly unpredictable, but manually scaled systems are simpler and may have fewer operational surprises**.

While distributing stateless services across multiple machines is fairly straightforward, taking stateful data systems from a single node to a distributed setup can introduce a lot of additional complexity. For this reason, common wisdom until recently was **to keep your database on a single node (scale up) until scaling cost or high availability requirements forced you to make it distributed**.

**An architecture that scales well for a particular application is built around assumptions** of which operations will be common and which will be rare—the load parameters. If those assumptions turn out to be wrong, the engineering effort for scaling is at best wasted, and at worst counterproductive.

> Even though they are specific to a particular application, scalable architectures are nevertheless usually built from **general-purpose building blocks**, arranged in **familiar patterns**.

## Maintainability
It is well known that the majority of the cost of software is not in its initial development, but in **its ongoing maintenance**—fixing bugs, keeping its systems operational, investigating failures, adapting it to new platforms, modifying it for new use cases, repaying technical debt, and adding new features.

However, we can and should design software in such a way that it will hopefully minimize pain during maintenance, and thus avoid creating `legacy software` ourselves. To this end, we will pay particular attention to three design principles for software systems:
- **Operability**: Make it easy for operations teams to keep the system running smoothly;
- **Simplicity**: Make it easy for new engineers to understand the system, by removing as much complexity as possible from the system. (Note this is not the same as simplicity of the user interface.);
- **Evolvability**: Make it easy for engineers to make changes to the system in the future, adapting it for unanticipated use cases as requirements change. Also known as `extensibility`, `modifiability`, or `plasticity`;

### Operability: Making Life Easy for Operations
It has been suggested that “good operations can often work around the limitations of bad (or incomplete) software, but good software cannot run reliably with bad operations”. While some aspects of operations can and should be automated, **it is still up to humans to set up that automation in the first place** and to make sure it’s working correctly.

Operations teams are vital to keeping a software system running smoothly. **A good operations team typically is responsible for the following**, and more:
- Monitoring the health of the system and quickly restoring service if it goes into a bad state;
- Tracking down the cause of problems, such as system failures or degraded performance;
- Keeping software and platforms up to date, including security patches;
- Keeping tabs on how different systems affect each other, so that a problematic change can be avoided before it causes damage;
- Anticipating future problems and solving them before they occur (e.g., capacity planning);
- Establishing good practices and tools for deployment, configuration management, and more;
- Performing complex maintenance tasks, such as moving an application from one platform to another;
- Maintaining the security of the system as configuration changes are made;
- Defining processes that make operations predictable and help keep the production environment stable;
- Preserving the organization’s knowledge about the system, even as individual people come and go;

Good operability means making routine tasks easy, allowing the operations team to focus their efforts on high-value activities. **Data systems can do various things to make routine tasks easy**, including:
- Providing visibility into the runtime behavior and internals of the system, with good monitoring;
- Providing good support for automation and integration with standard tools;
- Avoiding dependency on individual machines (allowing machines to be taken down for maintenance while the system as a whole continues running uninterrupted);
- Providing good documentation and an easy-to-understand operational model (“If I do X, Y will happen”);
- Providing good default behavior, but also giving administrators the freedom to override defaults when needed;
- Self-healing where appropriate, but also giving administrators manual control over the system state when needed;
- Exhibiting predictable behavior, minimizing surprises;

### Simplicity: Managing Complexity
Small software projects can have delightfully simple and expressive code, but **as projects get larger, they often become very complex and difficult to understand**. This complexity slows down everyone who needs to work on the system, further increasing the cost of maintenance. A software project mired in complexity is sometimes described as a `big ball of mud`.

Making a system simpler does not necessarily mean reducing its functionality; it can also mean removing `accidental complexity`. Moseley and Marks define complexity as accidental if it is not inherent in the problem that the software solves (as seen by the users) but **arises only from the implementation**.

One of the best tools we have for removing accidental complexity is `abstraction`. A good abstraction can hide a great deal of implementation detail behind a clean, simple-to-understand façade. A good abstraction can also be used for a wide range of different applications. Not only is this reuse more efficient than reimplementing a similar thing multiple times, but **it also leads to higher-quality software**, as quality improvements in the abstracted component benefit all applications that use it.

However, finding good abstractions is very hard. In the field of distributed systems, although there are many good algorithms, **it is much less clear how we should be packaging them into abstractions** that help us keep the complexity of the system at a manageable level.

### Evolvability: Making Change Easy
**It’s extremely unlikely that your system’s requirements will remain unchanged forever**. They are much more likely to be in constant flux: you learn new facts, previously unanticipated use cases emerge, business priorities change, users request new features, new platforms replace old platforms, legal or regulatory requirements change, growth of the system forces architectural changes, etc.

Most discussions of these `Agile` techniques focus on a fairly small, local scale (a couple of source code files within the same application). In this book, **we search for ways of increasing agility on the level of a larger data system**, perhaps consisting of several different applications or services with different characteristics. For example, how would you “refactor” Twitter’s architecture for assembling home timelines from approach 1 to approach 2?

## Summary
In this chapter, we have explored **some fundamental ways of thinking about data-intensive applications**. These principles will guide us through the rest of the book, where we dive into deep technical detail.

An application has to meet various requirements in order to be useful. There are `functional requirements` (what it should do, such as allowing data to be stored, retrieved, searched, and processed in various ways), and some `nonfunctional requirements` (general properties like security, reliability, compliance, scalability, compatibility, and maintainability). In this chapter we discussed reliability, scalability, and maintainability in detail.

`Reliability` means making systems work correctly, even when faults occur. Faults can be in hardware (typically random and uncorrelated), software (bugs are typically systematic and hard to deal with), and humans (who inevitably make mistakes from time to time). Fault-tolerance techniques can hide certain types of faults from the end user.

`Scalability` means having strategies for keeping performance good, even when load increases. In order to discuss scalability, we first need ways of describing load and performance quantitatively. We briefly looked at Twitter’s home timelines as an example of describing load, and response time percentiles as a way of measuring performance. In a scalable system, you can add processing capacity in order to remain reliable under high load.

`Maintainability` has many facets, but in essence it’s about making life better for the engineering and operations teams who need to work with the system. Good abstractions can help reduce complexity and make the system easier to modify and adapt for new use cases. Good operability means having good visibility into the system’s health, and having effective ways of managing it.

There is unfortunately no easy fix for making applications reliable, scalable, or maintainable. However, **there are certain patterns and techniques that keep reappearing in different kinds of applications**. In the next few chapters we will take a look at some examples of data systems and analyze how they work toward those goals.
