---
title: Azure Application Gateway and Azure WAF
abbrlink: 3697556407
date: 2022-04-25 00:22:47
tags: Azure
---
*Azure Application Gateway* is essentially a load balancer for web traffic, but it also provides us with better traffic control. Traditional load balancers operate on the transport layer and allow us to route traffic based on protocol (TCP or UDP) and IP address, mapping IP addresses, and protocols in the frontend to IP addresses and protocols in the backend. This **classic operation mode is often referred to as layer 4**.

Application gateway expands on that and allows us to **use hostnames and paths to determine where traffic should go, making it a layer 7 load balancer**. For example, we can have multiple servers that are optimized for different things. If one of our servers is optimized for video, then all video requests should be routed to that specific server based on the incoming URL request.

## Create an application gateway
*Azure Application Gateway* can be used as a simple load balancer to perform traffic distribution from the frontend to the backend based on protocols and ports. But it can also expand on that and perform additional routing based on hostnames and paths. This allows us to have resource pools based on rules and also allows us to optimize performance. Using these options and performing routing based on context will increase application performance, along with providing high availability. Of course, in this case, we need to **have multiple resources for each performance type in each backend pool** (each performance type requests a separate backend pool).

Using these additional rules, we can **route incoming requests to endpoints that are optimized for certain roles**. For example, we can have multiple backend pools with different settings that are optimized to perform only specific tasks. Based on the nature of the incoming requests, the application gateway will route the requests to the appropriate backend pool. This approach, along with high availability, will provide better performance by routing each request to a backend pool that will process the request in a more optimized way.

We can set up autoscaling for application gateway (available only for V2) with additional information for the minimum and maximum number of units. This way, application gateway will **scale based on demand and ensure that performance is not impacted**, even with the maximum number of requests.
<!--more-->
## Configure backend pools
After the application gateway is created, we must define the backend pools. Traffic coming to the frontend of the application gateway will be forwarded to the backend pools. Backend pools in application gateways are the same as backend pools in load balancers and are defined as possible destinations where traffic will be routed based on other settings. With backend pools, we define targets to which traffic will be forwarded. As the application gateway allows us to define routing for each request, it's best to **have targets based on performance and types grouped in the same way**.

For example, if we have multiple web servers, these should be placed in the same backend pool. Servers used for data processing should be placed in a separate pool, and servers used for video in another separate pool. This way, we can separate pools based on performance types, and route traffic based on operations that need to be completed. This will increase the performance of our application, as **each request will be processed by the resource best suited for a specific task**. To achieve high availability, we should add more servers to each backend pool.

## Configure HTTP settings
HTTP settings in application gateways are used for validation and various traffic settings. Their main purpose is to **ensure that requests are directed to the appropriate backend pool**. Some other HTTP settings are also included, such as *Cookie-baed Affinity* or *Connection Draining*. *Override* settings are also part of HTTP settings—these will allow you to redirect if an incomplete or incorrect request is sent.

Affinity allows us to route requests from the same source to the same target server in the backend pool. Connection draining will **control the behavior when the server is removed from the backend pool**. If this is enabled, the server will help maintain in-flight requests to the same server. Override settings allow us to override the path of the URL to a different path or a completely new domain, before forwarding the request to the backend pool.

## Configure listeners
Listeners in an application gateway listen for any incoming requests. After a new request is detected, it's forwarded to the backend pool based on the rules and settings we have defined. A listener monitors for new requests coming to the application gateway. **Each listener monitors only one frontend IP address and only one port**. If we have two frontend IPs (one public and one private) and traffic coming in over multiple protocols and ports, we must create a listener for each IP address and each port that traffic may be coming to.

**The basic type of listener is used when the listener listens to a single domain**; it's usually used when we host a single application behind an application gateway. A multi-site listener is used when we have more than one application behind the application gateway and we need to configure routing based on a host name or domain name.

## Configure rules
Rules in application gateways are used to determine how traffic flows. Different settings determine where a specific request is forwarded to and how this is done. Using rules, we can **tie some previously created settings together**. We define a listener that specifies which request on what IP address we are expecting on which port. Then, these requests are forwarded to the backend pool; forwarding is performed based on the HTTP settings. Optionally, we can also add redirection to the rules.

## Configure probes
Probes in application gateway are used to monitor the health of the backend targets. Each endpoint is monitored, and **if one is found to be unhealthy, it is temporarily taken out of rotation and requests are not forwarded**. Once the status changes, it's added back. This prevents requests from being sent to unhealthy endpoints that can't serve the request. *Protocol*, *Host*, and *Path* define what probe is being monitored. *Interval* defines how often checks are performed. *Timeout* defines how much time must pass before the check is declared to have failed. Finally, *Unhealthy Threshold* is used to set how many failed checks must occur before the endpoint is declared unavailable.

## Configure a WAF
*Azure Web Application Firewall* is an additional setting for the application gateway. It's used to **increase the security of applications behind the application gateway**, and it also provides centralized protection. The WAF feature helps increase security by checking all incoming traffic. As this can slow down performance, we can exclude some items that are creating false positives, especially when it comes to items of significant size. Excluded items will not be inspected. A WAF can work in two modes: *Detection* and *Prevention*. Detection will only detect if a malicious request is sent, while prevention will stop any such request.

## Customize WAF rules
A WAF comes with a predetermined set of rules. These rules are enforced to increase application security and prevent malicious requests. We can change these rules to address specific issues or requirements as needed. A WAF comes with all rules activated by default. **This can slow down performance, so we can disable some of the rules if needed**. Also, there are three rule sets available—*OWASP 2.2.9*, *OWASP 3.0*, and *OWASP 3.1*. The default (and recommended) rule set is OWASP 3.0, but we can switch between rule sets as required.

## Create a WAF policy
A WAF policy allows us to **handle WAF settings and configurations as a separate resource**. By doing so, we can apply the same policy to multiple resources instead of individual application gateways. A WAF policy can be associated with *Application Gateway*, *Front Door*, or *CDN*. Our WAF policy contains all the required settings and configuration for our WAF and it can be associated with multiple resources but only one type at a time. The *Mode* determines what kind of action is going to be taken when an issue is detected. *Prevention* will block suspicious requests, and *Detection* will only create a log entry.
