---
title: Discuss Azure Fundamental Concepts
abbrlink: 641155808
date: 2022-04-27 23:57:04
tags: Azure
---
## Discuss different types of cloud models
There are three deployment models for cloud computing: *Public Cloud*, *Private Cloud*, and *Hybrid Cloud*. Each deployment model has **different aspects that you should consider as you migrate to the cloud**.

### What are public, private, and hybrid clouds?
|Deployment Model|Description|
|:-|:-|
|Public Cloud|Services are offered over the public internet and available to anyone who wants to purchase them. Cloud resources, such as servers and storage, are owned and operated by a third-party cloud service provider, and delivered over the internet.|
|Private Cloud|A private cloud consists of computing resources used exclusively by users from one business or organization. A private cloud can be physically located at your organization's on-site (on-premises) datacenter, or it can be hosted by a third-party service provider.|
|Hybrid Cloud|A hybrid cloud is a computing environment that combines a public cloud and a private cloud by allowing data and applications to be shared between them.|

<!--more-->
### Cloud model comparison
**Public cloud**:
- No capital expenditures to scale up;
- Applications can be quickly provisioned and deprovisioned;
- Organizations pay only for what they use;

**Private cloud**:
- Hardware must be purchased for start-up and maintenance;
- Organizations have complete control over resources and security;
- Organizations are responsible for hardware maintenance and updates;

**Hybrid cloud**:
- Provides the most flexibility;
- Organizations determine where to run their applications;
- Organizations control security, compliance, or legal requirements;

## Describe cloud benefits and considerations
There are **several advantages that a cloud environment has over a physical environment** that the customer can use following its migration to Azure.

### What are some cloud computing advantages?
- **High availability**: Depending on the *Service-Level Agreement* (SLA) that you choose, your cloud-based apps can provide a continuous user experience with no apparent downtime, even when things go wrong;
- **Scalability**: Apps in the cloud can scale *Vertically* and *Horizontally*:
    - Scale vertically to increase compute capacity by adding RAM or CPUs to a virtual machine;
    - Scaling horizontally increases compute capacity by adding instances of resources, such as adding VMs to the configuration;
- **Elasticity**: You can configure cloud-based apps to take advantage of autoscaling, so your apps always have the resources they need;
- **Agility**: Deploy and configure cloud-based resources quickly as your app requirements change;
- **Geo-distribution**: You can deploy apps and data to regional datacenters around the globe, thereby ensuring that your customers always have the best performance in their region;
- **Disaster recovery**: You can deploy your apps with the confidence that comes from knowing that your data is safe in the event of disaster, through taking advantage of cloud-based backup services, data replication, and geo-distribution;

### Capital expenses vs. operating expenses
There are **two different types of expenses that you should consider**:
- *Capital Expenditure* (CapEx) is the up-front spending of money on physical infrastructure, and then deducting that up-front expense over time. The up-front cost from CapEx has a value that reduces over time;
- *Operational Expenditure* (OpEx) is spending money on services or products, and being billed for them now. You can deduct this expense in the same year you spend it. There is no up-front cost, as you pay for a service or product as you use it;

In other words, when the customer owns its infrastructure, it buys equipment that goes onto its balance sheets as assets. **Because a capital investment was made, accountants categorize this transaction as a CapEx**. Over time, to account for the assets' limited useful lifespan, assets are depreciated or amortized.

**Cloud services, on the other hand, are categorized as an OpEx, because of their consumption model**. There's no asset for the customer to amortize, and its cloud service provider manages the costs that are associated with the purchase and lifespan of the physical equipment. As a result, OpEx has a direct impact on net profit, taxable income, and the associated expenses on the balance sheet.

To summarize, **CapEx requires significant up-front financial costs, as well as ongoing maintenance and support expenditures**. By contrast, OpEx is a consumption-based model, so the customer is only responsible for the cost of the computing resources that it uses.

### Cloud computing is a consumption-based model
Cloud service providers operate on a consumption-based model, which means that **end users only pay for the resources that they use**. Whatever they use is what they pay for. A consumption-based model has many benefits, including:
- No upfront costs;
- No need to purchase and manage costly infrastructure that users might not use to its fullest;
- The ability to pay for additional resources when they are needed;
- The ability to stop paying for resources that are no longer needed;

## Describe different cloud services
If you've been around cloud computing for a while, you've probably seen the *PaaS*, *IaaS*, and *SaaS* acronyms for the different cloud service models. These models define **the different levels of shared responsibility that a cloud provider and cloud tenant are responsible for**.

### What are cloud service models?
|Model|Definition|Description|
|:-|:-|:-|
|IaaS|Infrastructure-as-a-Service|This cloud service model is the closest to managing physical servers; a cloud provider will keep the hardware up-to-date, but operating system maintenance and network configuration is up to you as the cloud tenant. For example, Azure virtual machines are fully operational virtual compute devices running in Microsoft datacenters. An advantage of this cloud service model is rapid deployment of new compute devices. Setting up a new virtual machine is considerably faster than procuring, installing, and configuring a physical server.|
|PaaS|Platform-as-a-Service|This cloud service model is a managed hosting environment. The cloud provider manages the virtual machines and networking resources, and the cloud tenant deploys their applications into the managed hosting environment. For example, Azure App Services provides a managed hosting environment where developers can upload their web applications, without having to worry about the physical hardware and software requirements.|
|SaaS|Software-as-a-Service|In this cloud service model, the cloud provider manages all aspects of the application environment, such as virtual machines, networking resources, data storage, and applications. The cloud tenant only needs to provide their data to the application managed by the cloud provider. For example, Microsoft Office 365 provides a fully working version of Microsoft Office that runs in the cloud. All you need to do is create your content, and Office 365 takes care of everything else.|

The following illustration **demonstrates the services that might run in each of the cloud service models**:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/03.png)

#### IaaS
IaaS is the most flexible category of cloud services. It aims to **give you complete control over the hardware that runs your application**. Instead of buying hardware, with IaaS, you rent it.

**Advantages**:
- **No CapEx**. Users have no up-front costs;
- **Agility**. Applications can be made accessible quickly, and deprovisioned whenever needed;
- **Management**. The shared responsibility model applies; the user manages and maintains the services they have provisioned, and the cloud provider manages and maintains the cloud infrastructure;
- **Consumption-based model**. Organizations pay only for what they use and operate under an OpEx model;
- **Skills**. No deep technical skills are required to deploy, use, and gain the benefits of a public cloud. Organizations can use the skills and expertise of the cloud provider to ensure workloads are secure, safe, and highly available;
- **Cloud benefits**. Organizations can use the skills and expertise of the cloud provider to ensure workloads are made secure and highly available;
- **Flexibility**. IaaS is the most flexible cloud service because you have control to configure and manage the hardware running your application;

#### PaaS
PaaS provides the same benefits and considerations as IaaS, but there are some **additional benefits to be aware of**.

**Advantages**:
- **No CapEx**. Users have no up-front costs;
- **Agility**. PaaS is more agile than IaaS, and users don't need to configure servers for running applications;
- **Consumption-based model**. Users pay only for what they use, and operate under an OpEx model;
- **Skills**. No deep technical skills are required to deploy, use, and gain the benefits of PaaS;
- **Cloud benefits**. Users can take advantage of the skills and expertise of the cloud provider to ensure that their workloads are made secure and highly available. In addition, users can gain access to more cutting-edge development tools. They can then apply these tools across an application's lifecycle;
- **Productivity**. Users can focus on application development only, because the cloud provider handles all platform management. Working with distributed teams as services is easier because the platform is accessed over the internet. You can make the platform available globally more easily;

**Disadvantage**:
- **Platform limitations**. There can be some limitations to a cloud platform that might affect how an application runs. When you're evaluating which PaaS platform is best suited for a workload, be sure to consider any limitations in this area;

#### SaaS
SaaS is software that's centrally hosted and managed for you and your users or customers. Usually one version of the application is used for all customers, and it's **licensed through a monthly or annual subscription**. SaaS provides the same benefits as IaaS, but again there are some additional benefits to be aware of too.

**Advantages**:
- **No CapEx**. Users have no up-front costs;
- **Agility**. Users can provide staff with access to the latest software quickly and easily;
- **Pay-as-you-go pricing model**. Users pay for the software they use on a subscription model, typically monthly or yearly, regardless of how much they use the software;
- **Skills**. No deep technical skills are required to deploy, use, and gain the benefits of SaaS;
- **Flexibility**. Users can access the same application data from anywhere;

**Disadvantage**:
- **Software limitations**. There can be some limitations to a software application that might affect how users work. Because you're using as-is software, you don't have direct control of features. When you're evaluating which SaaS platform is best suited for a workload, be sure to consider any business needs and software limitations;

### Cloud service model comparison
|IaaS|PaaS|SaaS|
|:-|:-|:-|
|The most flexible cloud service.|Focus on application development.|Pay-as-you-go pricing model.|
|You configure and manage the hardware for your application.|Platform management is handled by the cloud provider.|Users pay for the software they use on a subscription model.|

The following chart illustrates **the various levels of responsibility between a cloud provider and a cloud tenant**:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/04.png)

### What is serverless computing?
Like PaaS, *Serverless Computing* enables developers to build applications faster by eliminating the need for them to manage infrastructure. With serverless applications, the cloud service provider automatically provisions, scales, and manages the infrastructure required to run the code. Serverless architectures are **highly scalable and event-driven, only using resources when a specific function or trigger occurs**.

It's important to note that servers are still running the code. The "serverless" name comes from the fact that the tasks associated with infrastructure provisioning and management are invisible to the developer. This approach **enables developers to increase their focus on the business logic, and deliver more value to the core of the business**. Serverless computing helps teams increase their productivity and bring products to market faster, and it allows organizations to better optimize resources and stay focused on innovation.
