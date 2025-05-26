---
title: Azure Firewall
abbrlink: 4134241250
date: 2022-04-22 15:56:47
tags: Azure
---
**Most Azure networking components used for security are there to stop unwanted incoming traffic**. Whether we use NSGs, ASGs, or a WAF, they all have one single purpose—to stop unwanted traffic from reaching our services. *Azure Firewall* has similar functionality, including one extension that we can use to stop outbound traffic from leaving the VNet.

## Create a firewall
Azure Firewall gives us total control over our traffic. Besides controlling inbound traffic, with Azure Firewall, we can control outbound traffic as well. Azure Firewall uses a set of rules to control outbound traffic. We can **either block everything by default and allow only whitelisted traffic, or we can allow everything and block only blacklisted traffic**. It's essentially the central point where we can set network policies, enforce these policies, and monitor network traffic across VNets or even subscriptions. As a firewall as a service, Azure Firewall is a managed service with built-in high availability and scalability.

## Configure rules
If we want to allow specific traffic, we must create an allow rule. Rules are applied based on priority level, so a rule will be applied only when there is no other rule with higher priority. **An allow rule in Azure Firewall will whitelist specific traffic**. If there is a rule that would also block this traffic, the higher-priority rule will be applied.

The deny rule is the most commonly used option with Azure Firewall. An approach where you block everything and allow only whitelisted traffic isn't very practical, as we may end up adding a great many allow rules. Therefore, the most common approach is to **use deny rules to block certain traffic that we want to prevent**.
<!--more-->
## Configure a route table
Route tables are commonly used with Azure Firewall when there is cross-connectivity. Cross-connectivity can **either be with other Azure VNets or with on-premises networks**. In such cases, Azure Firewall uses route tables to forward traffic based on the rules specified in the route tables.

Using route tables associated with Azure Firewall, we can **define how traffic between networks is handled and how we route traffic from one network to another**. In a multinetwork environment, especially in a hybrid network where we connect an Azure VNet with a local on-premises network, this option is very important. This allows us to determine what kind of traffic can flow where and how.

## Enable diagnostic logs
Diagnostics are a very important part of any IT system, and networking is no exception. Diagnostics has **two purposes—auditing and troubleshooting**. Based on traffic and settings, these logs can grow over time, so it's important to consider the main purpose of enabling diagnostics in the first place. 

If diagnostics are enabled for auditing, you will probably want to choose a maximum of 365 days of retention. If the main purpose is troubleshooting, the retention period can be kept at 7 days or an even shorter period of time. Setting the retention policy to 0 will store logs without removing them after a period of time. This can generate additional costs and you may need to set up a different procedure for removing logs. If we **don't want to store diagnostic logs in a storage account**, we can choose *Log Analytics* or *Event Hubs*. The process, in this case, does not include setting retention periods as these settings are kept on the destination side.

## Configure in forced tunneling mode
Forced tunneling allows us to force all internet-bound traffic to an on-premises firewall for inspection or audit. Because of different Azure dependencies, this is not enabled by default and requires *User Defined Route* (USR) to allow forced tunneling. Note that this needs to be **done prior to Azure Firewall deployment and will not work if the subnet is added afterward**.

In order to support forced tunneling, **traffic associated with service management is separated from the rest of the traffic**. An additional subnet is required with a minimum size of /26, along with an associated public IP address. A route table is required with a single route defining the route to the internet, and BGP route propagation (propagate gateway routes) must be disabled. We can now include routes and define where exactly traffic needs to go (a VNet appliance or on-premises firewall) in order to be inspected or audited before reaching the internet.

## Create an IP group
IP groups are Azure resources that **help to group IP addresses for easier management**. This way, we can apply Azure Firewall rules easier and with better visibility. We can associate any number of individual IP addresses (in 10.10.10.10 format), IP ranges (in 10.10.10.10-10.10.10.20 format), or subnets (in 10.10.10.0/24 format). Then, firewall rules can be associated with IP groups and all IP addresses under a defined IP group. Instead of creating a separate rule for each IP address, range, or subnet, we can now have a single rule for a single IP range. This means easier management and maintenance of Azure Firewall, along with better visibility of effective rules.

## Configure DNS settings
We can use a custom DNS server with our Azure Firewall instance. This allows us to **resolve custom names and apply filtering based on FQDN**. In order to use FQDN filtering, Azure Firewall needs to be able to resolve the FQDN in question. This can be achieved by enabling DNS settings on Azure Firewall. When enabled, we can choose between Azure-provided DNS or custom DNS. Custom DNS can be either an Azure DNS zone or a DNS server running on a VNet.
