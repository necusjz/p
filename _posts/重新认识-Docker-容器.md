---
title: 重新认识 Docker 容器
date: 2021-05-28 01:16:39
tags:
  - Docker
---
剖析 Linux 容器的核心实现原理：
1. Linux Namespace 的隔离能力；
2. Linux Cgroups 的限制能力；
3. 基于 rootfs 的文件系统；

在开始实践之前，你需要准备一台 Linux 机器，并安装 Docker。这一次，我要用 Docker 部署一个用 Python 编写的 Web 应用。这个应用的代码部分（app.py）非常简单：
```python
from flask import Flask
import socket
import os

app = Flask(__name__)

@app.route('/')
def hello():
    html = "<h3>Hello {name}!</h3>" \
           "<b>Hostname:</b> {hostname}<br/>"           
    return html.format(name=os.getenv("NAME", "world"), hostname=socket.gethostname())
    
if __name__ == "__main__":
    app.run(host='0.0.0.0', port=80)
```
<!--more-->

在这段代码中，我使用 Flask 框架启动了一个 Web 服务器，而它唯一的功能是：如果当前环境中有“NAME”这个环境变量，就把它打印在“Hello”之后，否则就打印“Hello world”，最后再打印出当前环境的 hostname。这个应用的依赖，则被定义在了同目录下的 requirements.txt 文件里，内容如下所示：
```
$ cat requirements.txt
Flask
```

而将这样一个应用**容器化的第一步，是制作容器镜像**。不过，相较于我之前介绍的制作 rootfs 的过程，Docker 为你提供了一种更便捷的方式，叫作 Dockerfile，如下所示：
```dockerfile
# 使用官方提供的Python开发镜像作为基础镜像
FROM python:2.7-slim

# 将工作目录切换为/app
WORKDIR /app

# 将当前目录下的所有内容复制到/app下
ADD . /app

# 使用pip命令安装这个应用所需要的依赖
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# 允许外界访问容器的80端口
EXPOSE 80

# 设置环境变量
ENV NAME World

# 设置容器进程为：python app.py，即：这个Python应用的启动命令
CMD ["python", "app.py"]
```

通过这个文件的内容，你可以看到 Dockerfile 的设计思想，是**使用一些标准的原语（即大写高亮的词语），描述我们所要构建的 Docker 镜像。并且这些原语，都是按顺序处理的**。比如 FROM 原语，指定了“python:2.7-slim”这个官方维护的基础镜像，从而免去了安装 Python 等语言环境的操作。否则，这一段我们就得这么写了：
```dockerfile
FROM ubuntu:latest
RUN apt-get update -yRUN apt-get install -y python-pip python-dev build-essential
```



