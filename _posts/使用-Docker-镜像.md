---
title: 使用 Docker 镜像
date: 2019-06-09 13:09:58
tags:
  - Docker
---
**镜像**是 Docker 三大核心概念中最重要的。
## 获取镜像
可以使用 **docker pull 命令**直接从 Docker Hub 镜像源来下载镜像，描述一个镜像需要包括“名称+标签”信息（NAME[:TAG]）。
```bash
$ docker pull ubuntu:18.04
```
> 如果不显式指定 TAG，则默认会选择 latest 标签。从稳定性上考虑，不要在生产环境中忽略镜像的标签信息或使用默认的 lastest 标记的镜像。

镜像文件一般由若干层（layer）组成，当不同的镜像包括相同的层时，本地仅存储了层的一份内容，减少了存储空间。
如果从非官方的仓库下载镜像，则需要在仓库名称前指定完整的仓库地址：
```bash
$ docker pull hub.c.163.com/public/ubuntu:18.04
```
下载镜像到本地后，即可随时使用该镜像了：
```bash
$ docker run -it ubuntu:18.04 /bin/bash
```
<!--more-->
## 查看镜像信息
### docker images
**docker images 命令**可以列出本地主机上已有镜像的基本信息，可以使用该 ID 的前若干个字符组成的`可区分串`来替代完整的 ID。
镜像大小信息只是表示了该镜像的**逻辑体积**大小，实际上由于相同的镜像层本地只会存储一份，物理上占用的存储空间会小于各镜像逻辑体积之和。
### docker tag
为了方便在后续工作中使用特定镜像，还可以使用 **docker tag 命令**来为本地镜像任意添加新的标签。
```bash
$ docker tag ubuntu:latest myubuntu:latest
```
ID 完全一致，添加的标签实际上起到了`类似链接`的作用。
### docker inspect
使用 **docker inspect 命令**可以获取该镜像的详细信息，只要其中一项内容时，可以使用 -f 来指定：
```bash
$ docker inspect -f {{".Architecture"}} ubuntu:18.04
```
### docker history
可以使用 **docker history 命令**列出各层的创建信息。
## 搜寻镜像
使用 **docker search 命令**可以搜索 Docker Hub 官方仓库中的镜像。
搜索所有收藏数超过 4 的、关键词包括 tensorflow 的镜像（默认的输出结果将按照星级评价进行排序）：
```bash
$ docker search --filter=stars=4 tensorflow
```
## 删除和清理镜像
### 使用标签删除镜像
使用 **docker rmi 命令**可以删除镜像。
> 当同一个镜像拥有多个标签的时候，只是删除了该镜像多个标签中的指定标签而已，并不影响镜像文件。

当镜像只剩下一个标签的时候就要小心了，此时再使用 docker rmi 命令会彻底删除镜像。
### 使用 ID 删除镜像
> 先尝试删除所有指向该镜像的标签，然后删除该镜像文件本身。

当有该镜像创建的容器存在时，镜像文件默认是无法被删除的。正确的做法是，先删除依赖该镜像的所有容器，再来删除镜像。
### 清理镜像
使用 Docker 一段时间后，系统中可能会遗留一些临时的镜像文件，以及一些没有被使用的镜像，可以通过 **docker image prune 命令**来进行清理：
```bash
$ docker image prune -f
```
## 创建镜像
### 基于已有容器创建
使用 **docker commit 命令**，主要选项包括：-m：提交消息；-a：作者信息。
```bash
$ docker commit -m "add a new file" -a "hyang" a925cb40b3f0 test:0.1
```
### 基于本地模版导入
可以使用 **docker import 命令**，直接从一个操作系统模版文件导入一个镜像：
```bash
$ cat ubuntu-18.04-x86_64-minimal.tar.gz | docker import - ubuntu:18.04
```
### 基于 Dockerfile 创建
基于 Dockerfile 创建是最常见的方式。Dockerfile 是一个文本文件，利用给定的指令，描述基于某个父镜像创建新镜像的过程。
创建的过程可以使用 **docker build 命令**：
```bash
$ docker build -t python:3
```
## 存出和载入镜像
### 存出镜像
可以使用 **docker save 命令**，导出镜像到指定的文件中：
```bash
$ docker save -o ubuntu_18.04.tar ubuntu:18.04
```
### 载入镜像
可以使用 **docker load 命令**，从指定文件中读入镜像内容：
```bash
$ docker load -i ubuntu_18.04.tar
```
## 上传镜像
使用 **docker push 命令**默认上传到 Docker Hub 官方仓库（需要登录）。
可以先添加新的标签，然后再上传镜像：
```bash
$ docker tag test:latest hyang/test:latest
$ docker push hyang/test:latest
```
登陆信息会记录到本地 `~/.docker` 目录下。
