---
title: Manage IP Addresses
abbrlink: 4269680769
date: 2022-04-21 22:45:13
tags: Azure
---
In Azure, we can have **two types of IP addresses, private and public**. Public addresses can be accessed over the internet. Private addresses are from the VNet address space and are used for private communication on private networks. Addresses can be assigned to a resource or can exist as a separate resource.

## Create a public IP address
*Public IP Address* can be created as a separate resource or created during the creation of some other resources (a VM, for example). Therefore, **a public IP can exist as part of a resource or as a standalone resource**.

The *Stock Keeping Unit* (SKU) can be either *Basic* or *Standard*. The main differences are that Standard is closed to inbound traffic by default (inbound traffic must be whitelisted in NSGs) and that Standard is zone redundant. Another difference is that **a Standard SKU public IP address has a static assignment, while a Basic SKU can be either static or dynamic**. You can choose either the *IPv4* or *IPv6* version for the IP address, or both, but choosing IPv6 will limit you to a dynamic assignment for the Basic SKU and static assignment for the Standard SKU.

The *DNS Name Label* is optional—it can be used to **resolve the endpoint if dynamic assignment is selected**. Otherwise, there is no point in creating a DNS label, as an IP address can always be used to resolve the endpoint if static assignment is selected.
<!--more-->
## Assign a public IP address
A public IP address can be created as a separate resource or disassociated from another resource and exist on its own. Such an IP address can then be assigned to a new resource or another already-existing resource. If the resource is no longer in use or has been migrated, we can still use the same public IP address. In this case, the public endpoint that's used to access a service may stay unchanged. This can be useful when a publicly available application or service is migrated or upgraded, as we can **keep using the same endpoint and users don't need to be aware of any change**.

A public IP address exists as a separate resource and can be assigned to a resource at any time. When a public IP address is assigned, you can use this IP address to access services running on a resource that the IP address is assigned to (remember that an appropriate NSG must be applied). We can also **remove an IP address from a resource and assign it to a new resource**. For example, if we want to migrate services to a new VM, the IP address can be removed from the old VM and assigned to the new one. This way, service endpoints running on the VM will not change. This is especially useful when static IP addresses are used.

## Unassign a public IP address
A public IP address can be unassigned from a resource in order to be saved for later use or assigned to another resource. When a resource is deleted or decommissioned, we can still put the public IP address to use and assign it to the next resource. To remove it, we simply **disable the public IP address in the IP configuration under the NIC that the IP address is assigned to**. This will remove the association but keep the IP address as a separate resource.

## Create a reservation for a public IP address
**The default option for a public IP address is dynamic IP assignment**. This can be changed during the public IP address creation, or later. If this is changed from dynamic IP assignment, then the public IP address becomes reserved (or static). For example, if a VM that an IP address is assigned to is turned off or rebooted, there is a possibility that the IP address will change after the VM is up and running again.

This can cause issues if services that are running on the VM are accessed over the public IP address, or if there is a DNS record associated with the public IP address. We create an IP reservation and set the assignment to static to avoid such a scenario and **keep the IP address reserved for our services**.

## Remove a reservation for a public IP address
If the public IP address is set to static, we can remove a reservation and set the IP address assignment to dynamic. This isn't done often as there is usually a reason why the reservation is set in the first place. But as the reservation for the public IP address has an additional cost, there is sometimes a need to **remove the reservation if it is not necessary**.

To remove an IP reservation from a public IP address, the public IP address must not be associated with a resource. We can **remove the reservation by setting the IP address assignment to dynamic**. The main reason for this is pricing. In Azure, the first five public IP reservations are free. After the initial five, each new reservation is billed. To avoid paying anything unnecessary, we can remove a reservation when it is not needed or when the public IP address is not being used.

## Create a reservation for a private IP address
Similar to public IP addresses, we can make a reservation for *Private IP Address*. This is usually done to ensure communication between servers on the same VNet and to allow the usage of IP addresses in connection strings. The difference is that **a private IP address does not exist as a separate resource** but is assigned to an NIC.

Another difference is that you can **select a value for a private IP address**. A public IP address is assigned randomly and can be reserved, but you cannot choose which value this will be. For private IP addresses, you can select the value for the IP, but it must be an unused IP from the subnet associated with the NIC.

## Change a reservation for a private IP address
For private IP addresses, you can **change the IP address at any time to another value**. With public IP addresses, this isn't the case, as you get the IP address randomly from a pool and aren't able to change the value. With a private IP address, you can change the value to another IP address from the address space.

Again, the value must be **an unused IP address from a subnet associated with the NIC**. If the VM associated with the NIC is turned off, the new IP address will be assigned upon its next startup. If the VM is running, it will be restarted to apply the new changes.

## Remove a reservation for a private IP address
Similar to public IP addresses, we can remove a reservation for a private IP address at any time. A private IP address is free, so additional costs aren't a factor in this case. But there are scenarios where **dynamic assignment is required, and we can set it at any time**.

We can **remove a private IP address reservation at any time by switching asignment to dynamic**. When this change is made, the VM associated with the NIC will be restarted to apply the new changes. After a change is made, a private IP address may change after the VM is restarted or turned off.

## Add multiple IP addresses to an NIC
In various situations, we may need to have multiple IP addresses associated with a single NIC. In Azure, this is possible for both private and public IP addresses. Each IP configuration **must have a private IP address and can have a public IP address**. So, it is possible to add a private IP address without a public IP address, but not the other way around. This provides us with different routing options and the ability to communicate with different applications and services over different IP addresses.

## Create a public IP prefix
Creating new resources is usually associated with creating new IP addresses. There can be issues when public IP addresses need to be associated with firewall rules or app configurations. To overcome this, we can create a public IP prefix and **reserve a range of IP addresses that will be assigned to our resources**.

When we create a public IP prefix, public IP address association is not done randomly but from a pool of addresses reserved for us. In many ways, this acts similarly to creating a VNet and defining a private IP address space, only with public IP addresses. This can be **very useful when we need to know addresses in advance**. For example, let's say we need to create a firewall rule for each service we create. That would require us to wait for each service to be deployed and get a public IP address after it has been created. With a public IP prefix, IP addresses are known in advance and we can set a rule for a range of IP addresses, rather than doing it IP by IP.
