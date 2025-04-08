---
title: Azure Front Door and Azure CDN
abbrlink: 2503986917
date: 2022-04-25 00:32:07
tags: Azure
---
Several networking services in Azure are dedicated to application delivery. *Azure Front Door* and *Azure CDN* are services that allow us to create applications for global delivery and take advantage of the global network of Azure data centers. Leveraging this capability, we can **provide the same experience to our users, irrespective of their physical location**.

## Create a front door instance
*Azure Front Door* is used for the global routing of web traffic for applications distributed across different Azure regions. With front door, we can **define, manage, and monitor the routing of our web traffic and enable quick global failover**. It enables us to deliver our applications with the best performance and high availability.

Front door is an L7 load balancer, similar to application gateway. However, there is a difference as regards global distribution. In terms of global distribution, it is similar to another service—traffic manager. Essentially, front door **combines the best features of application gateway and traffic manager**—the security of application gateway and the distribution capability of traffic manager.

The successful sample rate ensures that endpoints in the backend are available and determines how many samples are sent at a time. *Successful Sample* **defines how many requests need to be successful in order for an endpoint to be considered healthy**.

*Latency Sensitivity* **sets the tolerance between the endpoint with the lowest latency and the rest of the endpoints**. For example, let's say the latency sensitivity setting is 30ms, while the latency of endpoint A is 15ms, that of endpoint B is 30ms, and that of endpoint C is 90ms. Endpoints A and B will be placed in the fastest pool as the difference in latency is lower than the sensitivity threshold, and endpoint C is out as it's above the threshold.

*Routing Rule* **defines how traffic is handled and whether specific traffic needs to be redirected or forwarded**. If URL rewrite is enabled, we can construct a URL that will be forwarded to a backend. If caching is enabled, front door will cache static content for faster delivery. Front door also includes a number of configurable options and rules that can help your web applications deliver a customer- and brand-centric service.
<!--more-->
## Create a CDN profile
*Azure CDN* is a distributed network that enables the faster delivery of web content to end users. Azure CDN **stores cached content on edge servers in multiple locations** (Azure regions). This content is then available to end users faster, with minimal network latency.

As these edge servers are distributed across Azure regions, we **have copies of content in practically every region in the world**. Content is then delivered to end users from the closest location, which provides minimum network latency. Let's say an application is hosted in West Europe, and a user is located in the western part of the US. Content, in this case, will not be delivered from the original location, but from the location closest to the user, in this instance, West US. This way, we can ensure that each user has the best experience and delivery wherever they are.
