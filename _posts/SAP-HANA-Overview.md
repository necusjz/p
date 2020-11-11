---
title: SAP HANA Overview
date: 2019-06-30 23:00:43
tags:
  - HANA
---
SAP HANA is a **data management platform** that is deploy as an appliance or in the cloud.
And its core is the `SAP HANA database`, an innovative in-memory database management system which makes full use of the capabilities of current hardware to increase application performance, to reduce cost of ownership and to enable new scenarios and applications that were not possible before.
The SAP HANA database is a hybrid database management system that combines several paradigms in one system. It includes a full **relational database management system** where individual tables can be stored column-based or row-based in memory, and column-based on disk.
It supports SQL, transactional isolation and recovery (ACID properties) and high availability. These capabilities are extended with the following features:
- **Text analysis and search** capabilities that support a state-of-the-art search experience. This includes full text search with advanced features such as free style search, linguistic search and fault-tolerant fuzzy search.
- Native support for **geo-spatial** data and operations.
- Support for **series data**.
- Built-in support for **planning** applications.
- SAP HANA provides capabilities for the efficient storage and processing of **graph-like** data structures with a flexible data schema.
- A **task framework** for executing potentially long running tasks. Task can started asynchronously and can be monitored on the level of application-defined steps.

<!--more-->
SAP HANA can combine and analyze all kinds of data within the **same database management system** - a core capability required by modern business applications that provides a competitive advantage for SAP.
The SAP HANA database is built for **high performance** applications. All relevant data is kept in main memory, so all read operations can run in main memory. SAP HANA is also designed to make full use of multi-core CPUs by parallelization of execution.
The SAP HANA database provides several programming and modeling options for **executing application logic close to the data**. This is required to make full use of the parallelization and optimization capabilities of SAP HANA and to reduce the amount of data that needs to be transported between the database and the application server.
A single SAP HANA system can contain several databases, which are isolated from each other and have their own data, metadata, and users. These contained databases are called **multi-tenant database containers**.
SAP HANA can process **big data** both inside the SAP HANA database and by integration with Apache Hadoop.
SAP HANA **eXtended application Services** (XS) is a layer on top of the SAP HANA database. It provides the platform for running SAP HANA-based web applications.
The database part of an XS Advanced application is deployed using the SAP **HANA Deployment Infrastructure** (HDI). HDI is a service layer of the SAP HANA database that simplifies the continuous deployment of HANA database objects.
