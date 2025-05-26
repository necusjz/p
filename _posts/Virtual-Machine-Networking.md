---
title: Virtual Machine Networking
abbrlink: 743133161
date: 2022-04-20 23:39:24
tags: Azure
---
*Azure Virtual Machine* depends on virtual networking, and **during the creation process, we need to define the network settings**.

## Create VMs
When a VM is created, a *Network Interface Card* (NIC) is created in the process. **An NIC is used as a sort of interconnection between the VM and the VNet**. A NIC is assigned a private IP address by the network. As an NIC is associated with both the VM and the VNet, the IP address is used by the VM. Using this IP address, the VM can communicate over a private network with other VMs (or other Azure resources) on the same network.

Additionally, **NICs and VMs can be assigned public IP addresses as well**. A public address can be used to communicate with the VM over the internet, either to access services or to manage the VM.

## View VM network settings
After an Azure VM is created, we can review the network settings in the VM pane. Networking information is displayed in several places, including in the VM's network settings. Additionally, each Azure resource has a separate pane and exists as an individual resource, so we can view these settings in multiple places. However, **the most complete picture of VM network settings can be found in the VM pane and the NIC pane**.
<!--more-->
## Create an NIC
A NIC is usually created during the VM creation process, but each VM can have multiple NICs. Based on this, we can create an NIC as an individual resource and attach it or detach it as needed. **A NIC cannot exist without a network association**, and this association must be assigned to a VNet and subnet. This is defined during the creation process and cannot be changed later. On the other hand, association with a VM can be changed and the NIC can be attached or detached from a VM at any time.

## Attach an NIC to a VM
Each VM can have multiple NICs. Because of this, we can add a new NIC at any time. The number of NICs that can be associated with a VM depends on the type and size of the VM. To attach an NIC to a VM, the VM needs to be stopped (that is, deallocated); you **cannot add an additional NIC to a running VM**.

## Detach an NIC from a VM
Just as with attaching an NIC, we can detach an NIC at any time and attach it to another VM. To detach an NIC, the VM associated with the NIC must be stopped (that is, deallocated). At least one NIC must be associated with the VM-so you **cannot remove the last NIC from a VM**. All network associations stay with the NIC—they are assigned to the NIC, not to the VM.
