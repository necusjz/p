---
title: 访问 Docker 仓库
date: 2019-06-16 23:23:39
tags:
  - Docker
---
**仓库**（Repository）是集中维护容器镜像的地方，为 Docker 镜像文件的`分发和管理`提供了便捷的途径，又分为公共仓库和私有仓库。
**注册服务器**（Registry）是存放仓库的具体服务器，一个注册服务器可以有多个仓库，而每个仓库下面可以有多个镜像。
仓库可以被认为是一个具体的`项目或目录`，例如对于仓库地址 `private-docker.com/ubuntu` 来说，`private-docker.com` 是注册服务器地址，`ubuntu` 是仓库名。
## Docker Hub 公共镜像市场
Docker Hub 是 Docker 官方提供的最大的公共镜像仓库，目前包括了超过 100, 000 的镜像，地址为 `https://hub.docker.com`。
### 登陆
可以执行 **docker login** 命令进行登录，登录成功的用户可以 push 个人制作的镜像到 Docker Hub。
<!--more-->
### 基本操作
用户无须登录即可通过 docker search 命令来查找官方仓库中的镜像，并利用 docker pull 命令来将他下载到本地。
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/Docker/5-1.jpeg)
根据是否为官方提供，可将这些镜像资源分为两类：
- 类似于 centos 这样的基础镜像（根镜像），由 Docker 公司创建、验证、支持、提供，这样的镜像往往使用`单个单词`作为名字。
- 带有用户名称为`前缀`，表明是某用户下的某仓库。可以通过“user_name/镜像名”，来指定使用某个用户提供的镜像。

### 自动创建
`自动创建`（Automated Builds）是 Docker Hub 提供的自动化服务。允许用户通过 Docker Hub 指定跟踪一个目标网站（GitHub、BitBucket）上的项目，一旦项目发生新的提交，则自动执行创建。
## 第三方镜像市场
国内不少云服务商都提供了 Docker 镜像市场，包括腾讯云、网易云、阿里云等。
### 查看镜像
访问 `https://hub.tenxcloud.com`，即可看到已存在的仓库和存储的镜像。
### 下载镜像
要在镜像名称前添加注册服务器的具体地址，格式为：`index.tenxcloud.com/<namespace>/<repository>:<tag>`：
```
$ docker pull index.tenxcloud.com/docker_library/node:latest
```
下载后，可以更新镜像的标签，与官方标签保持一致，方便使用：
```
$ docker tag index.tenxcloud.com/docker_library/node:latest node:latest
```
## 搭建本地私有仓库
### 使用 registry 镜像创建私有仓库
可以通过官方提供的 registry 镜像，来简单搭建一套本地私有仓库环境：
```
$ docker run -d -p 5000:5000 registry:2
```
默认情况下，仓库会被创建在容器的 `/var/lib/registry` 目录下。
> 还可以使用其他的开源方案（如 nexus），来搭建私有化的容器镜像仓库。

### 管理私有仓库
在企业的生产环境中，往往需要使用私有仓库来维护内部镜像。
出于安全性的考虑，会要求仓库支持 SSL/TLS 证书。对于内部使用的私有仓库，可以`自行配置证书`或`关闭安全性检查`。
修改 Docker Daemon 的启动参数（`/etc/default/docker`），添加如下参数，不进行安全证书检查：
```
DOCKER_OPTS="--insecure-registry 10.0.2.2:5000"
```
之后再重启 Docker 服务：
```
$ sudo service docker restart
```
如果要使用安全证书，用户也可以从较知名的 CA 服务商（如 verisign）申请公开的 SSL/TLS 证书，或者使用 OpenSSL 等软件来自行生成。
