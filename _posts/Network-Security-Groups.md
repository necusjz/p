---
title: Network Security Groups
abbrlink: 907302273
date: 2022-04-21 13:03:11
tags: Azure
---
*Network Security Group* (NSG) is a built-in tool for network control that allow us to **control incoming and outgoing traffic on an NIC or at the subnet level**. They contain sets of rules that allow or deny specific traffic to specific resources or subnets in Azure. An NSG can be associated with either a subnet (by applying security rules to all resources associated with the subnet) or an NIC, which is done by applying security rules to the VM associated with the NIC.

## Create an NSG
As a first step to more effectively control network traffic, we are going to create a new NSG. **The NSG deployment can be initiated during a VM deployment**. This will associate the NSG to the NIC associated with the deployed VM. In this case, the NSG is already associated with the resource, and rules defined in the NSG will apply only to the associated VM.

If the NSG is deployed separately, it is not associated and **the rules that are created within it are not applied until an association has been created with the NIC or the subnet**. When it is associated with a subnet, the NSG rules will apply to all resources on the subnet.
<!--more-->
## Create rules in an NSG
When a new NSG is created, only the default rules are present, which **allow all outbound traffic and block all inbound traffic**. To change these, additional rules need to be created. All outbound traffic is allowed by default, regardless of where it is going. If we want to explicitly deny traffic on a specific port, we need to create a rule to do so.

Make sure you **set the right priority when creating rules**. Rules with the highest priority (that is, those with the lower number) are processed first, so if you have two rules, one of which is denying traffic and one of which is allowing it, the rule with higher priority will take precedence, while the one with lower priority will be ignored.

## Assign an NSG to a subnet
The NSG and its rules must be assigned to a resource to have any impact. When an NSG is associated with a subnet, the rules in the NSG will apply to all of the resources in the subnet. Note that the subnet can be associated with more than one NSG, and the rules from all the NSGs will apply in that case. Priority is the most important factor when looking at a single NSG, but **when the rules from more NSGs are observed, the deny rule will prevail**. So, if we have two NSGs on a subnet, one with *Allow* on port 443 and another one with the *Deny* rule on the same port, traffic on this port will be denied.

## Assign an NSG to an NIC
When an NSG is associated with an NIC, the NSG rules will apply only to a single NIC (or a VM associated with the NIC). The NIC can be associated with only one NSG directly, but **a subnet associated with an NIC can have an association with another NSG** (or even multiple NSGs). This is similar to when we have multiple NSGs assigned to a single subnet, and the deny rule will take higher priority. If one of the NSGs allows traffic on a port, but another NSG is blocking it, traffic will be denied.

## Create an ASG
*Application Security Group* (ASG) is an extension of NSG, allowing us to create additional rules and take better control of traffic. Using only NSGs allows us to create rules that will allow or deny traffic only for a specific source, IP address, or subnet. ASGs allow us to **create better filtering and create additional checks on what traffic is allowed based on ASGs**. 

For example, with NSGs, we can create a rule that subnet A can communicate with subnet B. If we have the application structure for it and an associated ASG, we can add resources in application groups. By adding this element, we can create a rule that will allow communication between subnet A and subnet B, but only if the resources belong to the same application. ASGs don't make much difference on their own and **must be combined with NSGs to create NSG rules** that will allow better control of traffic, applying additional checks before traffic flow is allowed.

## Associate an ASG with a VM
After creating an ASG, we must associate it with a VM. After this is done, we can create rules with the NSG and ASG for traffic control. The VM must be associated with the ASG. We can **associate more than one VM with each ASG**. The ASG is then used in combination with the NSG to create new NSG rules.

## Create rules with an NSG and an ASG
As a final step, we can use NSGs and ASGs to create new rules with better control. This approach allows us to have better control of traffic, **limiting incoming traffic not only to a specific subnet but also only based on whether or not the resource is part of the ASG**.

Using only NSGs to create rules, we can allow or deny traffic only for a specific IP address or range. **With an ASG, we can widen or narrow this as needed**. For example, we can create a rule to allow VMs from a frontend subnet, but only if these VMs are in a specific ASG. Alternatively, we can allow access to a number of VMs from different VNets and subnets, but only if they belong to a specific ASG.
