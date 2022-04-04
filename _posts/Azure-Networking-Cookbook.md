---
title: Azure Networking Cookbook
abbrlink: 3451434521
date: 2022-04-03 14:11:18
tags: Azure
---
> Practical recipes for secure network infrastructure, global application delivery, and accessible connectivity in Azure.

## Azure Virtual Network
*Azure Virtual Network* represents your local network in the cloud. It enables other Azure resources to communicate over a secure private network **without exposing endpoints over the internet**.

### Create a virtual network
We deploy virtual networks to **Resource Group** under **Subscription** in the Azure datacenter that we choose. **Region** and **Subscription** are important parameters; **we will only be able to attach Azure resources to this virtual network if they are in the same subscription and region as the Azure datacenter**. The address space option defines the number of IP addresses that will be available for our network. It uses the **Classless Inter-Domain Routing** (CIDR) format and the largest range we can choose is /8. In the portal, we need to create an initial subnet and define the subnet address range. The smallest subnet allowed is /29 and the largest is /8 (however, this cannot be larger than the virtual network range). For reference, the range 10.0.0.0/8 (in CIDR format) will create an address range of 167772115 IP addresses (from 10.0.0.0 to 10.255.255.255) and 10.0.0.0/29 will create a range of 8 IP addresses (from 10.0.0.0 to 10.0.0.7).
<!--more-->
### Add a subnet
In addition to adding subnets while creating a virtual network, **we can add additional subnets to our network at any time**.

A single virtual network can have multiple subnets defined. Subnets cannot overlap and must be in the range of the virtual network address range. For each subnet, **four IP addresses are saved for Azure management and cannot be used**. Depending on the network settings, we can define the communication rules between subnets in the virtual network.

### Change the address space size
After the initial address space is defined during the creation of a virtual network, **we can still change the address space size as needed**. We can either increase or decrease the size of the address space or change the address space completely by using a new address range.

Although you can change the address space at any time, there are some rules that determine what you can and cannot do. **The address space cannot be decreased if you have subnets defined in the address space that would not be covered by the new address space**. For example, if the address space were in the range of 10.0.0.0/16, it would cover addresses from 10.0.0.1 to 10.0.255.254. If one of the subnets was defined as 10.0.255.0/24, we wouldn't be able to change the virtual network to 10.0.0.0/17, as this would leave the subnet outside the new space.

**The address space can't be changed to a new address space if you have subnets defined**. In order to completely change the address space, you need to remove all subnets first. For example, if we had the address space defined as 10.0.0.0/16, we would not be able to change it to 10.1.0.0/16, since having any subnets in the old space would leave them in an undefined address range.

### Change the subnet size
Similar to the virtual network address space, **we can change the size of a subnet at any time**.

When changing the subnet size, **there are some rules that must be followed**. We cannot change the address space if it is not within the virtual network address space range, and the subnet range cannot overlap with other subnets in a virtual network. If devices are assigned to this subnet, we cannot change the subnet to exclude the addresses that these devices are already assigned to.

## Virtual Machine Networking
*Azure VM* depends on virtual networking, and **during the creation process, we need to define the network settings**.

### Create VMs
When a VM is created, a *Network Interface Card* (NIC) is created in the process. **An NIC is used as a sort of interconnection between the VM and the virtual network**. A NIC is assigned a private IP address by the network. As an NIC is associated with both the VM and the virtual network, the IP address is used by the VM. Using this IP address, the VM can communicate over a private network with other VMs (or other Azure resources) on the same network. Additionally, NICs and VMs can be assigned public IP addresses as well. A public address can be used to communicate with the VM over the internet, either to access services or to manage the VM.

### View VM network settings
After an Azure VM is created, **we can review the network settings in the VM pane**.

Networking information is displayed in several places, including in the VM's network settings. Additionally, each Azure resource has a separate pane and exists as an individual resource, so we can view these settings in multiple places. However, **the most complete picture of VM network settings can be found in the VM pane and the NIC pane**.

### Create an NIC
A NIC is usually created during the VM creation process, but **each VM can have multiple NICs**. Based on this, we can create an NIC as an individual resource and attach it or detach it as needed.

**A NIC can't exist without a network association**, and this association must be assigned to a virtual network and subnet. This is defined during the creation process and cannot be changed later. On the other hand, association with a VM can be changed and the NIC can be attached or detached from a VM at any time.

### Attach an NIC to a VM
Each VM can have multiple NICs. Because of this, **we can add a new NIC at any time**.

Each VM can have multiple NICs. The number of NICs that can be associated with a VM depends on the type and size of the VM. To attach an NIC to a VM, the VM needs to be stopped (that is, deallocated); **you can't add an additional NIC to a running VM**.

### Detach an NIC from a VM
Just as with attaching an NIC, **we can detach an NIC at any time and attach it to another VM**.

To detach an NIC, the VM associated with the NIC must be stopped (that is, deallocated). At least one NIC must be associated with the VM-so **you can't remove the last NIC from a VM**. All network associations stay with the NIC—they are assigned to the NIC, not to the VM.

## Network Security Groups
*Network Security Groups* (NSGs) are built-in tools for network control that **allow us to control incoming and outgoing traffic on a network interface or at the subnet level**. They contain sets of rules that allow or deny specific traffic to specific resources or subnets in Azure. An NSG can be associated with either a subnet (by applying security rules to all resources associated with the subnet) or an NIC, which is done by applying security rules to the VM associated with the NIC.

### Create an NSG
As a first step to **more effectively control network traffic**, we are going to create a new NSG.

**The NSG deployment can be initiated during a VM deployment**. This will associate the NSG to the NIC associated with the deployed VM. In this case, the NSG is already associated with the resource, and rules defined in the NSG will apply only to the associated VM.

If the NSG is deployed separately, as seen in this recipe, it is not associated and **the rules that are created within it are not applied until an association has been created with the NIC or the subnet**. When it is associated with a subnet, the NSG rules will apply to all resources on the subnet.

### Create a allow rule in an NSG
When a new NSG is created, only the default rules are present, which **allow all outbound traffic and block all inbound traffic**. To change these, additional rules need to be created.

By default, all traffic coming from Azure Load Balancer or Azure Virtual Network is allowed. All traffic coming over the internet is denied. To change this, we need to create additional rules. **Make sure you set the right priority when creating rules**. Rules with the highest priority (that is, those with the lower number) are processed first, so if you have two rules, one of which is denying traffic and one of which is allowing it, the rule with higher priority will take precedence, while the one with lower priority will be ignored.

### Create a deny rule in an NSG
All outbound traffic is allowed by default, regardless of where it is going. If we want to **explicitly deny traffic on a specific port**, we need to create a rule to do so.

### Assign an NSG to a subnet
The NSG and its rules **must be assigned to a resource to have any impact**.

When an NSG is associated with a subnet, the rules in the NSG will apply to all of the resources in the subnet. Note that the subnet can be associated with more than one NSG, and the rules from all the NSGs will apply in that case. Priority is the most important factor when looking at a single NSG, but **when the rules from more NSGs are observed, the Deny rule will prevail**. So, if we have two NSGs on a subnet, one with Allow on port 443 and another one with the Deny rule on the same port, traffic on this port will be denied.

### Assign an NSG to an NIC
When an NSG is associated with an NIC, the NSG rules will apply only to a single NIC (or a VM associated with the NIC). The NIC can be associated with only one NSG directly, but **a subnet associated with an NIC can have an association with another NSG (or even multiple NSGs)**. This is similar to when we have multiple NSGs assigned to a single subnet, and the Deny rule will take higher priority. If one of the NSGs allows traffic on a port, but another NSG is blocking it, traffic will be denied.

### Create an ASG
*Application Security Groups* (ASGs) are an extension of NSGs, allowing us to create additional rules and take better control of traffic. Using only NSGs allows us to create rules that will allow or deny traffic only for a specific source, IP address, or subnet. **ASGs allow us to create better filtering and create additional checks on what traffic is allowed based on ASGs**. For example, with NSGs, we can create a rule that subnet A can communicate with subnet B. If we have the application structure for it and an associated ASG, we can add resources in application groups. By adding this element, we can create a rule that will allow communication between subnet A and subnet B, but only if the resources belong to the same application.

ASGs don't make much difference on their own and **must be combined with NSGs to create NSG rules** that will allow better control of traffic, applying additional checks before traffic flow is allowed.

### Associate an ASG with a VM
**After creating an ASG, we must associate it with a VM**. After this is done, we can create rules with the NSG and ASG for traffic control.

The VM must be associated with the ASG. **We can associate more than one VM with each ASG**. The ASG is then used in combination with the NSG to create new NSG rules.

### Create rules with an NSG and an ASG
As a final step, we can use NSGs and ASGs to create new rules with better control. This approach allows us to have better control of traffic, **limiting incoming traffic not only to a specific subnet but also only based on whether or not the resource is part of the ASG**.

Using only NSGs to create rules, we can allow or deny traffic only for a specific IP address or range. **With an ASG, we can widen or narrow this as needed**. For example, we can create a rule to allow VMs from a frontend subnet, but only if these VMs are in a specific ASG. Alternatively, we can allow access to a number of VMs from different virtual networks and subnets, but only if they belong to a specific ASG.

## Managing IP Address
In Azure, **we can have two types of IP addresses, private and public**. Public addresses can be accessed over the internet. Private addresses are from the Azure Virtual Network address space and are used for private communication on private networks. Addresses can be assigned to a resource or can exist as a separate resource.

### Create a public IP address
*Public IP Address* can be created as a separate resource or created during the creation of some other resources (a VM, for example). Therefore, **a public IP can exist as part of a resource or as a standalone resource**.

The **Stock Keeping Unit** (SKU) can be either Basic or Standard. The main differences are that **Standard is closed to inbound traffic by default** (inbound traffic must be whitelisted in NSGs) and that Standard is zone redundant. Another difference is that a Standard SKU public IP address has a static assignment, while a Basic SKU can be either static or dynamic.

You can choose either the IPv4 or IPv6 version for the IP address, or both, but **choosing IPv6 will limit you to a dynamic assignment for the Basic SKU** and static assignment for the Standard SKU.

The **DNS Name Label** is optional—it can be used to **resolve the endpoint if dynamic assignment is selected**. Otherwise, there is no point in creating a DNS label, as an IP address can always be used to resolve the endpoint if static assignment is selected.

### Asign a public IP address
A public IP address can be created as a separate resource or disassociated from another resource and exist on its own. Such an IP address can then be assigned to a new resource or another already-existing resource. If the resource is no longer in use or has been migrated, we can still use the same public IP address. In this case, the public endpoint that's used to access a service may stay unchanged. This can be useful when a publicly available application or service is migrated or upgraded, as **we can keep using the same endpoint and users don't need to be aware of any change**.

A public IP address exists as a separate resource and can be assigned to a resource at any time. When a public IP address is assigned, you can use this IP address to access services running on a resource that the IP address is assigned to (remember that an appropriate NSG must be applied). **We can also remove an IP address from a resource and assign it to a new resource**. For example, if we want to migrate services to a new VM, the IP address can be removed from the old VM and assigned to the new one. This way, service endpoints running on the VM will not change. This is especially useful when static IP addresses are used.

### Unassign a public IP address
A public IP address can be unassigned from a resource in order to be saved for later use or assigned to another resource. **When a resource is deleted or decommissioned, we can still put the public IP address to use and assign it to the next resource**.

A public IP address can be assigned or unassigned from a resource in order to save it for future use or to transfer it to a new resource. **To remove it, we simply disable the public IP address in the IP configuration under the NIC that the IP address is assigned to**. This will remove the association but keep the IP address as a separate resource.

### Create a reservation for a public IP address
**The default option for a public IP address is dynamic IP assignment**. This can be changed during the public IP address creation, or later. If this is changed from dynamic IP assignment, then the public IP address becomes reserved (or static).

A public IP address is set to dynamic by default. This means that an IP address might change in time. For example, if a VM that an IP address is assigned to is turned off or rebooted, there is a possibility that the IP address will change after the VM is up and running again. **This can cause issues if services that are running on the VM are accessed over the public IP address, or if there is a DNS record associated with the public IP address**.

We create an IP reservation and set the assignment to static to avoid such a scenario and **keep the IP address reserved for our services**.

### Remove a reservation for a public IP address
If the public IP address is set to static, we can remove a reservation and set the IP address assignment to dynamic. This isn't done often as there is usually a reason why the reservation is set in the first place. But as the reservation for the public IP address has an additional cost, **there is sometimes a need to remove the reservation if it is not necessary**.

To remove an IP reservation from a public IP address, the public IP address must not be associated with a resource. **We can remove the reservation by setting the IP address Assignment to Dynamic**.

The main reason for this is pricing. In Azure, **the first five public IP reservations are free**. After the initial five, each new reservation is billed. To avoid paying anything unnecessary, we can remove a reservation when it is not needed or when the public IP address is not being used.

### Create a reservation for a private IP address
Similar to public IP addresses, we can make a reservation for *Private IP Address*. This is usually done to **ensure communication between servers on the same virtual network** and to allow the usage of IP addresses in connection strings.

A reservation can be made for private IP addresses. The difference is that **a private IP address does not exist as a separate resource but is assigned to an NIC**.

Another difference is that **you can select a value for a private IP address**. A public IP address is assigned randomly and can be reserved, but you cannot choose which value this will be. For private IP addresses, you can select the value for the IP, but it must be an unused IP from the subnet associated with the NIC.

### Change a reservation for a private IP address
For private IP addresses, **you can change the IP address at any time to another value**. With public IP addresses, this isn't the case, as you get the IP address randomly from a pool and aren't able to change the value. With a private IP address, you can change the value to another IP address from the address space.

A reservation for a private IP address can be changed. Again, **the value must be an unused IP address from a subnet associated with the NIC**. If the VM associated with the NIC is turned off, the new IP address will be assigned upon its next startup. If the VM is running, it will be restarted to apply the new changes.

### Remove a reservation for a private IP address
Similar to public IP addresses, we can remove a reservation for a private IP address at any time. A private IP address is free, so additional costs aren't a factor in this case. But **there are scenarios where dynamic assignment is required, and we can set it at any time**.

**We can remove a private IP address reservation at any time by switching Assignment to Dynamic**. When this change is made, the VM associated with the NIC will be restarted to apply the new changes. After a change is made, a private IP address may change after the VM is restarted or turned off.

### Add multiple IP addresses to an NIC
In various situations, we may need to have multiple IP addresses associated with a single NIC. In Azure, **this is possible for both private and public IP addresses**.

Each NIC can have multiple IP configurations assigned. **Each IP configuration must have a private IP address and can have a public IP address**. So, it is possible to add a private IP address without a public IP address, but not the other way around. This provides us with different routing options and the ability to communicate with different applications and services over different IP addresses.

### Create a public IP prefix
Creating new resources is usually associated with creating new IP addresses. **There can be issues when public IP addresses need to be associated with firewall rules or app configurations**. To overcome this, we can create a public IP prefix and reserve a range of IP addresses that will be assigned to our resources.

When we create a public IP prefix, public IP address association is not done randomly but from a pool of addresses reserved for us. In many ways, this acts similarly to creating a virtual network and defining a private IP address space, only with public IP addresses. **This can be very useful when we need to know addresses in advance**. For example, let's say we need to create a firewall rule for each service we create. That would require us to wait for each service to be deployed and get a public IP address after it has been created. With a public IP prefix, IP addresses are known in advance and we can set a rule for a range of IP addresses, rather than doing it IP by IP.

## Local and Virtual Network Gateways
Local and virtual network gateways are **Virtual Private Network** (VPN) gateways that are used to **connect to on-premises networks and encrypt all traffic going between a VNet and a local network**. Each virtual network can have only one virtual network gateway, but one virtual network gateway can be used to configure multiple VPN connections.

### Create a local network gateway
When a Site-to-Site connection is created, we have to provide configuration for both sides of the connection—that is, both Azure and on-premises. Although a *Local Network Gateway* is created in Azure, it represents your local (on-premises) network and holds configuration information on your local network settings. **It's an essential component for creating the VPN connection that is needed to create a Site-to-Site connection between the virtual network and the local network**.

The local network gateway is used to connect a virtual network gateway to an on-premises network. The virtual network gateway is directly connected to the virtual network and has all the relevant Azure VNet information needed to create a VPN connection. On the other hand, **a local network gateway holds all the local network information needed to create a VPN connection**.

### Create a virtual network gateway
After a local network gateway is created, we need to create a *Virtual Network Gateway* in order to create a VPN connection between the local and Azure networks. As a local network gateway holds information on the local network, **the virtual network gateway holds information for the Azure VNet that we are trying to connect to**.

The virtual network gateway is the second part needed to establish the connection to the Azure VNet. It is directly connected to the virtual network and is needed to create both Site-to-Site and Point-to-Site connections. **We need to set the VPN type, which needs to match the type of the local VPN device when a Site-to-Site connection is created**.

Active-active mode provides high availability by associating two IP addresses with separate gateway configurations to ensure uptime.

The **Border Gateway Protocol** is a standard protocol for the exchange of routing and reachability information between different Autonomous Systems (ASes). Each system is assigned an Autonomous Systems Number (ASN).

### Modify local network gateway settings
**Network configurations may change over time, and we may need to address these changes in Azure as well**—for example, the public IP address of a local firewall may change, and we'd then need to reconfigure the local network gateway, or a local network might be reconfigured and the address space or subnet has changed, so we would need to reconfigure the local network gateway once again.

The local network gateway holds the local network information needed to create a Site-to-Site connection between the local and Azure networks. **If this information changes, we can edit it in the Configuration settings**. The changes that can be made are the IP address (that is, the public IP address of the local firewall) and the address space we are connecting to. Additionally, we can add or remove address spaces if we want to add or remove subnets that are able to connect to Azure VNet. If the configuration in the local network gateway is no longer valid, we can still use it to create a completely new connection to a new local network if needed.

## DNS and Routing
*Azure DNS* allows us to host **Domain Name System** (DNS) domains in Azure. When using Azure DNS, we use Microsoft infrastructure for the name resolution, which results in fast and reliable DNS queries. Azure DNS infrastructure uses a vast number of servers to provide great reliability and availability of service. **Using anycast networking, each DNS query is answered by the closest available DNS server to provide a quick reply**.

### Create a DNS zone
To start using Azure DNS, we must first create a DNS zone. A DNS zone holds a DNS record for a specific domain, and it can hold records for a single domain at a time. **A DNS zone will hold DNS records for this domain and possible subdomains**. DNS name servers are set up to reply to any query on a registered domain and point to a destination.

A DNS zone is required to start using Azure DNS. A new DNS zone is required for each domain we want to host with Azure DNS, as a single DNS zone can hold information for a single domain. After we create a DNS zone, **we can add records, record sets, and route tables to a domain hosted with Azure DNS**. Using these, we can route traffic and define destinations using an FQDN for Azure resources (and other resources as well).

### Create a private DNS zone
A private DNS zone operates very similarly to a DNS zone. However, instead of operating on public records, it operates inside a virtual network. It is used to **resolve custom names and domains inside your Azure VNet**.

When a virtual network is created, a default DNS zone is provided. The default DNS zone uses Azure-provided names, and **we must use a private DNS zone to use custom names**. A private DNS zone is also required for name resolution across virtual networks, as default DNS doesn't support such an option.

### Integrate a VNet with a private DNS zone
When a private DNS zone is created, it is a standalone service that doesn't do much on its own. **We must integrate it with a virtual network in order to start using it**. Once integrated, it will provide DNS inside the virtual network.

Once the virtual network is linked to the private DNS zone, the zone can be used for name resolution inside the connected virtual network. For name resolution across multiple connected virtual networks, we must use a private DNS zone, as default DNS doesn't support resolution across networks. **The same applies if the network is connected to an on-premises network**.

If we enable auto-registration under Configuration, newly created virtual machines will be automatically registered in the private DNS zone. Otherwise, we must add each new resource manually.

### Create a record set
When creating a DNS zone, we define what domain we're going to hold records for. **A DNS zone is created for a root domain defined with an FQDN**. We can add additional subdomains and add records to hold information on other resources on the same domain.

A DNS record set holds information on the subdomain in the domain hosted with the DNS zone. In this case, the domain would be toroman.cloud, and the subdomain would be test. This forms an FQDN, demo.toroman.cloud, and the record points this domain to the IP address we defined. **The record set can hold multiple records for a single subdomain, usually used for redundancy and availability**.

**Using CNAME and/or an alias can be done with Azure Traffic Manager**. In this way, custom domain names can be used for name resolution, instead of the default names provided by Azure.

### Create a route table
Azure routes network traffic in subnets by default. However, in some cases, **we want to use custom traffic routes to define where and how traffic flows**. In such cases, we use route tables. A route table defines the next hop for our traffic and determines where the network traffic needs to go.

Network routing in Azure VNet is done automatically, but we can use custom routing with route tables. Route tables use rules and subnet associations to define traffic flow in VNet. **When a new route table is created, no configuration is created**—only an empty resource. After the resource is created, we need to define rules and subnets in order to use a route table for the traffic flow.

### Change a route table
As mentioned in the previous recipe, creating a new route table will result in an empty resource. Once a resource is created, we can change the settings as needed. Before we configure the routes and subnets associated with the route table, **the only setting we can change is the Border Gateway Protocol (BGP) route propagation**. We may change other settings after creation as well.

Under the settings of the route table, **we can disable or enable gateway route propagation at any time**. This option, if disabled, prevents on-premises routes from being propagated via BGP to the network interfaces in a virtual network subnet. Under the settings, we can create, delete, or change routes and subnets.

### Associate a route table with a subnet
When a route table is created, it doesn't do anything until it's properly configured. There are two things we need to address: which resources are affected, and how. To define which resources are affected, **we must make an association between a subnet and a route table**.

The route table, to be effective, must have two parts defined: the what and the how. We define what will be affected by the route table with a subnet association. This is only one part of the configuration, as just associating a subnet to a route table will do nothing. **We must create rules that will apply to this association**.

### Dissociate a route table from a subnet
After we create an association and rules, those rules will apply to all resources on the associated subnet. **If we want rules to no longer apply to a specific subnet, we can remove the association**.

At some point, we may have created rules in a route table that apply to multiple subnets. If we no longer want to apply one or more rules to a specific subnet, we can remove the association. Once the association is removed, the rules will no longer apply to the subnet. **All rules will apply to all the associated subnets**. If we need to make a single rule no longer apply to a specific subnet, we must remove the association.

### Create a route
After we create a route table and the associated subnets, there is still a piece missing. We defined the route table that will be affected with subnet association, but we're missing the part that defines how it will be affected. **We define how associated subnets are affected using rules called routes**. Routes define traffic routes, stating where specific traffic needs to go. If the default route for specific traffic is the internet, we can change this and reroute the traffic to a specific IP or subnet.

The route defines the traffic flow. **All traffic from the associated subnet will follow the route defined by these rules**. If we define that traffic will go to the internet, all traffic will go outside the network to an IP address range defined with an IP address prefix. If we choose for traffic to go to a virtual network, it will go to a subnet defined by the IP address prefix. If that virtual network gateway is used, all traffic will go through the virtual network gateway and reach its connection on the other side—either another virtual network or our local network. The Virtual Appliance option will send all traffic to the virtual appliance, which then, with its own set of rules, defines where the traffic goes next.

### Change a route
Route requirements may change over time. In such cases, **we can either remove the route or edit it, depending on our needs**. If a route needs to be adjusted, we can select the option to change the route and apply the new traffic flow at any time.

The requirements for a route may change over time. We can change a route and adjust it to suit new requirements as needed. The most common scenarios are that **the traffic needs to reach a specific service when the service IP changes over time**. For example, we may need to route all traffic through a virtual appliance, but the IP address of the virtual appliance changes over time. We may change the route in the route table to reflect this change and force the traffic flow through the virtual appliance. Another example is when traffic needs to reach our local network through a virtual network gateway—the destination IP address range may change over time, and we need to reflect these changes in the route once again.

### Delete a route
As we have already mentioned, route requirements may change over time. In some cases, **rules are no longer applicable and we must remove them**. In such cases, changing the route will not complete the task and we will need to remove the route completely. This task may be completed by deleting the route.

As our requirements change, we need to address the new requirements in our route tables. We can either edit routes or remove them to meet these new requirements. **When multiple routes are used in a single route table, one of the routes may become obsolete, or even block new requirements**. In such cases, we may want to delete a route to resolve any issues.

## Azure Firewall
Most Azure networking components used for security are there to stop unwanted incoming traffic. Whether we use NSGs, ASGs, or a WAF, they all have one single purpose—to stop unwanted traffic from reaching our services. *Azure Firewall* has similar functionality, including one extension that **we can use to stop outbound traffic from leaving the virtual network**.

### Create a firewall

### Configure a allow rule

### Configure a deny rule

### Configure a route table

### Enable diagnotic logs

### Configure in forced tunneling mode

### Create an IP group

### Configure DNS settings

## Create Hybrid Connections

## Connect to Resources Securely

## Load Balancers

## Traffic Manager

## Azure Application Gateway and Azure Web Application Firewall

## Azure Front Door and Azure CDN
