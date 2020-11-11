---
title: 操作 Docker 容器
date: 2019-06-16 17:18:38
tags:
  - Docker
---
**容器**是 Docker 的另一个核心概念，容器是镜像的一个运行实例。镜像是静态的只读文件，容器中的应用进程处于运行状态。
## 创建容器
对容器的操作就像`直接操作应用`一样简单和快速。
### 新建容器
可以使用 **docker create** 命令新建一个容器，新建的容器处于停止状态，可以使用 docker start 命令来启动他。
```
$ docker create -it ubuntu:latest
```
容器是整个 Docker 技术栈的核心，支持的选项十分复杂。主要包括如下几大类：
- 与容器运行模式相关
- 与容器环境配置相关
- 与容器资源限制和安全保护相关

<!--more-->
### 启动容器
使用 **docker start** 命令来启动一个已经创建的容器：
```
$ docker start af
```
此时，通过 docker ps 命令可以查看到一个运行中的容器。
### 新建并启动容器
也可以直接`新建并启动`容器，所需要的命令为 **docker run**。等价于先执行 docker create 命令，再执行 docker start 命令。
```
$ docker run -it ubuntu:18.04 /bin/bash
```
> 对于容器来说，当其中的应用退出后，容器的使命完成，也就没有继续运行的必要了。

### 守护态运行
更多的时候，需要让容器在后台以守护态（daemonized）形式运行，可以通过添加 `-d` 参数来实现。
```
$ docker run -d ubuntu /bin/bash -c "while true; do echo hello world; sleep 1; done"
```
### 查看容器输出
要获取容器的输出信息，可以通过 **docker logs** 命令。
```
$ docker logs ce554267d7a4
```
## 停止容器
### 暂停容器
可以使用 **docker pause** 命令来暂停一个运行中的容器：
```
$ docker run --name test --rm -it ubuntu bash
$ docker pause test
```
处于 `Paused` 状态的容器，可以使用 **docker unpause** 命令来恢复到运行状态。
### 终止容器
可以使用 **docker stop** 来终止一个运行中的容器，该命令会首先向容器发送 SIGTERM 信号，等待一段超时时间后（默认为 10 秒），再发送 SIGKILL 信号来终止容器。
还可以通过 **docker kill** 直接发送 SIGKILL 信号来强行终止容器
执行 **docker container prune** 命令，会自动清除掉所有处于 `Exited` 状态的容器。
> 处于 Exited 状态的容器，可以通过 docker start 命令来重新启动。

**docker restart** 命令会将一个运行态的容器先终止，然后再重新启动。
## 进入容器
使用 `-d` 参数，容器启动后进入后台，用户无法看到其中的信息，也无法进行操作。此时，推荐使用官方的 **attach** 或 **exec** 命令。
### attach 命令
```
$ docker attach nostalgic_hypatia
```
使用 attach 命令有时候并不方便。当多个窗口同时 attach 到同一个容器的时候，所有窗口都会`同步显示`；当某个窗口因命令阻塞时，其他窗口也无法执行操作了。
### exec 命令
```
$ docker exec -it 243c32535da7 /bin/bash
```
可以在运行中容器内直接执行任意命令。会打开一个新的 bash 终端，在不影响容器内其他应用的前提下，用户可以与容器进行交互。
> `-t` 选项让 Docker 分配一个伪终端（pseudo-tty）并绑定到容器的标准输入上；`-i` 则让容器的标准输入保持打开。通过 exec 命令对容器执行操作是最为推荐的方式。

## 删除容器
```
$ docker rm ce554267d7a4
```
默认情况下，**docker rm** 命令只能删除已经处于终止或退出状态的容器，并不能删除还处于运行状态的容器。
## 导出和导入容器
### 导出容器
导出一个已经创建的容器到一个文件，不管此时这个容器是否处于运行状态，可以使用 **docker export** 命令：
```
$ docker export e81 > test_for_stop.tar
```
### 导入容器
导出的文件又可以使用 **docker import** 命令导入变成镜像：
```
$ docker import test_for_stop.tar test/ubuntu:v1.0
```
既可以使用 docker load 命令来导入镜像存储文件到本地镜像库，也可以使用 docker import 命令来导入一个容器快照到本地镜像库，两者的区别在于：
- 容器快照文件仅保存容器当时的`快照状态`，而镜像存储文件保存了所有的历史记录和`元数据信息`。
- 从容器快照文件导入时，可以重新指定标签等元数据信息。

## 查看容器
### 查看容器详情
查看容器详情可以使用 **docker inspect** 命令，会以 JSON 格式返回包括容器 ID、创建时间、路径、状态、镜像、配置等在内的各项信息。
```
$ docker inspect test
```
### 查看容器内进程
查看容器内进程可以使用 **docker top** 命令，会打印出包括 PID、用户、时间、命令等进程信息。
```
$ docker top test
```
### 查看统计信息
查看统计信息可以使用 **docker stats** 命令，会显示 CPU、内存、存储、网络等使用情况的统计信息。
```
$ docker stats
```
## 其他容器命令
### 复制文件
**docker cp** 命令支持在容器和主机时间复制文件：
```
$ docker cp data test:/tmp/
```
### 查看变更
**docker diff** 命令查看容器内文件系统的变更：
```
$ docker diff test
```
### 查看端口映射
**docker port** 命令可以查看容器的端口映射情况：
```
$ docker port test
```
### 更新配置
**docker update** 命令可以更新容器的一些运行时配置，例如，限制总配额为 1 秒，容器 test 所占用时间为 10%：
```
$ docker update --cpu-quota 1000000 test
$ docker update --cpu-period 100000 test
```
在生产环境中，提高容器的高可用性和安全性：
- 合理使用`资源限制参数`，来管理容器的资源消耗。
- 指定合适的`容器重启策略`，来自动重启退出的容器。
- 使用 HAProxy 等辅助工具来`处理负载均衡`，自动切换故障的应用容器。
