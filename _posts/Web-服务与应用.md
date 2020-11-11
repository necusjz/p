---
title: Web 服务与应用
date: 2019-08-24 21:56:36
tags:
  - Apache
---
Web 服务和应用是目前互联网技术领域的热门技术。重点介绍如何使用 Docker 来运行常见的 Web 服务器（包括 Apache、Nginx、Tomcat 等），以及一些常见应用（包括 `LAMP` 和 `CI/CD`）。
包括 Web 服务在内的**中间件领域十分适合引入容器技术**：
- 中间件服务器是除数据库服务器外的主要计算节点，**很容易成为性能瓶颈**，所以通常需要大批量部署，而 Docker 对于批量部署有着许多先天的优势；
- 中间件服务器结构清晰，在剥离了配置文件、日志、代码目录之后，容器几乎可以**处于零增长状态**，这使得容器的迁移更加方便；
- 中间服务器很容易实现集群，在使用硬件的 F5、软件的 Nginx 等**负载均衡后**，中间件服务器集群变得非常容易。

> 需要注意**数据的持久化**。对于程序代码、资源目录、日志、数据库、文件等需要实时更新和保存的数据，一定要启动数据持久化机制，避免发生数据丢失。
## Apache
Apache 是一个高稳定性的、商业级别的开源 Web 服务器，是目前世界使用排名第一的 **Web 服务器软件**。
![](https://raw.githubusercontent.com/was48i/mPOST/master/Apache/01/01.jpg)
在使用 Dockerfile 创建镜像时，会继承父镜像的开放端口，但却**不会继承启动命令**。因此，需要在 run.sh 脚本中添加启动 sshd 的服务的命令。
<!--more-->
## Nginx
Nginx 是一款功能强大的开源**反向代理服务器**，支持 HTTP、HTTPS、SMTP、POP3、IMAP 等协议。
![](https://raw.githubusercontent.com/was48i/mPOST/master/Apache/01/02.jpg)
特性如下：
- **热部署**：采用 master 管理进程与 worker 工作进程的分离设计，支持热部署；
- **高并发连接**：Nginx 可以轻松支持超过 100K 的并发，理论上支持的并发连接上限取决于机器内存；
- **低内存消耗**：在一般情况下，10K 个非活跃的 HTTP Keep-Alive 连接在 Nginx 中仅消耗 2.5MB 的内存；
- **响应快**：在高峰期，Nginx 可以比其他的 Web 服务器更快地响应请求；
- **高可靠性**：高可靠性来自其核心框架代码的优秀设计和实现。

## Tomcat
Tomcat 由 Apache 软件基金会开发，实现了对 Servlet 和 JSP 的支持。同时，它提供了作为 Web 服务器的**一些特有功能**，如 Tomcat 管理和控制平台、安全域管理和 Tomcat 阀等。
![](https://raw.githubusercontent.com/was48i/mPOST/master/Apache/01/03.jpg)
在实际环境中，可以通过 -v 参数来挂载 Tomcat 的日志文件、程序所在目录，以及相关配置。
## Jetty
Jetty 是一个优秀的开源 **Servlet 容器**，以其高效、小巧、可嵌入式等优点深得人心，它为基于 Java 的 Web 内容提供运行环境。
![](https://raw.githubusercontent.com/was48i/mPOST/master/Apache/01/04.jpg)
与相对老牌的 Tomcat 比，Jetty **架构更合理、性能更优**。尤其在启动速度上，让 Tomcat 望尘莫及，目前在国内外互联网企业中应用广泛。
## LAMP
LAMP 是目前流行的 **Web 工具栈**，其中包括：Linux 操作系统、Apache 网络服务器、MySQL 数据库、PHP 编程语言。
![](https://raw.githubusercontent.com/was48i/mPOST/master/Apache/01/05.jpg)
- 和 Java/J2EE 架构相比，LAMP 具有 Web 资源丰富、轻量、快速开发等特点；
- 和微软的 .NET 架构相比，LAMP 具有通用、跨平台、高性能、低价格的优势。

## 持续开发与管理
持续集成（Continuous Integration，CI）倡导开发团队定期进行集成验证。集成通过自动化的构建来完成，包括自动编译、发布和测试，从而尽快地发现错误。
特点包括：
- **鼓励自动化的周期性的过程**，从检出代码、编译构建、运行测试、结果记录、测试统计等都是自动完成的，减少人工干预；
- **需要有持续集成系统的支持**，包括代码托管机制支持，以及集成服务器等。

持续交付（Continuous Delivery，CD）是经典的敏捷软件开发方法的自然延伸，它强调产品在修改后到部署上线的流程要敏捷化、自动化。甚至一些**较少的改变也要尽早地部署上线**。
### Jenkins
Jenkins 是一个得到广泛应用的 CI/CD 工具。
![](https://raw.githubusercontent.com/was48i/mPOST/master/Apache/01/06.jpg)
作为开源软件项目，它旨在提供一个开放易用的持续集成平台。Jenkins 能实时监控集成中存在的错误，**提供详细的日志文件和提醒功能**，并用图表的形式形象地展示项目构建的趋势和稳定性。
### GitLab
GitLab 是一款非常强大的开源源码管理系统。
![](https://raw.githubusercontent.com/was48i/mPOST/master/Apache/01/07.jpg)
它支持基于 Git 的源码管理、代码评审、Issues 跟踪、活动管理、Wiki 页面、**持续集成和测试等功能**。
