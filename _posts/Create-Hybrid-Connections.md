---
title: Create Hybrid Connections
abbrlink: 3597318647
date: 2022-04-22 18:24:27
tags: Azure
---
*Hybrid Connection* allows us to create secure connections with VNets. These connections can either be from on-premises or from other VNets. Establishing connections to VNets enables the exchange of secure network traffic with other services that are located in different VNets, different subscriptions, or outside Azure (in different clouds or on-premises). Using secure connections **removes the need for publicly exposed endpoints that present a potential security risk**. This is especially important when we consider management, where opening public endpoints creates a security risk and presents a major issue.

For example, if we consider managing VMs, it's a common practice to use either *Remote Desktop Protocol* (RDP) or PowerShell for management. Exposing these ports to public access presents a great risk. A best practice is to **disable any kind of public access to such ports and use only access from an internal network for management**. In this case, we use either a Site-to-Site or a Point-to-Site connection to enable secure management.

In another scenario, we might need the ability to **access a service or a database on another network, either on-premises or via another VNet**. Again, exposing these services might present a risk, and we use either Site-to-Site, VNet-to-VNet, or VNet peering to enable such a connection in a secure way.
<!--more-->
## Create a Site-to-Site connection
A Site-to-Site connection is used to create a secure connection between an on-premises network and an Azure VNet. This connection is used to perform a number of different tasks, such as enabling hybrid connections or secure management. In a hybrid connection, we **allow a service in one environment to connect to a service in another environment**. For example, we could have an application in Azure that uses a database located in an on-premises environment. Secure management lets us limit management operations to being allowed only when coming from a secure and controlled environment, such as our local network.

Using the virtual network gateway, we set up the Azure side of the *Internet Protocol Security* (IPSec) tunnel. The local network gateway provides information on the local network, defining the local side of the tunnel with the public IP address and local subnet information. This way, **Azure's side of the tunnel has all the relevant information** that's needed to form a successful connection with an on-premises network.

However, this completes only half of the work, as **the opposite side of the connection must be configured as well**. This part of the work really depends on the VPN device that's used locally, and each device has unique configuration steps. After both sides of the tunnel are configured, the result is a secure and encrypted VPN connection between networks.

## Download the VPN device configuration
After creating the Azure side of the Site-to-Site connection, we still need to configure the local VPN device. The configuration **depends upon the vendor and the device type**. You can see all the supported devices at <https://docs.microsoft.com/azure/vpn-gateway/vpn-gateway-about-vpn-devices>. In some cases, there is an option to download configuration for a VPN device directly from the Azure Portal. After the VPN device has been configured, everything is set up, and we can use the tunnel for secure communication between the local network and the VNet.

## Create a Point-to-Site connection
Accessing resources in a secure way is important, and this must be performed securely. It's not always possible to perform this using a Site-to-Site connection, especially when we have to perform something out of work hours. In this case, we can **use Point-to-Site to create a secure connection that can be established from anywhere**.

Certificate-based authentication is used, which uses the same certificate on both the server (Azure) and the client (the VPN client) to verify the connection and permit access. This allows us to access Azure VNets from anywhere and at any time. This type of connection is usually **used for management and maintenance tasks, as it's an on-demand connection**. If a constant connection is needed, you need to consider a Site-to-Site connection.

## Create a VNet-to-VNet connection
Similar to the need to connect VNets to resources on a local network, we may have the need to connect to resources in another VNet. In such cases, we can create a VNet-to-VNet connection that will **allow us to use services and endpoints in another VNet**. This process is very similar to creating a Site-to-Site connection; the difference is that we don't require a local network gateway.

Instead, we **use two virtual network gateways, one for each VNet**. Each virtual network gateway provides network information for the VNet that it's associated with. This results in secure, encrypted VPN connections between two VNets that can be used to establish connections between Azure resources on both VNets.

## Connect VNets using network peering
Another way to connect two VNets is to use network peering. This approach doesn't require the use of a virtual network gateway, so it's **more economical to use it if the only requirement is to establish a connection between VNets**. Network peering uses the Microsoft backbone infrastructure to establish a connection between two VNets, and traffic is routed through private IP addresses only. However, this traffic is not encrypted; it's private traffic that stays on the Microsoft network, similar to what happens to traffic on the same VNet.

The downside of this approach is that **the same VNet can't use peering and a virtual network gateway at the same time**. If there is a need to connect VNet to both the local network and another VNet, we must take a different approach and use a virtual network gateway, which will allow us to create a Site-to-Site connection with a local network and a VNet-to-VNet connection with another VNet.

When it comes to network access settings, we **have multiple options to control network traffic flow**. For example, we can say that traffic is allowed from VNet A to VNet B, but denied from VNet B to VNet A. Of course, we can set it the other way around or make it bidirectional; We can also control transit traffic when an additional network is in the mix. If VNet A is connected to VNet B, and additionally VNet A is connected to VNet C, we can control whether traffic is allowed between VNet B and VNet C as transit traffic through VNet A.

However, this only works if transit is not made via peering. If all networks are Azure VNets, and VNet A connected to VNet B via peering, and VNet B connected to VNet C via peering, the connection between VNet A and VNet C would not be possible via transit between VNets. This is because **peering is a non-transitive relationship between two VNets**. If VNet B is connected to VNet C via VNet-to-VNet (or to an on-premises network via Site-to-Site), transit would be possible between VNet A and VNet C over VNet B.
