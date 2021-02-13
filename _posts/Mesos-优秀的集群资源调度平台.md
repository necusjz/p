---
title: Mesos - 优秀的集群资源调度平台
date: 2019-08-12 21:37:29
tags:
  - Kubernetes
---
Mesos 项目是源自 UC Berkeley 的对集群资源进行抽象和管理的开源项目，类似于操作系统内核，使用它可以很容易地**实现分布式应用的自动化调度**。同时，Mesos 自身也很好地结合和支持了 Docker 等相关容器技术，基于 Mesos 已有的大量应用框架，可以是实现用户应用的快速上线。
## 简介
Mesos 可以将整个数据中心的`资源`（包括 CPU、内存、存储、网络等）进行抽象和调度，使得多个应用同时运行在集群中分享资源，并无须关心资源的物理分布情况。
如果把数据中心的集群资源看作一台服务器，那么 Mesos 要做的事情，其实就是今天操作系统内核的职责：**抽象资源 + 调度任务**；Mesos 拥有许多引人注目的特性，包括：
- 支持数万个节点的**大规模场景**（Apple、Twitter、eBay 等公司使用）；
- 支持多种应用框架，包括 Marathon、Singularity、Aurora 等；
- 支持 `HA`（基于 ZooKeeper 实现）；
- 支持 Docker、LXC 等容器机制进行任务隔离；
- 提供了多个流行语言的 API，包括 Python、Java、C++ 等；
- 自带了简洁易用的 `WebUI`，方便用户直接进行操作。

> Mesos 自身只是一个资源抽象的平台，要使用它往往需要结合运行在其上的分布式应用（`framework`）。

<!--more-->
## Mesos 安装与使用
以 Mesos 结合 Marathon 应用框架为例，来看一下如何快速搭建一套 Mesos 平台。
ZooKeeper 是一个分布式集群中`信息同步的工具`，通过**自动在多个节点中选举 leader**，保障多个节点之间的某些信息保持一致性。
> 一般在生产环境中，需要启动多个 Mesos master 服务（3 个或 5 个），并且使用 Supervisord 等进程管理器来自动保持服务的运行。

### 安装
Mesos 也采用了经典的`主-从结构`，一般包括若干主节点和大量从节点。
安装可以通过**源码编译**、**软件源**、**Docker 方式**进行。
#### 源码编译
可以保证获取到最新版本，但编译过程比较费时间。
常规 C++ 项目的方法，配置之后利用 Makefile 进行编译和安装。
#### 软件源安装
安装相对会省时间，但往往不是最新版本。
可以通过 service 命令来方便进行管理，实际上是通过调用 `/usr/bin/mesos-init-wrapper` 脚本文件进行处理。
#### Docker 方式安装
需要如下三个镜像：ZooKeeper、Mesos、Marathon，其中 `mesos-master` 镜像在后面将分别作为 master 和 slave 角色进行使用。
可以通过访问本地 8080 端口来使用 Marathon 启动服务。
### 配置说明
#### ZooKeeper
ZooKeeper 是一个分布式应用的协调工具，用来**管理多个主节点的选举和冗余**，监听在 `2181` 端口。推荐至少布置三个主节点来被 ZooKeeper 维护。
配置文件默认都在 /etc/zookeeper/conf/ 目录下，比较关键的配置文件有两个：
- **myid**：记录加入 ZooKeeper 集群的节点的序号（1~255）；
- **zoo.cfg**：添加上加入 ZooKeeper 集群的机器的序号和对应的监听地址。

> 可以用主机名形式，需要各个节点 `/etc/hosts` 文件中都记录地址到主机名对应的映射关系。

#### Mesos
Mesos 的默认配置目录有三个：
- **/etc/mesos/**：主节点和从节点都会读取的配置文件，需要在所有节点上修改 /etc/mesos/zk，写入主节点集群的 ZooKeeper 地址列表；
- **/etc/mesos-master**：只有主节点会读取的配置，等价于启动 mesos-master 命令时的默认选项。建议配置至少四个参数文件：ip、quorum、work_dir、cluster；
- **/etc/mesos-slave**：建议在从节点上，创建 ip 文件，在其中写入跟主节点通信的地址。

修改配置之后，启动服务即可生效：
```bash
$ sudo service mesos-master/slave start
```
#### Marathon
Marathon 作为 Mesos 的一个应用框架，配置要更为简单，**必需的配置项有 \-\-master 和 \-\-zk**。
手动创建配置目录，并添加配置项，让 Marathon 能连接到已创建的 Mesos 集群中。
### 访问 Mesos 图形界面
Mesos 自带了 Web 图形界面，可以方便用户查看集群状态。
用户在 Mesos 主节点服务和从节点服务都启动后，可以通过浏览器访问主节点 `5050` 端口，看到如下界面：
![](https://raw.githubusercontent.com/was48i/mPOST/master/Mesos/01.jpg)
### 访问 Marathon 图形界面
Marathon 服务启动后，在 Mesos 的 Web 界面的 Frameworks 标签页下面将能看到名称为 marathon 的框架出现。
同时，可以通过浏览器访问 `8080` 端口，看到 Marathon 自己的管理界面：
![](https://raw.githubusercontent.com/was48i/mPOST/master/Mesos/02.jpg)
## 原理与架构
基于 Mesos，可以比较容易地为各种应用管理框架或者中间件平台，**提供分布式运行能力**；同时多个框架也可以同时运行在一个 Mesos 集群中，**提高整体的资源使用率**。
### 架构
Mesos 的基本架构：
![](https://raw.githubusercontent.com/was48i/mPOST/master/Mesos/03.jpg)
Mesos 采用了经典的主-从架构，其中主节点可以使用 ZooKeeper 来做 HA。
Mesos slave 服务运行在各个计算任务节点上，负责完成具体任务的应用框架，并与 Mesos master 进行交互申请资源。
### 基本单元
Mesos 有三个基本的组件：
- **管理服务（master）**：主节点起到管理作用，将看到全局的信息，负责不同应用框架之间的资源调度和逻辑控制；
- **任务服务（slave）**：负责汇报本从节点上的资源状态给主节点，并负责隔离本地资源来执行主节点分配的具体任务；
- **应用框架（framework）**：应用框架是实际干活的，包括两个主要组件：
    - `调度器`（scheduler）：注册到主节点，等待分配资源；
    - `执行器`（executor）：在从节点上执行框架指定的任务。

应用框架可以分两种：
- 对资源的**需求会扩展**，申请后还可能调整，比如 Hadoop、Spark 等；
- 对资源的**需求将会固定**，一次申请即可，比如 MPI 等。

### 调度
对于一个资源调度框架来说，最核心的就是`调度机制`，如何快速高效地完成对某个应用框架资源的分配，是其核心竞争力所在。
Mesos 为了实现尽量优化的调度，采取了**两层调度算法**。
#### 算法基本过程
master 先全局调度一大块资源给某个 framework，framework 自己再实现内部的细粒度调度，决定哪个任务用多少资源。
调度机制支持插件机制来实现不同的策略，默认是 Dominant Resource Fairness（`DRF`）。
> 两层调度简化了 Mesos master 自身的调度过程，通过将复杂的细粒度调度交由 framework 实现，**避免了 Mesos master 成为性能瓶颈**。

#### 调度过程
基本调度过程如下：
1. slave 节点会周期性汇报自己可用的资源给 master；
2. 某个时候，master 收到应用框架发来的资源请求，根据调度策略，计算出来一个资源 offer 给 framework；
3. framework 收到 offer 后可以决定要不要，如果接受的话，**返回一个描述**，说明自己如何使用和分配这些资源来运行某些任务；
4. master 则根据 framework 答复的具体分配情况发送给 slave，以使 framework 的 executor 按照分配的资源策略执行任务。

#### 过滤器
framework 可以通过`过滤器机制`告诉 master 它的资源偏好。过滤器可以避免某些应用资源长期分配不到所需要的资源的情况，**加速整个资源分配的交互过程**。
#### 回收机制
为了避免某些任务长期占用集群中资源，Mesos 也支持`回收机制`。主节点可以定期回收计算节点上的任务所占用的资源，**动态调整长期任务和短期任务的分布**。
### 高可用性
除了使用 ZooKeeper 来解决单点失效问题之外，Mesos 的 master 节点自身还提供了很高的鲁棒性。Mesos master 节点再重启后，可以动态通过 slave 和 framework 发来的消息**重建内部状态**，虽然可能导致一定的时延，但这**避免了传统控制节点对数据库的依赖**。
当然，为了减少 master 节点的负载过大，在集群中 slave 节点数目较多的时候，要**避免把各种通知的周期配置得过短**。
> 实践中，可以通过部署多个 Mesos 集群来保持单个集群的规模不要过大。

## Mesos 配置解析
Mesos 的配置项分为三种类型：通用项、master 专属配置项、slave 专属配置项。
### 通用项
通用项数量不多，主要涉及服务绑定地址和日志信息等：
![](https://raw.githubusercontent.com/was48i/mPOST/master/Mesos/04.jpg)
### master 专属配置项
这些配置项是针对主节点上的 Mesos master 服务的，围绕高可用、注册信息、对应用框架的资源管理等。
**必须指定**的配置项有以下三个：
- \-\-quorum=VALUE：利用 ZooKeeper 实现 HA 时，参与投票时的最少节点个数；
- \-\-work_dir=VALUE：注册表持久化信息存储位置；
- \-\-zk=VALUE：指定 ZooKeeper 的服务地址，支持多个地址，之间用逗号隔离。

### slave 专属配置项
**slave 节点支持的配置项是最多的**，因为它所完成的事情也最复杂。这些配置项既包括跟主节点打交道的一些参数，也包括对本地资源的配置，包括隔离机制、本地任务的资源限制等。
必备项就一个：\-\-master=VALUE，master 所在地址，或对应 ZooKeeper 服务地址，或文件路径，可以是列表。
为了避免主机分配的临时端口，跟我们指定的临时端口范围冲突，需要在主机节点上进行配置：
```bash
$ echo "57345 61000" > /proc/sys/net/ipv4/ip_local_port_range
```
> **非临时端口是 Mesos 分配给框架**，绑定到任务使用的，端口号往往有明确的意义；**临时端口是系统分配的**，往往不太关心具体端口号。

## 日志与监控
Mesos 自身提供了强大的日志和监控功能，某些应用框架也提供了针对框架中任务的监控能力。
### 日志配置
日志文件默认在 `/var/log/mesos` 目录下，根据日志等级带有不同后缀。用户可以**通过日志来调试**使用中碰到的问题。
### 监控
Mesos 提供了方便的`监控接口`，供用户查看集群中各个节点的状态：
- **主节点**：通过 http://MASTER_NODE:5050/metrics/snapshot 地址，可以获取到 Mesos 主节点的各种状态统计信息，包括资源使用、系统状态、从节点、应用框架、任务状态等。
- **从节点**：通过 http://SLAVE_NODE:5051/metrics/snapshot 地址，可以获取到 Mesos 从节点的各种状态统计信息，包括资源、系统状态、各种消息状态等。

## 常见应用框架
应用框架是实际干活的，可以理解为 Mesos 之上跑的应用，应用框架**注册到 Mesos master 服务**上即可使用。
Mesos 目前支持的应用框架分为四大类：**长期运行任务**、**大数据处理**、**批量调度**、**数据存储**。
![](https://raw.githubusercontent.com/was48i/mPOST/master/Mesos/05.jpg)
> 结合 Docker，Mesos 可以很容易部署一套私有的容器云，可以很好地应用并集成到生产环境中；但它的定位集中在资源调度，往往需要结合应用框架或二次开发。
