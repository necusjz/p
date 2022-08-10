---
title: Connect to Resources Securely
abbrlink: 2931158028
date: 2022-04-22 23:40:35
tags: Azure
---
**Exposing management endpoints (RDP, SSH, HTTP, and others) over a public IP address is not a good idea**. Any kind of management access should be controlled and allowed only over a secure connection. Usually, this is done by connecting to a private network (via S2S or P2S) and accessing resources over private IP addresses. In some situations, this is not easy to achieve. The cause of this can be insufficient local infrastructure, or in some cases, the scenario may be too complex. Fortunately, there are other ways to achieve the same goal. We can safely connect to our resources using *Azure Bastion*, *Azure Virtual WAN*, and *Azure Private Link*.

## Create a bastion instance
*Azure Bastion* allows us to connect securely to our Azure resources without additional infrastructure. All we need is a browser. It is essentially **a PaaS service provisioned in our VNet that provides a secure RDP/SSH connection to Azure VMs**. The connection is made directly from the Azure Portal over *Transport Layer Security* (TLS). Using TLS, it provides a secure RDP and SSH connection to all resources on that network. The connection is made through a browser session, and no public IP address is required. This means that we don't need to expose any of the management ports over a public IP address.

## Connect to a VM with bastion
With Azure Bastion, we can connect to a VM through the browser without a public IP address and without exposing it publicly. Azure Bastion **uses a subnet in the VNet to connect to VMs in that specific network**. It provides a safe connection over TLS and allows a connection to a VM without exposing it over a public IP address.
<!--more-->
## Create a virtual WAN
In many situations, the network topology can get very complex. It can be difficult to keep track of all network connections, gateways, and peering processes. *Azure Virtual WAN* **provides a single interface to manage all these points**. From here, we can configure, control, and monitor connections such as Site-to-Site, Point-to-Site, ExpressRoute, or a connection between VNets. When we have multiple Site-to-Site connections or multiple VNets connected with peering, it can be hard to keep track of all these resources. Azure Virtual WAN allows us to do that with a single service.

## Create a hub in virtual WAN
Hubs are used as regional connection points. They contain multiple service endpoints that enable connectivity between different networks and services. They're **the core of networking for each region**. Virtual hubs represent control points inside a region. From there, we can define all connections to VNets inside the region.

This applies to Site-to-Site, Point-to-Site, and ExpressRoute. Each section is optional, and we can **create a hub without any configurations for connection types**. If we choose to create them at this point, we need to provide an SKU for each type. A Point-to-Site connection also requires the user's VPN configuration to be provided. Each connection type can be added at a later time as well.

## Add a Site-to-Site connection in a virtual hub
After a virtual hub is created and the Site-to-Site SKU is defined inside the hub, we can proceed to create a Site-to-Site connection. For this, we need to **apply the appropriate connection settings and provide configuration details**. Adding a Site-to-Site connection to our virtual hub allows us to connect to a virtual hub in a specific region from our on-premises network (or other networks using virtual appliance). To do so, we must provide information about the VPN connection in the virtual hub and configure the VPN device that will be used to connect. However, this allows us only to connect to the hub. We need to connect VNets in order to access Azure resources.

## Add a VNet connection in a virtual hub
A virtual hub represents a central point in an Azure region. But **to actually use this point, we need to connect VNets to a virtual hub**. Then, we can use the virtual hub as intended. A connection can be made over a Site-to-Site connection, a Point-to-Site connection, or from another VNet (connected to the same hub). When creating a connection, we need to provide routing and propagation rules in order to define the network flow. We can also define a static route. A static route will force all traffic to go through a single IP address, usually through a firewall or network virtual appliance.

## Create a private link endpoint
*Azure Private Link* allows us to connect to PaaS services over a secure network. As these services are usually exposed over the internet, this gives us a more secure method of access. There are **two components available to make a secure connection**—a *Private Link Endpoint* and a *Private Link Service*. Let's start by creating a Private Link Endpoint first.

The Private Link Endpoint associates the selected PaaS resource with the subnet on the VNet. By doing so, we have the option to access the PaaS resource over a secure connection. Optionally, we can integrate a private DNS zone and use DNS resolution instead of IP addresses. A Private Link Endpoint **allows us to link services directly but only individual services and only directly**. If we need to add load balancers in place, we can use a Private Link Service.

## Create a private link service
A Private Link Service allows us to set up a secure connection to resources associated with Standard load balancer. For that, we need to prepare infrastructure prior to deploying the Private Link Service. A Private Link Service and a Private Link Endpoint work in a similar way, allowing us to connect to services (that are by default publicly accessible) over a private network. The main difference is that with a Private Link Endpoint, we link PaaS services, and **with a Private Link Service, we create a custom service behind Standard load balancer**.
