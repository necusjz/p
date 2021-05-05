---
title: 使用 Dockerfile 创建镜像
date: 2019-08-04 17:17:13
tags:
  - Docker
---
Dockerfile 是一个文本格式的配置文件，用户可以使用 Dockerfile 来快速创建自定义的镜像，本文会介绍使用 Dockerfile 的一些**最佳实践**。
## 基本结构
Dockerfile 由一行行命令语句组成，并且支持以 `#` 开头的注释行。主体内容分为四部分：**基础镜像信息**、**维护者信息**、**镜像操作指令**、**容器启动时执行指令**。
下面给出一个简单的示例：
```dockerfile
# escape=\ (backslash)
# This dockerfile uses the ubuntu:xeniel image
# VERSION 2 - EDITION 1
# Author: docker_user
# Command format: Instruction [arguments / command] ..

# Base image to use, this must be set as the first line
FROM ubuntu:xeniel

# Maintainer: docker_user <docker_user at email.com> (@docker_user)
LABEL maintainer docker_user<docker_user@email.com>

# Commands to update the image
RUN echo "deb http://archive.ubuntu.com/ubuntu/ xeniel main universe" >> /etc/apt/sources.list
RUN apt-get update && apt-get install -y nginx
RUN echo "\ndaemon off;" >> /etc/nginx/nginx.conf

# Commands when creating a new container
CMD /usr/sbin/nginx
```
<!--more-->
首行可以通过注释来指定解析器命令，后续通过注释说明镜像的相关信息。主体部分首先使用 `FROM` 指令指明所基于的镜像名称，接下来一般是使用 `LABEL` 指令说明维护者信息。每运行一条 `RUN` 指令，镜像添加新的一层并提交，最后是 `CMD` 指令，来指定运行容器时的操作命令。
## 指令说明
Dockerfile 中指令的一般格式为：INSTRUCTION arguments，包括`配置指令`（配置镜像信息）和`操作指令`（具体执行操作）。
![](https://raw.githubusercontent.com/snlndod/mPOST/master/Docker/8-1.jpg)
### 配置指令
#### ARG
定义创建镜像过程中使用的变量，在执行 docker build 时，可以通过 `-build-arg[=]` 来为变量赋值。当镜像编译成功后，ARG 指定的变量将不再存在（**ENV 指定的变量将在镜像中保留**），一些内置的变量：HTTP_PROXY、HTTPS_PROXY、FTP_PROXY、NO_PROXY 等。
#### FROM
指定所创建镜像的基础镜像，任何 Dockerfile 中**第一条指令**必须为 FROM 指令。为了保证镜像精简，可以选用体积较小的镜像。
#### LABEL
LABEL 指令可以为生成的镜像添加元数据标签信息，用来**辅助过滤出特定的镜像**。
#### EXPOSE
**声明**镜像内服务监听的端口，该指令只是起到声明作用，并不会自动完成端口映射。在启动容器时可以使用 `-P` 参数或 `-p HOST_PORT:CONTAINER_PORT` 参数。
#### ENV
指定环境变量，在镜像生成过程中会被后续 RUN 指令使用，在镜像启动的容器中也会存在。指令指定的环境变量在运行时**可以被覆盖掉**。
#### ENTRYPOINT
指定镜像的默认入口命令，该命令会在启动容器时作为`根命令`执行，所有传入值作为该命令的参数。此时，**CMD 指令**指定值将作为根命令的参数；在运行时，可以被 --entrypoint 参数覆盖掉。
#### VOLUME
创建一个**数据卷挂载点**，运行容器时可以从本地主机或其他容器挂载数据卷，一般用来存放数据库和需要保持的数据等。
#### USER
指定运行容器时的用户名或 UID，后续的 **RUN 等指令**也会使用指定的用户身份。当服务不需要管理员权限时，可以通过该命令指定运行用户，要临时获取管理员权限时可以使用 `gosu` 命令。
#### WORKDIR
为后续的 RUN、CMD、ENTRYPOINT 指令**配置工作目录**，为了避免出错，推荐只使用`绝对路径`。
#### ONBUILD
指定当基于所生成镜像创建子镜像时，**自动执行**的操作指令。
例如，使用如下的 Dockerfile 创建父镜像 ParentImage，指定 ONBUILD 指定：
```dockerfile
# Dockerfile for ParentImage
...
ONBUILD ADD . /app/src
ONBUILD RUN /usr/local/bin/python-build --dir /app/src
...
```
使用 docker build 命令创建子镜像 ChildImage 时，会首先执行 ParentImage 中配置的 ONBUILD 指令：
```dockerfile
# Dockerfile for ChildImage
FROM ParentImage
```
等价于在 ChildImage 的 Dockerfile 中添加如下指令：
```dockerfile
# Automatically run the following when building ChildImage
ADD . /app/src
RUN /usr/local/bin/python-build --dir /app/src
...
```
> ONBUILD 指令在创建专门用于自动编译、检查等操作的基础镜像时，十分有用。

#### STOPSIGNAL
指定所创建镜像启动的容器，**接收退出的信号值**：
```
STOPSIGNAL signal
```
#### HEALTHCHECK
配置所启动容器如何进行**健康检查**，格式有两种：
- HEALTHCHECK [OPTIONS] CMD command：根据所执行命令返回值是否为 0 来判断；
- HEALTHCHECK NONE：禁止基础镜像中的健康检查。

OPTION 支持如下参数：
- -interval=DURATION (default: 30s)：过多久检查一次；
- -timeout=DURATION （default: 30s)：每次检查等待结果的超时；
- -retries=N (default: 3)：如果失败了，重试几次才最终确定失败。

#### SHELL
指定其他命令使用 Shell 时的默认 **Shell 类型**，默认值为：
```
["/bin/sh", "-c"]
```
### 操作指令
#### RUN
运行指定指令，有两种格式：
- RUN command 默认将在 Shell 终端中运行命令，即 /bin/sh -c；
- RUN ["executable", "param1", "param2"]，会被解析为 JSON 数组，因此**必须用双引号**。

每条 RUN 指令将在当前镜像基础上执行指定命令，并提交为新的镜像层。当命令较长时，可以使用`\`换行。
#### CMD
CMD 指令用来指定**启动容器时默认执行的命令**，支持三种格式：
- CMD ["executable", "param1", "param2"]：相当于执行 executable param1 param2，推荐方式；
- CMD command param1 param2：在默认的 Shell 中执行，提供给需要交互的应用；
- CMD ["param1", "param2"]：提供给 ENTRYPOINT 的默认参数。

> 每个 Dockerfile 只能有一条 CMD 命令。如果制定了多条命令，只有最后一条会被执行。

#### ADD
添加内容到镜像，格式为：
```
ADD <src> <dest>
```
该命令将复制指定 `src 路径`下的内容，到容器中的 `dest 路径`下。
#### COPY
复制内容到镜像，格式为：
```
COPY <src> <dest>
```
COPY 与 ADD 指令功能类似，当**本地目录为源目录**时，推荐使用 COPY。
## 创建镜像
编写完成 Dockerfile 之后，可以通过 docker build 命令来创建镜像。该命令将读取指定路径下的 Dockerfile，并**将该路径下所有数据作为 context** 发送给 Docker 服务端。
逐条执行其中定义的指令，碰到 `ADD、COPY、RUN 指令`会生成一层新的镜像，最终如果创建镜像成功，会返回最终镜像的 ID。
例如，上下文路径为：/tmp/docker_builder/，并且希望生成镜像标签为：builder／first_image:1.0.0，可以使用下面的命令：
```
$ docker build -t builder/first_image:1.0.0 /tmp/docker_builder/
```
### 命令选项
docker build 命令支持一系列的选项，可以**调整创建镜像过程的行为**。
### 选择父镜像
大部分情况下，生成新的镜像都需要通过 `FROM 指令`来指定父镜像。父镜像是生成镜像的基础，会直接影响到所生成镜像的大小和功能。
用户可以选择两种镜像作为父镜像：
- **基础镜像**（base image），其 Dockerfile 中往往不存在 FORM 指令，或者基于 scratch 镜像（FROM scratch），这意味着其在整个镜像树中处于根的位置。
- **普通镜像**也可以作为父镜像来使用，包括常见的 busybox、debian、ubuntu 等。

Docker 不同类型镜像之间的继承关系如图：
![](https://raw.githubusercontent.com/snlndod/mPOST/master/Docker/8-2.jpg)
### 使用 .dockerignore 文件
可以通过 .dockerignore 来让 Docker 忽略匹配路径或文件，在创建镜像的时候，**不将无关数据发送到服务端**。
语法支持 Golang 风格的正则格式：
- “*”表示任意多个字符；
- “?”表示单个字符；
- “!”表示不匹配（即不忽略指定的路径或文件）。

### 多步骤创建
Docker 支持多步骤镜像创建（multi-stage build）特性，可以**精简最终生成的镜像大小**。对于需要编译的应用来说，通常情况下至少需要准备两个环境的 Docker 镜像：
- `编译环境镜像`：包括完整的编译引擎、依赖库等，往往比较庞大。作用是编译应用为二进制文件。
- `运行环境镜像`：利用编译好的二进制文件，运行应用，由于不需要编译环境，体积比较小。

使用多步骤创建，可以在保证最终生成的运行环境镜像保持精简的情况下，使用单一的 Dockerfile，**降低维护复杂度**。
## 最佳实践
**从需求出发**，来定制合适自己、高效方便的镜像。
`Docker Hub` 官方仓库中提供了大量的优秀镜像和对应的 Dockerfile，可以通过阅读它们来学习如何撰写高效的 Dockerfile。
尝试从如下角度进行思考，完善所生成的镜像：
- 精简镜像用途；
- **选用合适的基础镜像**：推荐选用瘦身过的应用镜像（node:slim），或者较为小巧的系统镜像（alpine、busybox 或 debian）；
- 提供注释和维护者信息
- **正确使用版本号**：非依赖于默认的 latest，通过版本号可以避免环境不一致导致的问题；
- **减少镜像层数**：尽量合并 RUN、ADD 和 COPY 指令；
- **恰当使用多步骤构建**：通过多步创建，可以将编译和运行等过程分开，保证最终生成的镜像只包括运行应用所需要的`最小化环境`；
- 使用 .dockerignore 文件；
- **及时删除临时文件和缓存文件**：特别是在执行 apt-get 指令后，`/var/cache/apt` 下面会缓存了一些安装包；
- 提高生成速度；
- **调整合理的指令顺序**：在`开启 cache` 的情况下，内容不变的指令尽量放在前面，这样可以尽量复用；
- 减少外部源的干扰。

> 在使用 Dockerfile 构建镜像的过程中，可以体会到 Docker 镜像在使用上“一处修改代替大量更新”的灵活之处。
