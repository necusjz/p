---
title: Proxies
date: 2021-02-04 20:12:13
tags:
  - SystemDesign
---
A `Proxy Server` is an intermediate server between the client and the back-end server. Clients connect to proxy servers to make a request for a service like a web page, file, connection, etc. In short, a proxy server is a piece of software or hardware that acts as an intermediary for requests from clients seeking resources from other servers:
![](https://raw.githubusercontent.com/snlndod/mPOST/master/SystemDesign/educative/05.png)

Typically, proxies are used to filter requests, log requests, or sometimes transform requests (by adding/removing headers, encrypting/decrypting, or compressing a resource). Another advantage of a proxy server is that its cache can serve a lot of requests. If multiple clients access a particular resource, the proxy server can cache it and serve it to all the clients without going to the remote server.
<!--more-->

## Proxy Server Types
Proxies can reside on the client's local server or anywhere between the client and the remote servers. Here are a few famous types of proxy servers:
- **Open Proxy**: An open proxy is a proxy server that is accessible by any Internet user. Generally, a proxy server only allows users within a network group (i.e., a closed proxy) to store and forward Internet services such as DNS or web pages to reduce and control the bandwidth used by the group. With an open proxy, however, any user on the Internet is able to use this forwarding service. There two famous open proxy types:
    1. **Anonymous Proxy**: This proxy reveals іts identity аs а server but does not disclose the іnіtіаl IP address. Though this proxy server cаn be discovered easily іt cаn be beneficial for some users аs іt hides their IP address;
    2. **Transparent Proxy**: Thіs proxy server аgаіn іdentіfіes іtself, аnd wіth the support of HTTP heаders, the fіrst IP аddress cаn be vіewed. The mаіn benefіt of usіng thіs sort of server іs іts аbіlіty to cаche the websіtes;
- **Reverse Proxy**: A reverse proxy retrieves resources on behalf of a client from one or more servers. These resources are then returned to the client, appearing as if they originated from the proxy server itself;
