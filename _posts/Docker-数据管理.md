---
title: Docker 数据管理
date: 2019-06-22 18:03:26
tags:
  - Docker
---
在生产环境中使用 Docker，往往需要对数据进行`持久化`，或者需要在多个容器之间进行`数据共享`，这必然涉及容器的数据管理操作。
容器中管理数据主要有两种方式：
- 数据卷（Data Volumes）：宿主机目录直接映射进容器。
- 数据卷容器（Data Volumes Containers）：使用特定容器维护数据卷。

通过这些机制，即使容器在运行中出现故障，用户也不必担心数据发生丢失，只需要快速的重新创建容器即可。
## 数据卷
**数据卷**是一个可供容器使用的特殊目录，类似于 Linux 中的 `mount` 行为。
> 对数据卷的更新不会影响镜像，解耦开应用和数据。

<!--more-->
### 创建数据卷
Docker 提供了 `volume` 子命令来管理数据卷，如下命令可以快速在本地创建一个数据卷：
```
$ docker volume create -d local test
```
查看创建的数据卷的位置：
```
$ ls -l /var/lib/docker/volumes
```
除了 create 外，**docker volume** 还支持 inspect、ls、prune、rm 等。
### 绑定数据卷
可以在创建容器时将主机本地的任意路径挂载到容器内作为数据卷，这种形式创建的数据卷称为**绑定数据卷**。
在用 docker run 命令的时候，使用 **--mount** 选项，支持三种类型的数据卷：
- volume：普通数据卷，映射到主机 `/var/lib/docker/volumes` 路径下。
- bind：绑定数据卷，映射到主机`指定路径`下。
- tmpfs：临时数据卷，只存在于`内存`中。

下面使用 /training/webapp 镜像创建一个 Web 容器，并创建一个数据卷挂载到容器的 /opt/webapp 目录：
```
$ docker run -d -P --name web --mount type=bind, source=/webapp, destination=/opt/webapp training/webapp python app.py
```
这个功能在进行`应用测试`的时候十分方便，本地目录的路径必须是绝对路径，容器内路径可以为相对路径。
> 推荐的方式是：直接挂载文件所在的`目录`到容器。

## 数据卷容器
创建一个数据卷容器 dbdata，并在其中创建一个数据卷挂载到 /dbdata：
```
$ docker run -it -v /dbdata --name dbdata ubuntu
```
可以在其他容器中使用 `--volumes-from` 来挂载 dbdata 容器中的数据卷：
```
$ docker run -it --volumes-from dbdata --name db1 ubuntu
$ docker run -it --volumes-from dbdata --name db2 ubuntu
```
三个容器任何一方在该目录下的写入，其他容器都可以看到；可以多次使用 --volumes-from 参数来从多个容器挂载多个数据卷，还可以从其他已经挂载了数据卷的容器来挂载数据卷。
> 使用 --volumes-from 参数所挂载数据卷的容器自身，并不需要保持在运行状态。

要删除一个数据卷，必须在删除最后一个还挂载着它的容器时，显示使用 docker rm -v 命令来指定同时删除关联的数据卷。
## 利用数据卷容器来迁移数据
可以利用数据卷容器对其中的数据**进行备份、恢复，以实现数据的迁移**。
### 备份
使用下面的命令来备份 `dbdata` 数据卷容器内的数据卷：
```
$ docker run --rm --volumes-from dbdata -v $(pwd):/backup busybox tar cvf /backup/backup.tar /dbdata
```
### 恢复
首先创建一个带有数据卷的容器 `dbdata2`：
```
$ docker run -v /dbdata --name dbdata2 ubuntu /bin/bash
```
然后创建另一个临时容器，挂载 dbdata2 的数据卷，并解压备份文件到挂载的数据卷中：
```
$ docker run --rm --volumes-from dbdata2 -v $(pwd):/backup busybox tar xvf /backup/backup.tar
```
通过这些机制，即使容器在运行中出现故障，用户也不必担心数据发生丢失，只需要快速的重新创建容器即可。
在生产环境中，除了使用数据卷外：
- 定期将主机的本地数据进行备份
- 使用支持容错的存储系统，包括 RAID 或分布式文件系统，如 Ceph、GPFS、HDFS 等。
