---
title: Traffic Manager
abbrlink: 1841516736
date: 2022-04-23 23:44:09
tags: Azure
---
Azure Load Balancer is limited to providing high availability and scalability only to Azure VMs. Also, a single load balancer is limited to VMs in a single Azure region. If we want to provide high availability and scalability to other Azure services that are globally distributed, we must introduce a new component—*Azure Traffic Manager*. Traffic manager is **DNS-based and provides the ability to distribute traffic over services and spread traffic across Azure regions**. But traffic manager is not limited to Azure services only; we can add external endpoints as well.

## Create a traffic manager profile
Traffic manager provides load balancing to services, but traffic is routed and directed using DNS entries. **The frontend is an FQDN assigned during creation, and all traffic coming to traffic manager is distributed to endpoints in the backend**. The default routing method is *Performance*. The performance method will distribute traffic based on the best possible performance available.

For example, if we have more than one backend endpoint in the same region, traffic will be spread evenly. If the endpoints are located across different regions, traffic manager will **direct traffic to the endpoint closest to the incoming traffic in terms of geographical location and minimum network latency**.
<!--more-->
## Add an endpoint
After a traffic manager profile is created, we have the frontend endpoint and routing method defined. But we still **need to define where the traffic needs to go after it's reached traffic manager**. We need to add endpoints to the backend and define where the traffic is directed. Incoming requests reach traffic manager by hitting the frontend endpoint of traffic manager. Based on rules (mainly the routing method), traffic is then forwarded to the backend endpoints.

The load balancer works by forwarding traffic to private IP addresses. On the other hand, traffic manager uses public endpoints in the backend. **The supported endpoint types are Azure, external, and nested**. Based on the endpoint type, we can add Azure or external endpoints. Endpoints can be either (public) FQDNs or public IP addresses. Nested endpoints allow us to add other traffic manager profiles to the backend of the traffic manager.

Custom header settings **add specific HTTP headers to the health checks that traffic manager sends to endpoints under a profile**. They can be defined either at profile level (and applied to all endpoints under that profile) or for each individual endpoint. It comes in *header:value* format and we can add up to 8 pairs.

## Configure traffic based on weight
The default routing method for traffic manager is performance. The performance method will distribute traffic based on the best possible performance available. This method only **takes full effect if we have multiple instances of a service in multiple regions**. As this often isn't the case, other methods are available, such as distributed traffic (also referred to as the weighted routing method).

The weighted routing method will distribute traffic evenly across all endpoints in the backend. We can further **set weight settings to give an advantage to a certain endpoint** and say that some endpoints will receive a bigger or smaller percentage of the traffic. This method is usually used when we have multiple instances of an application in the same region, or for scaling out to increase performance.

## Configure traffic based on priority
Another routing method available is priority. Priority, as its name suggests, gives priority to some endpoints, while some endpoints are kept as backups. **Backup endpoints are only used if endpoints with priority become unavailable**. All traffic will first go to the endpoints with the highest priority. Other endpoints (with lower priority) are backed up, and traffic is routed to these endpoints only when higher-priority endpoints become unavailable.

**The default priority order is the order of adding endpoints to traffic manager**, where the endpoint added first becomes the one with the highest priority and the endpoint added last becomes the endpoint with the least priority. Priority can be changed under the endpoint settings.

## Configure traffic based on geographical location
Geographical location is another routing method in traffic manager. This method is based on network latency and directs a request based on the geographical location of the origin and the endpoint. When a request comes to traffic manager, based on the origin of the request, it's routed to the nearest endpoint in terms of region. This way, it **provides the least network latency possible**.

The geographic routing method **matches the request origin with the closest endpoint in terms of geographical location**. For example, let's say we have multiple endpoints, each on a different continent. If a request comes from Europe, it would make no sense to route it to Asia or North America. The geographic routing method will make sure that a request coming from Europe will be pointed to the endpoint located in Europe.

## Manage endpoints
After we add endpoints to traffic manager, we may **have to make changes over time**. This can be either to make adjustments or to completely remove endpoints. We can delete the endpoint to completely remove it from traffic manager, or we can disable it to temporarily remove it from the backend. We can also change the endpoint completely, to point to another service or a completely different type.

## Manage profiles
The traffic manager profile is another setting that we can manage and adjust. Although it has very limited options, where we can only *Disable* and *Enable* traffic manager, **managing the profile setting can be very useful for maintenance purposes**.

Managing the traffic manager profile with the disable and enable options will make the traffic manager frontend unavailable or available (based on the option selected). If we must apply changes across all endpoints, and changes need to be applied to all endpoints at the same time, we can **disable the traffic manager profile temporarily**. Once the changes are applied to all the endpoints, we can make traffic manager available again by enabling the profile.

## Configure traffic manager with load balancers
Combining traffic manager with load balancers is often done to provide maximum availability. Load balancers are limited to providing high availability to a set of resources located in the same region. This gives us an advantage if a single resource fails, as we have multiple instances of a resource. But what if a complete region fails? Load balancers can't handle resources in multiple regions, but we can combine load balancers with traffic manager to **provide even better availability with resources across Azure regions**.

Traffic manager will become the frontend, and we will add load balancers as the backend endpoints of traffic manager. **All requests will come to traffic manager first, and will then be routed to the appropriate load balancer in the backend**. Traffic manager will monitor the health of the load balancers, and if one of them becomes unavailable, the traffic will be rerouted to an active load balancer.
