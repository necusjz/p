---
title: Describe Core Azure Architectural Components
abbrlink: 1434545921
date: 2022-04-30 20:31:53
tags: Azure
---
## Overview of Azure subscriptions, management groups, and resources
You need to learn the organizing structure for resources in Azure, which has four levels: *Management Groups*, *Subscriptions*, *Resource Groups*, and *Resources*. The following image shows **the top-down hierarchy of organization for these levels**:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/05.png)

Having seen the top-down hierarchy of organization, let's **describe each of those levels from the bottom up**:
- **Resources**: Resources are instances of services that you create, like VMs, storage, or SQL databases;
- **Resource groups**: Resources are combined into resource groups, which act as a logical container into which Azure resources like web apps, databases, and storage accounts are deployed and managed;
- **Subscriptions**: A subscription groups together user accounts and the resources that have been created by those user accounts. For each subscription, there are limits or quotas on the amount of resources that you can create and use. Organizations can use subscriptions to manage costs and the resources that are created by users, teams, or projects;
- **Management groups**: They help you manage access, policy, and compliance for multiple subscriptions. All subscriptions in a management group automatically inherit the conditions applied to the management group;

<!--more-->
## Azure regions, availability zones, and region pairs
Resources are created in regions, which are different geographical locations around the globe that contain Azure datacenters. Azure is made up of datacenters located around the globe. When you use a service or create a resource such as a SQL database or VM, you're using physical equipment in one or more of these locations. These specific **datacenters aren't exposed to users directly, instead, Azure organizes them into regions**. Some of these regions offer availability zones, which are different Azure datacenters within that region.

### Azure regions
A *Region* is a geographical area on the planet that **contains at least one but potentially multiple datacenters that are nearby and networked together with a low-latency network**. Azure intelligently assigns and controls the resources within each region to ensure workloads are appropriately balanced. When you deploy a resource in Azure, you'll often need to choose the region where you want your resource deployed.

> Some services or VM features are only available in certain regions, such as specific VM sizes or storage types. There are also some global Azure services that don't require you to select a particular region, such as *Azure Active Directory*, *Azure Traffic Manager*, and *Azure DNS*.

A few examples of regions are West US, Canada Central, West Europe, Australia East, and Japan West. Here's **a view of all the available regions** as of June 2020:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/06.png)

#### Why are regions important?
Azure has more global regions than any other cloud provider. These regions give you the flexibility to bring applications closer to your users no matter where they are. Global regions **provide better scalability and redundancy, also preserve data residency for your services**.

#### Special Azure regions
Azure has specialized regions that you might want to use when you **build out your applications for compliance or legal purposes**. A few examples include:
- **US DoD Central, US Gov Virginia, US Gov Iowa and more**: These regions are physical and logical network-isolated instances of Azure for U.S. government agencies and partners. These datacenters are operated by screened U.S. personnel and include additional compliance certifications;
- **China East, China North, and more**: These regions are available through a unique partnership between Microsoft and 21Vianet, whereby Microsoft doesn't directly maintain the datacenters;

### Azure availability zones
You want to ensure your services and data are redundant so you can protect your information in case of failure. When you host your infrastructure, setting up your own redundancy requires that you create duplicate hardware environments. **Azure can help make your app highly available** through *Availability Zone*.

#### What is an availability zone?
Availability zones are physically separate datacenters within an Azure region. Each availability zone is made up of one or more datacenters equipped with independent power, cooling, and networking. An availability zone is set up to be an *Isolation Boundary*. **If one zone goes down, the other continues working**. Availability zones are connected through high-speed, private fiber-optic networks:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/07.png)

#### Supported regions
**Not every region has support for availability zones**. For an updated list, see [Regions that support availability zones in Azure](https://docs.microsoft.com/en-us/azure/availability-zones/az-region).

#### Use availability zones in your apps
You can use availability zones to run mission-critical applications and build high-availability into your application architecture by co-locating your compute, storage, networking, and data resources within a zone and replicating in other zones. Keep in mind that **there could be a cost to duplicating your services and transferring data between zones**.

Availability zones are primarily for VMs, managed disks, load balancers, and SQL databases. Azure services that **support availability zones fall into three categories**:
- **Zonal services**: You pin the resource to a specific zone (for example, VMs, managed disks, IP addresses);
- **Zone-redundant services**: The platform replicates automatically across zones (for example, zone-redundant storage, SQL Database);
- **Non-regional services**: Services are always available from Azure geographies and are resilient to zone-wide outages as well as region-wide outages;

### Azure region pairs
Availability zones are created by using one or more datacenters. There's **a minimum of three zones within a single region**. It's possible that a large disaster could cause an outage big enough to affect even two datacenters. That's why Azure also creates *Region Pair*.

#### What is a region pair?
Each Azure region is always **paired with another region within the same geography (such as US, Europe, or Asia) at least 300 miles away**. This approach allows for the replication of resources (such as VM storage) across a geography that helps reduce the likelihood of interruptions because of events such as natural disasters, civil unrest, power outages, or physical network outages that affect both regions at once. If a region in a pair was affected by a natural disaster, for instance, services would automatically failover to the other region in its region pair. Examples of region pairs in Azure are West US paired with East US and SouthEast Asia paired with East Asia:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/08.png)

Because the pair of regions is directly connected and far enough apart to be isolated from regional disasters, you can use them to provide reliable services and data redundancy. **Some services offer automatic geo-redundant storage by using region pairs**.

**Additional advantages of region pairs**:
- If an extensive Azure outage occurs, one region out of every pair is prioritized to make sure at least one is restored as quickly as possible for applications hosted in that region pair;
- Planned Azure updates are rolled out to paired regions one region at a time to minimize downtime and risk of application outage;
- Data continues to reside within the same geography as its pair (except for Brazil South) for tax- and law-enforcement jurisdiction purposes;

## Azure resources and Azure Resource Manager
Before you create a subscription for your service, you will need to **be ready to start creating resources and storing them in resource groups**. With that in mind, it's important to define those terms:
- **Resource**: A manageable item that's available through Azure. VMs, storage accounts, web apps, databases, and VNets are examples of resources;
- **Resource group**: A container that holds related resources for an Azure solution. The resource group includes resources that you want to manage as a group. You decide which resources belong in a resource group based on what makes the most sense for your organization;

### Azure resource groups
Resource groups are a fundamental element of the Azure platform. A resource group is **a logical container for resources deployed on Azure**. These resources are anything you create in an Azure subscription like VMs, Azure Application Gateway instances, and Azure Cosmos DB instances. All resources must be in a resource group, and a resource can only be a member of a single resource group. Many resources can be moved between resource groups with some services having specific limitations or requirements to move. Resource groups can't be nested. Before any resource can be provisioned, you need a resource group for it to be placed in.

#### Logical grouping
Resource groups exist to help manage and organize your Azure resources. By placing resources of similar usage, type, or location in a resource group, you can provide order and organization to resources you create in Azure. Logical grouping is the aspect that you're most interested in here, because **there's a lot of disorder among our resources**:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/09.png)

#### Life cycle
If you delete a resource group, all resources contained within it are also deleted. Organizing resources by life cycle can be useful in nonproduction environments, where you might try an experiment and then dispose of it. Resource groups **make it easy to remove a set of resources all at once**.

#### Authorization
Resource groups are also a scope for applying *Role-Based Access Control* (RBAC) permissions. By applying RBAC permissions to a resource group, you can **ease administration and limit access to allow only what's needed**.

### Azure resource manager
*Azure Resource Manager* is the deployment and management service for Azure. It **provides a management layer that enables you to create, update, and delete resources in your Azure account**. You use management features like access control, locks, and tags to secure and organize your resources after deployment.

When a user sends a request from any of the Azure tools, APIs, or SDKs, ARM receives the request. It **authenticates and authorizes the request, then sends the request to the Azure service**, which takes the requested action. Because all requests are handled through the same API, you see consistent results and capabilities in all the different tools.

The following image **shows the role ARM plays in handling Azure requests**:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/10.png)

All capabilities that are available in the Azure Portal are **also available through PowerShell, the Azure CLI, REST APIs, and client SDKs**. Functionality initially released through APIs will be represented in the portal within 180 days of initial release.

**The benefits of using ARM**:
- Manage your infrastructure through declarative templates rather than scripts. An ARM template is a JSON file that defines what you want to deploy to Azure;
- Deploy, manage, and monitor all the resources for your solution as a group, rather than handling these resources individually;
- Redeploy your solution throughout the development life cycle and have confidence your resources are deployed in a consistent state;
- Define the dependencies between resources so they're deployed in the correct order;
- Apply access control to all services because RBAC is natively integrated into the management platform;
- Apply tags to resources to logically organize all the resources in your subscription;
- Clarify your organization's billing by viewing costs for a group of resources that share the same tag;

## Azure subscriptions and management groups
As your service gets started with Azure, one of your first steps will be to **create at least one Azure subscription**. You'll use it to create your cloud-based resources in Azure.

### Azure subscriptions
Using Azure requires an Azure subscription. A subscription provides you with authenticated and authorized access to Azure products and services. It also allows you to provision resources. An Azure subscription is a logical unit of Azure services that links to an Azure account, which is **an identity in Azure AD or in a directory that Azure AD trusts**:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/11.png)

An account can have one subscription or multiple subscriptions that have different billing models and to which you apply different access-management policies. You can use Azure subscriptions to define boundaries around Azure products, services, and resources. There are **two types of subscription boundaries that you can use**:
- **Billing boundary**: This subscription type determines how an Azure account is billed for using Azure. You can create multiple subscriptions for different types of billing requirements. Azure generates separate billing reports and invoices for each subscription so that you can organize and manage costs;
- **Access control boundary**: Azure applies access-management policies at the subscription level, and you can create separate subscriptions to reflect different organizational structures. An example is that within a business, you have different departments to which you apply distinct Azure subscription policies. This billing model allows you to manage and control access to the resources that users provision with specific subscriptions;

#### Create additional Azure subscriptions
You might want to **create additional subscriptions for resource or billing management purposes**. For example, you might choose to create additional subscriptions to separate:
- **Environments**: When managing your resources, you can choose to create subscriptions to set up separate environments for development and testing, security, or to isolate data for compliance reasons. This design is particularly useful because resource access control occurs at the subscription level;
- **Organizational structures**: You can create subscriptions to reflect different organizational structures. For example, you could limit a team to lower-cost resources, while allowing the IT department a full range. This design allows you to manage and control access to the resources that users provision within each subscription;
- **Billing**: You might want to also create additional subscriptions for billing purposes. Because costs are first aggregated at the subscription level, you might want to create subscriptions to manage and track costs based on your needs. For instance, you might want to create one subscription for your production workloads and another subscription for your development and testing workloads;

You might also **need additional subscriptions because of the limitation**:
- **Subscription limits**: Subscriptions are bound to some hard limitations. For example, the maximum number of Azure ExpressRoute circuits per subscription is 10. Those limits should be considered as you create subscriptions on your account. If there's a need to go over those limits in particular scenarios, you might need additional subscriptions;

#### Customize billing to meet your needs
**If you have multiple subscriptions, you can organize them into invoice sections**. Each invoice section is a line item on the invoice that shows the charges incurred that month. For example, you might need a single invoice for your organization but want to organize charges by department, team, or project.

Depending on your needs, you can set up multiple invoices within the same billing account. To do this, create additional billing profiles. **Each billing profile has its own monthly invoice and payment method**. The following diagram shows an overview of how billing is structured. If you've previously signed up for Azure or if your organization has an *Enterprise Agreement*, your billing might be set up differently:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/12.png)

### Azure management groups
If your organization has many subscriptions, you might need a way to efficiently manage access, policies, and compliance for those subscriptions. Azure management groups provide a level of scope above subscriptions. You organize subscriptions into containers called management groups and apply your governance conditions to the management groups. **All subscriptions within a management group automatically inherit the conditions applied to the management group**.

Management groups give you enterprise-grade management at a large scale no matter what type of subscriptions you might have. **All subscriptions within a single management group must trust the same Azure AD tenant**. For example, you can apply policies to a management group that limits the regions available for VM creation. This policy would be applied to all management groups, subscriptions, and resources under that management group by only allowing VMs to be created in that region.

#### Hierarchy of management groups and subscriptions
You can **build a flexible structure of management groups and subscriptions to organize your resources into a hierarchy for unified policy and access management**. The following diagram shows an example of creating a hierarchy for governance by using management groups:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/13.png)

You can create a hierarchy that applies a policy. For example, you could limit VM locations to the US West in a group called Production. This policy will inherit onto all the Enterprise Agreement subscriptions that are descendants of that management group and will apply to all VMs under those subscriptions. **This security policy can't be altered by the resource or subscription owner**, which allows for improved governance.

Another scenario where you would use management groups is to provide user access to multiple subscriptions. By moving multiple subscriptions under that management group, you can **create one RBAC assignment on the management group, which will inherit that access to all the subscriptions**. One assignment on the management group can enable users to have access to everything they need instead of scripting RBAC over different subscriptions.

**Important facts about management groups**:
- 10,000 management groups can be supported in a single directory;
- A management group tree can support up to six levels of depth. This limit doesn't include the root level or the subscription level;
- Each management group and subscription can support only one parent;
- Each management group can have many children;
- All subscriptions and management groups are within a single hierarchy in each directory;
