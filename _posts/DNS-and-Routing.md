---
title: DNS and Routing
abbrlink: 3768823570
date: 2022-04-22 09:55:28
tags: Azure
---
*Azure DNS* allows us to host *Domain Name System* (DNS) domains in Azure. When using Azure DNS, we use Microsoft infrastructure for the name resolution, which results in fast and reliable DNS queries. Azure DNS infrastructure uses a vast number of servers to provide great reliability and availability of service. **Using anycast networking, each DNS query is answered by the closest available DNS server** to provide a quick reply.

## Create a DNS zone
To start using Azure DNS, we must first create a DNS zone. A DNS zone holds a DNS record for a specific domain, and it can hold records for a single domain at a time. A DNS zone will **hold DNS records for this domain and possible subdomains**. DNS name servers are set up to reply to any query on a registered domain and point to a destination.

A DNS zone is required to start using Azure DNS. A new DNS zone is required for each domain we want to host with Azure DNS, as a single DNS zone can hold information for a single domain. After we create a DNS zone, we can **add records, record sets, and route tables to a domain hosted with Azure DNS**. Using these, we can route traffic and define destinations using a *Fully Qualified Domain Name* (FQDN) for Azure resources (and other resources as well).

## Create a private DNS zone
A private DNS zone operates very similarly to a DNS zone. However, instead of operating on public records, it operates inside a VNet. It is used to **resolve custom names and domains inside your Azure VNet**. When a VNet is created, a default DNS zone is provided. The default DNS zone uses Azure-provided names, and we must use a private DNS zone to use custom names. A private DNS zone is also required for name resolution across VNets, as default DNS doesn't support such an option.
<!--more-->
## Integrate a VNet with a private DNS zone
When a private DNS zone is created, it is a standalone service that doesn't do much on its own. We must **integrate it with a VNet in order to start using it**. Once integrated, it will provide DNS inside the VNet. Once the VNet is linked to the private DNS zone, the zone can be used for name resolution inside the connected VNet.

For name resolution across multiple connected VNets, we must use a private DNS zone, as default DNS doesn't support resolution across networks. **The same applies if the network is connected to an on-premises network**. If we enable auto-registration under configuration, newly created VMs will be automatically registered in the private DNS zone. Otherwise, we must add each new resource manually.

## Create a record set
When creating a DNS zone, we define what domain we're going to hold records for. **A DNS zone is created for a root domain defined with an FQDN**. We can add additional subdomains and add records to hold information on other resources on the same domain. In this case, the domain would be *toroman.cloud*, and the subdomain would be *demo*. This forms an FQDN, *demo.toroman.cloud.*, and the record points this domain to the IP address we defined.

The record set can **hold multiple records for a single subdomain, usually used for redundancy and availability**. Using CNAME and/or an alias can be done with *Azure Traffic Manager*. In this way, custom domain names can be used for name resolution, instead of the default names provided by Azure.

## Create a route table
Azure routes network traffic in subnets by default. However, in some cases, we want to **use custom traffic routes to define where and how traffic flows**. In such cases, we use route tables. A route table defines the next hop for our traffic and determines where the network traffic needs to go.

Route tables use rules and subnet associations to define traffic flow in VNet. When a new route table is created, no configuration is created—only an empty resource. After the resource is created, we need to **define rules and subnets in order to use a route table for the traffic flow**.

## Change a route table
As mentioned in the previous recipe, creating a new route table will result in an empty resource. Once a resource is created, we can change the settings as needed. Before we configure the routes and subnets associated with the route table, **the only setting we can change is the BGP route propagation**. We may change other settings after creation as well.

Under the settings of the route table, we can **disable or enable gateway route propagation at any time**. This option, if disabled, prevents on-premises routes from being propagated via BGP to the network interfaces in a VNet subnet. Under the settings, we can create, delete, or change routes and subnets.

## Associate a route table with a subnet
When a route table is created, it doesn't do anything until it's properly configured. There are two things we need to address: which resources are affected, and how. To define which resources are affected, we must **make an association between a subnet and a route table**. This is only one part of the configuration, as just associating a subnet to a route table will do nothing. We must create rules that will apply to this association.

## Dissociate a route table from a subnet
After we create an association and rules, those rules will apply to all resources on the associated subnet. At some point, we may have created rules in a route table that apply to multiple subnets. If we **no longer want to apply one or more rules to a specific subnet, we can remove the association**. Once the association is removed, the rules will no longer apply to the subnet. If we need to make a single rule no longer apply to a specific subnet, we must remove the association.

## Create a route
After we create a route table and the associated subnets, there is still a piece missing. We defined the route table that will be affected with subnet association, but we're missing the part that defines how it will be affected. We **define how associated subnets are affected using rules called routes**. Routes define traffic routes, stating where specific traffic needs to go. If the default route for specific traffic is the internet, we can change this and reroute the traffic to a specific IP or subnet.

The route defines the traffic flow. **All traffic from the associated subnet will follow the route defined by these rules**. If we define that traffic will go to the internet, all traffic will go outside the network to an IP address range defined with an IP address prefix. If we choose for traffic to go to a VNet, it will go to a subnet defined by the IP address prefix. If that virtual network gateway is used, all traffic will go through the virtual network gateway and reach its connection on the other side—either another VNet or our local network. The *Virtual Appliance* option will send all traffic to the virtual appliance, which then, with its own set of rules, defines where the traffic goes next.

## Change a route
Route requirements may change over time. In such cases, we can **either remove the route or edit it, depending on our needs**. If a route needs to be adjusted, we can select the option to change the route and apply the new traffic flow at any time.

The most common scenarios are that **the traffic needs to reach a specific service when the service IP changes over time**. For example, we may need to route all traffic through a virtual appliance, but the IP address of the virtual appliance changes over time. We may change the route in the route table to reflect this change and force the traffic flow through the virtual appliance. Another example is when traffic needs to reach our local network through a virtual network gateway—the destination IP address range may change over time, and we need to reflect these changes in the route once again.

## Delete a route
As we have already mentioned, route requirements may change over time. In some cases, **rules are no longer applicable and we must remove them**. In such cases, changing the route will not complete the task and we will need to remove the route completely. This task may be completed by deleting the route. We can either edit routes or remove them to meet these new requirements. When multiple routes are used in a single route table, one of the routes may become obsolete, or even block new requirements. In such cases, we may want to delete a route to resolve any issues.
