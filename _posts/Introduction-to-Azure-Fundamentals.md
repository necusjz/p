---
title: Introduction to Azure Fundamentals
abbrlink: 2304314973
date: 2022-04-26 00:16:19
tags: Azure
---
## What is cloud computing?
Have you ever wondered what cloud computing is? It's **the delivery of computing services over the internet**, which is otherwise known as the cloud. These services include servers, storage, databases, networking, software, analytics, and intelligence. Cloud computing offers faster innovation, flexible resources, and economies of scale.

### Why is cloud computing typically cheaper to use?
Cloud computing is the delivery of computing services over the internet by using a pay-as-you-go pricing model. You typically **pay only for the cloud services you use**, which helps you:
- Lower your operating costs;
- Run your infrastructure more efficiently;
- Scale as your business needs change;

To put it another way, cloud computing is a way to **rent compute power and storage from someone else's datacenter**. You can treat cloud resources like you would resources in your own datacenter. When you're done using them, you give them back. You're billed only for what you use.

**Instead of maintaining CPUs and storage in your datacenter**, you rent them for the time that you need them. The cloud provider takes care of maintaining the underlying infrastructure for you. The cloud enables you to quickly solve your toughest business challenges, and bring cutting-edge solutions to your users.
<!--more-->
### Why should I move to the cloud?
The cloud helps you **move faster and innovate in ways that were once nearly impossible**. In our ever-changing digital world, two trends emerge:
- Teams deliver new features to their users at record speeds;
- Users expect an increasingly rich and immersive experience with their devices and with software;

Software releases were once scheduled in terms of months or even years. Today, teams **release features in smaller batches that are often scheduled in days or weeks**. Some teams even deliver software updates continuously—sometimes with multiple releases within the same day.

Think of all the ways you **interact with devices that you couldn't do a few years ago**. Many devices can recognize your face and respond to voice commands. Augmented reality changes the way you interact with the physical world. Household appliances are even beginning to act intelligently. These technologies are only a few examples, and many of them are powered by the cloud.

To **power your services and deliver innovative and novel user experiences more quickly**, the cloud provides on-demand access to:
- A nearly limitless pool of raw compute, storage, and networking components;
- Speech recognition and other cognitive services that help make your application stand out from the crowd;
- Analytics services that deliver telemetry data from your software and devices;

## What is Azure?
Azure is **a continually expanding set of cloud services that help your organization meet your current and future business challenges**. Azure gives you the freedom to build, manage, and deploy applications on a massive global network using your favorite tools and frameworks.

### What does Azure offer?
With help from Azure, you have everything you need to build your next great solution. The following lists **several of the benefits that Azure provides**, so you can easily invent with purpose:
- **Be ready for the future**: Continuous innovation from Microsoft supports your development today and your product visions for tomorrow;
- **Build on your terms**: You have choices. With a commitment to open source, and support for all languages and frameworks, you can build how you want and deploy where you want to;
- **Operate hybrid seamlessly**: On-premises, in the cloud, and at the edge—we'll meet you where you are. Integrate and manage your environments with tools and services designed for a hybrid cloud solution;
- **Trust your cloud**: Get security from the ground up, backed by a team of experts, and proactive compliance trusted by enterprises, governments, and startups;

### What can I do with Azure?
Azure provides **more than 100 services that enable you to do everything from running your existing applications on virtual machines**, to exploring new software paradigms, such as intelligent bots and mixed reality.

Many teams start exploring the cloud by moving their existing applications to virtual machines that run in Azure. **Migrating your existing apps to virtual machines is a good start**, but the cloud is much more than a different place to run your virtual machines.

For example, Azure provides AI and machine-learning services that can naturally communicate with your users through vision, hearing, and speech. It also provides storage solutions that dynamically grow to accommodate massive amounts of data. Azure services **enable solutions that aren't feasible without the power of the cloud**.

### What is the Azure Portal?
The *Azure Portal* is **a web-based, unified console that provides an alternative to command-line tools**. With the Azure Portal, you can manage your Azure subscription by using a graphical user interface. You can:
- Build, manage, and monitor everything from simple web apps to complex cloud deployments;
- Create custom dashboards for an organized view of resources;
- Configure accessibility options for an optimal experience;

The Azure Portal is **designed for resiliency and continuous availability**. It maintains a presence in every Azure datacenter. This configuration makes the Azure Portal resilient to individual datacenter failures and avoids network slowdowns by being close to users. The Azure Portal updates continuously and requires no downtime for maintenance activities.

### What is Azure Marketplace?
*Azure Marketplace* helps connect users with Microsoft partners, independent software vendors, and startups that are offering their solutions and services, which are optimized to run on Azure. Azure Marketplace customers can **find, try, purchase, and provision applications and services from hundreds of leading service providers**. All solutions and services are certified to run on Azure.

The solution catalog spans several industry categories such as open-source container platforms, virtual machine images, databases, application build and deployment software, developer tools, threat detection, and blockchain. Using Azure Marketplace, you can **provision end-to-end solutions quickly and reliably, hosted in your own Azure environment**. At the time of writing, there are more than 8,000 listings.

Azure Marketplace is **designed for IT pros and cloud developers interested in commercial and IT software**. Microsoft partners also use it as a launch point for all joint go-to-market activities.

## Tour of Azure services
Azure can help you tackle tough business challenges. You bring your requirements, creativity, and favorite software development tools. **Azure brings a massive global infrastructure that's always available for you to build your applications on**.

### Azure services
Here's a big-picture view of **the available services and features in Azure**:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/01.png)

### Compute
Compute services are often **one of the primary reasons why companies move to the Azure platform**. Azure provides a range of options for hosting applications and services. Here are some examples of compute services in Azure:

|Service Name|Service Function|
|:-|:-|
|Azure Virtual Machines|Windows or Linux virtual machines (VMs) hosted in Azure.|
|Azure Virtual Machine Scale Sets|Scaling for Windows or Linux VMs hosted in Azure.|
|Azure Kubernetes Service|Cluster management for VMs that run containerized services.|
|Azure Service Fabric|Distributed systems platform that runs in Azure or on-premises.|
|Azure Batch|Managed service for parallel and high-performance computing applications.|
|Azure Container Instances|Containerized apps run on Azure without provisioning servers or VMs.|
|Azure Functions|An event-driven, serverless compute service.|

### Networking
**Linking compute resources and providing access to applications** is the key function of Azure networking. Networking functionality in Azure includes a range of options to connect the outside world to services and features in the global Azure datacenters. Here are some examples of networking services in Azure:

|Service Name|Service Function|
|:-|:-|
|Azure Virtual Network|Connects VMs to incoming virtual private network (VPN) connections.|
|Azure Load Balancer|Balances inbound and outbound connections to applications or service endpoints.|
|Azure Application Gateway|Optimizes app server farm delivery while increasing application security.|
|Azure VPN Gateway|Accesses Azure Virtual Networks through high-performance VPN gateways.|
|Azure DNS|Provides ultra-fast DNS responses and ultra-high domain availability.|
|Azure Content Delivery Network|Delivers high-bandwidth content to customers globally.|
|Azure DDoS Protection|Protects Azure-hosted applications from distributed denial of service (DDOS) attacks.|
|Azure Traffic Manager|Distributes network traffic across Azure regions worldwide.|
|Azure ExpressRoute|Connects to Azure over high-bandwidth dedicated secure connections.|
|Azure Network Watcher|Monitors and diagnoses network issues by using scenario-based analysis.|
|Azure Firewall|Implements high-security, high-availability firewall with unlimited scalability.|
|Azure Virtual WAN|Creates a unified wide area network (WAN) that connects local and remote sites.|

### Storage
Azure provides **four main types of storage services**:

|Service Name|Service Function|
|:-|:-|
|Azure Blob Storage|Storage service for very large objects, such as video files or bitmaps.|
|Azure File Storage|File shares that can be accessed and managed like a file server.|
|Azure Queue Storage|A data store for queuing and reliably delivering messages between applications.|
|Azure Table Storage|Table storage is a service that stores non-relational structured data (also known as structured NoSQL data) in the cloud, providing a key/attribute store with a schemaless design.|

These services all **share several common characteristics**:
- **Durable** and highly available with redundancy and replication;
- **Secure** through automatic encryption and role-based access control;
- **Scalable** with virtually unlimited storage;
- **Managed**, handling maintenance and any critical problems for you;
- **Accessible** from anywhere in the world over HTTP or HTTPS;

### Mobile
With Azure, developers can **create mobile backend services for iOS, Android, and Windows apps quickly and easily**. Features that used to take time and increase project risks, such as adding corporate sign-in and then connecting to on-premises resources such as SAP, Oracle, SQL Server, and SharePoint, are now simple to include. Other features of this service include:
- Offline data synchronization;
- Connectivity to on-premises data;
- Broadcasting push notifications;
- Autoscaling to match business needs;

### Databases
Azure provides multiple database services to **store a wide variety of data types and volumes**. And with global connectivity, this data is available to users instantly:

|Service Name|Service Function|
|:-|:-|
|Azure Cosmos DB|Globally distributed database that supports NoSQL options.|
|Azure SQL Database|Fully managed relational database with auto-scale, integral intelligence, and robust security.|
|Azure Database for MySQL|Fully managed and scalable MySQL relational database with high availability and security.|
|Azure Database for PostgreSQL|Fully managed and scalable PostgreSQL relational database with high availability and security.|
|SQL Server on Azure Virtual Machines|Service that hosts enterprise SQL Server apps in the cloud.|
|Azure Synapse Analytics|Fully managed data warehouse with integral security at every level of scale at no extra cost.|
|Azure Database Migration Service|Service that migrates databases to the cloud with no application code changes.|
|Azure Cache for Redis|Fully managed service caches frequently used and static data to reduce data and application latency.|
|Azure Database for MariaDB|Fully managed and scalable MariaDB relational database with high availability and security.|

### Web
Having a great web experience is critical in today's business world. Azure **includes first-class support to build and host web apps and HTTP-based web services**. The following Azure services are focused on web hosting:

|Service Name|Service Function|
|:-|:-|
|Azure App Service|Quickly create powerful cloud web-based apps.|
|Azure Notification Hubs|Send push notifications to any platform from any backend.|
|Azure API Management|Publish APIs to developers, partners, and employees securely and at scale.|
|Azure Cognitive Search|Deploy this fully managed search as a service.|
|Web Apps Feature of Azure App Service|Create and deploy mission-critical web apps at scale.|
|Azure SignalR Service|Add real-time web functionalities easily.|

### IoT
People are able to access more information than ever before. Personal digital assistants led to smartphones, and now there are smart watches, smart thermostats, and even smart refrigerators. Personal computers used to be the norm. Now **the internet allows any item that's online-capable to access valuable information**. This ability for devices to garner and then relay information for data analysis is referred to as IoT. Many services can assist and drive end-to-end solutions for IoT on Azure:

|Service Name|Service Function|
|:-|:-|
|IoT Central|Fully managed global IoT software as a service (SaaS) solution that makes it easy to connect, monitor, and manage IoT assets at scale.|
|Azure IoT Hub|Messaging hub that provides secure communications between and monitoring of millions of IoT devices.|
|IoT Edge|Fully managed service that allows data analysis models to be pushed directly onto IoT devices, which allows them to react quickly to state changes without needing to consult cloud-based AI models.|

### Big data
Data comes in all formats and sizes. When we talk about big data, we're referring to large volumes of data. Data from weather systems, communications systems, genomic research, imaging platforms, and many other scenarios generate hundreds of gigabytes of data. This amount of data makes it hard to analyze and make decisions. It's often **so large that traditional forms of processing and analysis are no longer appropriate**. Open-source cluster technologies have been developed to deal with these large data sets. Azure supports a broad range of technologies and services to provide big data and analytic solutions:

|Service Name|Service Function|
|:-|:-|
|Azure Synapse Analytics|Run analytics at a massive scale by using a cloud-based enterprise data warehouse that takes advantage of massively parallel processing to run complex queries quickly across petabytes of data.|
|Azure HDInsight|Process massive amounts of data with managed clusters of Hadoop clusters in the cloud.|
|Azure Databricks|Integrate this collaborative Apache Spark-based analytics service with other big data services in Azure.|

### AI
AI, in the context of cloud computing, is based around a broad range of services, the core of which is machine learning. Machine learning is a data science technique that allows computers to use existing data to forecast future behaviors, outcomes, and trends. Using machine learning, **computers learn without being explicitly programmed**.

**Forecasts or predictions from machine learning can make apps and devices smarter**. For example, when you shop online, machine learning helps recommend other products you might like based on what you've purchased. Or when your credit card is swiped, machine learning compares the transaction to a database of transactions and helps detect fraud. And when your robot vacuum cleaner vacuums a room, machine learning helps it decide whether the job is done. Here are some of the most common AI and machine learning service types in Azure:

|Service Name|Service Function|
|:-|:-|
|Azure Machine Learning Service|Cloud-based environment you can use to develop, train, test, deploy, manage, and track machine learning models. It can auto-generate a model and auto-tune it for you. It will let you start training on your local machine, and then scale out to the cloud.|
|Azure ML Studio|Collaborative visual workspace where you can build, test, and deploy machine learning solutions by using prebuilt machine learning algorithms and data-handling modules.|

A closely related set of products are the *Cognitive Services*. You can **use these prebuilt APIs in your applications to solve complex problems**:

|Service Name|Service Function|
|:-|:-|
|Vision|Use image-processing algorithms to smartly identify, caption, index, and moderate your pictures and videos.|
|Speech|Convert spoken audio into text, use voice for verification, or add speaker recognition to your app.|
|Knowledge Mapping|Map complex information and data to solve tasks such as intelligent recommendations and semantic search.|
|Bing Search|Add Bing Search APIs to your apps and harness the ability to comb billions of webpages, images, videos, and news with a single API call.|
|Natural Language Processing|Allow your apps to process natural language with prebuilt scripts, evaluate sentiment, and learn how to recognize what users want.|

### DevOps
DevOps brings together people, processes, and technology by **automating software delivery to provide continuous value to your users**. With Azure DevOps, you can create build and release pipelines that provide continuous integration, delivery, and deployment for your applications. You can integrate repositories and application tests, perform application monitoring, and work with build artifacts.

You can also work with and backlog items for tracking, automate infrastructure deployment, and integrate a range of third-party tools and services such as Jenkins and Chef. All of these functions and many more are **closely integrated with Azure to allow for consistent, repeatable deployments** for your applications to provide streamlined build and release processes:

|Service Name|Service Function|
|:-|:-|
|Azure DevOps|Use development collaboration tools such as high-performance pipelines, free private Git repositories, configurable Kanban boards, and extensive automated and cloud-based load testing. Formerly known as Visual Studio Team Services.|
|Azure DevTest Labs|Quickly create on-demand Windows and Linux environments to test or demo applications directly from deployment pipelines.|

## Get started with Azure accounts
To create and use Azure services, you need an Azure subscription. When you're completing Learn modules, most of the time a temporary subscription is created for you, which runs in an environment called the Learn sandbox. When you're working with your own applications and business needs, you need to create an Azure account, and a subscription will be created for you. **After you've created an Azure account, you're free to create additional subscriptions**.

For example, your company might use a single Azure account for your business and separate subscriptions for development, marketing, and sales departments. **After you've created an Azure subscription, you can start creating Azure resources within each subscription**:
![](https://raw.githubusercontent.com/necusjz/p/master/Azure/02.png)

If you're new to Azure, you can sign up for a free account on the Azure website to start exploring at no cost to you. **When you're ready, you can choose to upgrade your free account**. You can create a new subscription that enables you to start paying for Azure services you need to use that are beyond the limits of a free account.

### Create an Azure account
You can purchase Azure access directly from Microsoft by signing up on the [Azure website](https://azure.microsoft.com/) or through a Microsoft representative. **You can also purchase Azure access through a Microsoft partner**. Cloud Solution Provider partners offer a range of complete managed-cloud solutions for Azure.

### What is the Azure free account?
The Azure **free account includes**:
- Free access to popular Azure products for 12 months;
- A credit to spend for the first 30 days;
- Access to more than 25 products that are always free;

The Azure free account is an excellent way for new users to get started and explore. To sign up, you need a phone number, a credit card, and a Microsoft or GitHub account. **The credit card information is used for identity verification only**. You won't be charged for any services until you upgrade to a paid subscription.

### What is the Azure free student account?
The Azure **free student account offer includes**:
- Free access to certain Azure services for 12 months;
- A credit to use in the first 12 months;
- Free access to certain software developer tools;

The [Azure free student account](https://azure.microsoft.com/free/students/) is an offer for students that gives $100 credit and free developer tools. Also, you can **sign up without a credit card**.

### What is the Learn sandbox?
Many of the Learn exercises use a technology called the sandbox, which creates a temporary subscription that's added to your Azure account. This temporary subscription allows you to **create Azure resources for the duration of a Learn module**. Learn automatically cleans up the temporary resources for you after you've completed the module.

When you're completing a Learn module, you're welcome to use your personal subscription to complete the exercises in a module. The sandbox is the preferred method to use though, because it allows you to **create and test Azure resources at no cost to you**.
