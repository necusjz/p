---
title: Bump Python SDK
abbrlink: 558864227
date: 2022-04-11 11:40:53
tags: Azure
---
## Update corresponding versions
Update *package name + package version*:
- setup.py;
- requirements.py3.Linux.txt;
- requirements.py3.Darwin.txt;
- requirements.py3.Windows.txt;

Update *resource type + api version*:
- _shared.py (latest);

## Setup development environment
Install expected Python packages:
```text
$ azdev setup -c -r ./azure-cli-extensions
```
<!--more-->
## Find affected modules
Get all test failures in *test_results.xml*:
```text
$ azdev test --no-exitfirst
```

## Re-run tests in live mode
Make sure the new API version is working in all modules:
```text
$ azdev test --no-exitfirst --lf --live
```
