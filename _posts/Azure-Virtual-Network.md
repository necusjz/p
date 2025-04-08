---
title: Azure Virtual Network
abbrlink: 457978096
date: 2022-04-20 23:18:23
tags: Azure
---
*Azure Virtual Network* represents your local network in the cloud. It enables other Azure resources to communicate over a secure private network **without exposing endpoints over the internet**.

## Create a VNet
We deploy VNets to resource group under subscription in the Azure data center that we choose. *Region* and *Subscription* are important parameters; we will **only be able to attach Azure resources to this VNet if they are in the same subscription and region as the Azure data center**.

The address space option defines the number of IP addresses that will be available for our network. It uses the *Classless Inter-Domain Routing* (CIDR) format and the largest range we can choose is /8. In the portal, we need to create an initial subnet and define the subnet address range. **The smallest subnet allowed is /29 and the largest is /8** (however, this cannot be larger than the VNet range). For reference, the range 10.0.0.0/8 will create an address range of 167772115 IP addresses (from 10.0.0.0 to 10.255.255.255) and 10.0.0.0/29 will create a range of 8 IP addresses (from 10.0.0.0 to 10.0.0.7).

## Add a subnet
In addition to adding subnets while creating a VNet, we can **add additional subnets to our network at any time**. A single VNet can have multiple subnets defined. Subnets cannot overlap and must be in the range of the VNet address range. For each subnet, four IP addresses are saved for Azure management and cannot be used. Depending on the network settings, we can define the communication rules between subnets in the VNet.
<!--more-->
## Change the address space size
After the initial address space is defined during the creation of a VNet, we can still **change the address space size as needed**. We can either increase or decrease the size of the address space or change the address space completely by using a new address range.

Although you can change the address space at any time, there are some rules that determine what you can and cannot do. **The address space cannot be decreased if you have subnets defined in the address space that would not be covered by the new address space**. For example, if the address space were in the range of 10.0.0.0/16, it would cover addresses from 10.0.0.1 to 10.0.255.254. If one of the subnets was defined as 10.0.255.0/24, we wouldn't be able to change the VNet to 10.0.0.0/17, as this would leave the subnet outside the new space.

**The address space can't be changed to a new address space if you have subnets defined**. In order to completely change the address space, you need to remove all subnets first. For example, if we had the address space defined as 10.0.0.0/16, we would not be able to change it to 10.1.0.0/16, since having any subnets in the old space would leave them in an undefined address range.

## Change the subnet size
Similar to the VNet address space, we can change the size of a subnet at any time. When changing the subnet size, **there are some rules that must be followed**. We cannot change the address space if it is not within the VNet address space range, and the subnet range cannot overlap with other subnets in a VNet. If devices are assigned to this subnet, we cannot change the subnet to exclude the addresses that these devices are already assigned to.
