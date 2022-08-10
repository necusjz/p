---
title: Load Balancers
abbrlink: 2042627151
date: 2022-04-23 18:02:25
tags: Azure
---
*Azure Load Balancer* is used to support scaling and high availability for applications and services. A load balancer is primarily composed of **three components—a frontend, a backend, and routing rules**. Requests coming to the frontend of a load balancer are distributed based on routing rules to the backend, where we place multiple instances of a service.

This can be used for performance-related reasons, where we would like to distribute traffic equally between endpoints in the backend, or for high availability, where multiple instances of services are used to increase the chances that at least one endpoint will be available at all times. Azure supports **two types of load balancers—internal and public**.

## Create an internal load balancer
An internal load balancer is assigned a private IP address (from the address range of subnets in the VNet) for a frontend IP address, and it targets the private IP addresses of our services (usually, an Azure VM) in the backend. An internal load balancer is **usually used by services that are not internet-facing and are accessed only from within our VNet**.

Traffic can come from other networks (other VNets or local networks) if there is some kind of VPN in place. **The traffic coming to the frontend of the internal load balancer will be distributed across the endpoints in the backend of the load balancer**. Internal load balancers are usually used for services that are not placed in a *DeMilitarized Zone* (DMZ) (and are therefore not accessible over the internet), but rather in middle- or back-tier services in a multitier application architecture.

We also need to keep in mind the differences between the Basic and Standard SKUs. The main difference is in *Performance* (this is better in the Standard SKU) and *SLA* (Standard has an SLA guaranteeing 99.99% availability, while Basic has no SLA). Also, note that **Standard SKU requires an NSG**. If an NSG is not present on the subnet or network interface, or NIC (of the VM in the backend), traffic will not be allowed to reach its target. For more information on load balancer SKUs, see <https://docs.microsoft.com/azure/load-balancer/skus>.
<!--more-->
## Create a public load balancer
The second type of load balancer in Azure is a public load balancer. The main difference is that **a public load balancer is assigned a public IP address in the frontend**, and all requests come over the internet. The requests are then distributed to the endpoints in the backend.

What's interesting is that the public load balancer does not target the public IP addresses in the backend, but private IP addresses instead. For example, let's say that we have one public load balancer with two Azure VMs in the backend. Traffic coming to the public IP address of the load balancer will then be distributed to VMs but will target the VMs' private IP addresses. Public load balancers are **used for public-facing services, most commonly for web servers**.

## Create a backend pool
After the load balancer is created, either internally or publicly, we need to configure it further in order to start using it. During the creation process, we define the frontend of the load balancer and know where traffic needs to go to reach the load balancer. But, **in order to define where that traffic needs to go after reaching the load balancer, we must first define a backend pool**.

The two main components of any load balancer are the frontend and the backend. The frontend defines the endpoint of the load balancer, and the backend defines where the traffic needs to go after reaching the load balancer. As the frontend information is created along with the load balancer, we must define the backend ourselves, after which the traffic will be evenly distributed across endpoints in the backend. The available **options for the backend pool are VMs and VM scale sets**.

## Create health probes
After the frontend and the backend of the load balancer are defined, traffic is evenly distributed among endpoints in the backend. But what if one of the endpoints is unavailable? In that case, some of the requests will fail until we detect the issue, or even fail indefinitely should the issue remain undetected. The load balancer would **send a request to all the defined endpoints in the backend pool and the request would fail when directed to an unavailable server**.

This is why we introduce the next two components in the load balancer—*Health Probes* and *Rules*. These components are used to detect issues and define what to do when issues are detected. Health probes constantly monitor all endpoints defined in the backend pool and detect if any of them become unavailable. They do this by sending a probe in the configured protocol and listening for a response. **If an HTTP probe is configured, an HTTP 200 OK response is required to be considered successful**.

After we define the health probe, it will be used to monitor the endpoints in the backend pool. We define the *Protocol* and the *Port* as useful information that will provide information regarding whether the service we are using is available or not. **Monitoring the state of the server would not be enough**, as it could be misleading.

For example, the server could be running and available, but the *Internet Information Services* (IIS) or SQL server that we use might be down. So, the protocol and the port will **detect changes in the service that we are interested in and not only whether the server is running**. The *Interval* defines how often a check is performed, and the *Unhealthy Threshold* defines after how many consecutive fails the endpoint is declared unavailable.

## Create load balancer rules
The last piece of the puzzle when speaking of Azure Load Balancers is the rule. Rules **finally tie all things together** and define which health probe (there can be more than one) will monitor which backend pool (more than one can be available). Furthermore, rules enable port mapping from the frontend of a load balancer to the backend pool, defining how ports relate and how incoming traffic is forwarded to the backend.

As its default distribution mode, Azure Load Balancer **uses a five-tuple hash (source IP, source port, destination IP, destination port, and protocol type)**. If we change the session persistence to client IP, the distribution will be two-tuple (requests from the same client IP address will be handled by the same VM). Changing session persistence to client IP and protocol will change the distribution to three-tuple (requests from the same client IP address and protocol combination will be handled by the same VM).

## Create inbound NAT rules
Inbound NAT rules are an optional setting in Azure Load Balancer. These rules essentially create another port mapping from the frontend to the backend, forwarding traffic from a specific port on the frontend to a specific port in the backend. The difference between inbound NAT rules and port mapping in load balancer rules is that **inbound NAT rules apply to direct forwarding to a VM, whereas load balancer rules forward traffic to a backend pool**.

A load balancer rule creates additional settings, such as the health probe or session persistence. Inbound NAT rules **exclude these settings and create unconditional mapping from the frontend to the backend**. With an inbound NAT rule, forwarded traffic will always reach the single server in the backend, whereas a load balancer will forward traffic to the backend pool and will use a *Pseudo-round-robin* algorithm to route traffic to any of the healthy servers in the backend pool.

## Create explicit outbound rules
When creating load balancing rules, we can create implicit outbound rules. This will enable *Source Network Address Translation* (SNAT) for VMs in the backend pool and allow them to access the internet over the load balancer's public IP address (specified in the rule). But in some scenarios, implicit rules are not enough and we need to create explicit outbound rules. Explicit outbound rules (and SNAT in general) are **available only for public load balancers with the Standard SKU**.

Outbound rules depend on **three things—frontend IP addresses, instances in the backend pool, and connections**. Each frontend IP address has a limited number of ports for connections. The more IP addresses are assigned to the frontend, the more connections are allowed. On the other hand, the number of connections allowed (per backend instance) decreases with the number of instances in the backend.

If we **set the default number of outbound ports, allocation is done automatically and without control**. If we have a VM scale set with the default number of instances, port allocation will be done automatically for each VM in the scale set. If the number of instances in a scale set increases, this means that the number of ports allocated to each VM will drop in turn.

To avoid this, we can set port allocation to manual and either limit the number of instances that are allowed or limit the number of ports per instance. This will **ensure that each VM has a certain number of ports dedicated and that connections will not be dropped**.
