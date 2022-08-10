---
title: Contribute to Azure CLI
abbrlink: 4286004591
date: 2022-04-04 18:30:21
tags: Azure
---
## What is Azure CLI?
Azure CLI is a command-line tool to create and manage resources. You interact with Azure by running commands in a terminal or writing scripts to automate tasks. Azure CLI interacts with the **Azure Resource Manager** (ARM) service, which is the management layer to interact with resources in your account.

## Prerequisites
Fork and clone the repositories you wish to develop for:
```text
$ git clone https://github.com/necusjz/azure-cli.git
$ git clone https://github.com/necusjz/azure-cli-extensions.git
```

Add or change the upstream:
```text
$ git remote add upstream https://github.com/Azure/azure-cli.git
$ git remote set-url upstream https://github.com/Azure/azure-cli.git
```

Install and setup *azdev*:
```text
$ pip install azdev
$ azdev setup -c -r ./azure-cli-extensions
```

List what extensions are currently visible to your development environment:
```text
$ azdev extension list -o table
$ azdev extension add {}
```

Publish extensions:
```text
$ azdev extension publish {} --storage-account {} --storage-container {} --storage-account-key {}
```
