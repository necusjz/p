---
title: Local and Virtual Network Gateways
abbrlink: 1042644649
date: 2022-04-21 23:37:08
tags: Azure
---
Local and virtual network gateways are *Virtual Private Network* (VPN) gateways that are used to **connect to on-premises networks and encrypt all traffic going between a VNet and a local network**. Each VNet can have only one virtual network gateway, but one virtual network gateway can be used to configure multiple VPN connections.

## Create a local network gateway
When a Site-to-Site connection is created, we have to **provide configuration for both sides of the connection**—that is, both Azure and on-premises. Although a *Local Network Gateway* is created in Azure, it represents your local (on-premises) network and holds configuration information on your local network settings. It's an essential component for creating the VPN connection that is needed to create a Site-to-Site connection between the VNet and the local network.

The local network gateway is used to connect a virtual network gateway to an on-premises network. The virtual network gateway is directly connected to the VNet and has all the relevant Azure VNet information needed to create a VPN connection. On the other hand, a local network gateway **holds all the local network information needed to create a VPN connection**.
<!--more-->
## Create a virtual network gateway
After a local network gateway is created, we need to create a *Virtual Network Gateway* in order to create a VPN connection between the local and Azure networks. As a local network gateway holds information on the local network, the virtual network gateway **holds information for the Azure VNet that we are trying to connect to**.

The virtual network gateway is the second part needed to establish the connection to the Azure VNet. It is directly connected to the VNet and is needed to create both Site-to-Site and Point-to-Site connections. We need to **set the VPN type, which needs to match the type of the local VPN device** when a Site-to-Site connection is created.

**Active-active mode provides high availability** by associating two IP addresses with separate gateway configurations to ensure uptime. The *Border Gateway Protocol* (BGP) is a standard protocol for the exchange of routing and reachability information between different *Autonomous System* (AS). Each system is assigned an *Autonomous Systems Number* (ASN).

## Modify the local network gateway settings
The local network gateway holds the local network information needed to create a Site-to-Site connection between the local and Azure networks. If this information changes, we can **edit it in the configuration settings**. The changes that can be made are the IP address (that is, the public IP address of the local firewall) and the address space we are connecting to. Additionally, we can add or remove address spaces if we want to add or remove subnets that are able to connect to Azure VNet. If the configuration in the local network gateway is no longer valid, we can still use it to create a completely new connection to a new local network if needed.
