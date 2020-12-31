---
title: Proxy Design Pattern
date: 2020-12-02 00:56:30
tags:
  - GoF
---
## 代理模式的原理解析
`代理模式`（Proxy Design Pattern）的原理和代码实现都不难掌握。它在不改变原始类（或叫被代理类）代码的情况下，通过**引入代理类来给原始类附加功能**。

我们开发了一个性能计数器 -- MetricsCollector 类，在业务系统中，我们采用如下方式来使用这个 MetricsCollector 类：
```java
public class UserController
{
    //...省略其他属性和方法...
    private MetricsCollector metricsCollector; // 依赖注入

    public UserVo login(String telephone, String password) 
    {
        long startTimestamp = System.currentTimeMillis();

        //...省略 login 逻辑...

        long endTimeStamp = System.currentTimeMillis();
        long responseTime = endTimeStamp - startTimestamp;
        RequestInfo requestInfo = new RequestInfo("login", responseTime, startTimestamp);
        metricsCollector.recordRequest(requestInfo);

        //...返回 UserVo 数据...
    }

    public UserVo register(String telephone, String password) 
    {
        long startTimestamp = System.currentTimeMillis();

        //...省略 register 逻辑...

        long endTimeStamp = System.currentTimeMillis();
        long responseTime = endTimeStamp - startTimestamp;
        RequestInfo requestInfo = new RequestInfo("register", responseTime, startTimestamp);
        metricsCollector.recordRequest(requestInfo);

        //...返回 UserVo 数据...
    }
}
```
<!--more-->

上面的写法有两个问题：
1. 性能计数器框架代码侵入到业务代码中，跟业务代码高度耦合。如果未来需要替换这个框架，那替换的成本会比较大；
2. 收集接口请求的代码跟业务代码无关，本就不应该放到一个类中。业务类最好职责更加单一，只聚焦业务处理；

为了**将框架代码和业务代码解耦**，代理模式就派上用场了。代理类 UserControllerProxy 和原始类 UserController 实现相同的接口 IUserController。UserController 类只负责业务功能。代理类 UserControllerProxy 负责在业务代码执行前后附加其他逻辑代码，并通过`委托`的方式调用原始类来执行业务代码。具体的代码实现如下所示：
```java
public interface IUserController 
{
    UserVo login(String telephone, String password);
    UserVo register(String telephone, String password);
}

public class UserController implements IUserController 
{
    //...省略其他属性和方法...

    @Override
    public UserVo login(String telephone, String password) 
    {
        //...省略 login 逻辑...
        //...返回 UserVo 数据...
    }

    @Override
    public UserVo register(String telephone, String password) 
    {
        //...省略 register 逻辑...
        //...返回 UserVo 数据...
    }
}

public class UserControllerProxy implements IUserController 
{
    private MetricsCollector metricsCollector;
    private UserController userController;

    public UserControllerProxy(UserController userController) 
    {
        this.userController = userController;
        this.metricsCollector = new MetricsCollector();
    }

    @Override
    public UserVo login(String telephone, String password) 
    {
        long startTimestamp = System.currentTimeMillis();

        // 委托
        UserVo userVo = userController.login(telephone, password);

        long endTimeStamp = System.currentTimeMillis();
        long responseTime = endTimeStamp - startTimestamp;
        RequestInfo requestInfo = new RequestInfo("login", responseTime, startTimestamp);
        metricsCollector.recordRequest(requestInfo);

        return userVo;
    }

    @Override
    public UserVo register(String telephone, String password) 
    {
        long startTimestamp = System.currentTimeMillis();

        // 委托
        UserVo userVo = userController.register(telephone, password);

        long endTimeStamp = System.currentTimeMillis();
        long responseTime = endTimeStamp - startTimestamp;
        RequestInfo requestInfo = new RequestInfo("register", responseTime, startTimestamp);
        metricsCollector.recordRequest(requestInfo);

        return userVo;
    }
}

// UserControllerProxy 使用举例
// 因为原始类和代理类实现相同的接口，是基于接口而非实现编程
// 将 UserController 类对象替换为 UserControllerProxy 类对象，不需要改动太多代码
IUserController userController = new UserControllerProxy(new UserController());
```

但是，如果**原始类并没有定义接口，并且原始类代码并不是我们开发维护的**（比如它来自一个第三方的类库），我们也没办法直接修改原始类，给它重新定义一个接口。对于这种外部类的扩展，我们一般都是采用`继承`的方式。这里也不例外。我们让代理类继承原始类，然后扩展附加功能。具体代码如下所示：
```java
public class UserControllerProxy extends UserController 
{
    private MetricsCollector metricsCollector;

    public UserControllerProxy() 
    {
        this.metricsCollector = new MetricsCollector();
    }

    public UserVo login(String telephone, String password) 
    {
        long startTimestamp = System.currentTimeMillis();

        UserVo userVo = super.login(telephone, password);

        long endTimeStamp = System.currentTimeMillis();
        long responseTime = endTimeStamp - startTimestamp;
        RequestInfo requestInfo = new RequestInfo("login", responseTime, startTimestamp);
        metricsCollector.recordRequest(requestInfo);

        return userVo;
    }

    public UserVo register(String telephone, String password) 
    {
        long startTimestamp = System.currentTimeMillis();

        UserVo userVo = super.register(telephone, password);

        long endTimeStamp = System.currentTimeMillis();
        long responseTime = endTimeStamp - startTimestamp;
        RequestInfo requestInfo = new RequestInfo("register", responseTime, startTimestamp);
        metricsCollector.recordRequest(requestInfo);

        return userVo;
    }
}
// UserControllerProxy 使用举例
UserController userController = new UserControllerProxy();
```

## 动态代理的原理解析
刚刚的代码实现还是有点问题：
- 我们需要在代理类中，将原始类中的所有的方法，都重新实现一遍，并且为每个方法都附加相似的代码逻辑；
- 如果要添加的附加功能的类有不止一个，我们需要针对每个类都创建一个代理类；

我们可以使用动态代理来解决这个问题。所谓`动态代理`（Dynamic Proxy），就是我们不事先为每个原始类编写代理类，而是**在运行的时候，动态地创建原始类对应的代理类**，然后在系统中用代理类替换掉原始类。如果你熟悉的是 Java 语言，实现动态代理就是件很简单的事情。因为 Java 语言本身就已经提供了动态代理的语法（实际上，动态代理底层依赖的就是 Java 的`反射语法`）。其中，MetricsCollectorProxy 作为一个动态代理类，动态地给每个需要收集接口请求信息的类创建代理类：
```java
public class MetricsCollectorProxy 
{
    private MetricsCollector metricsCollector;

    public MetricsCollectorProxy() 
    {
        this.metricsCollector = new MetricsCollector();
    }

    public Object createProxy(Object proxyObject) 
    {
        Class<?>[] interfaces = proxyObject.getClass().getInterfaces();
        DynamicProxyHandler handler = new DynamicProxyHandler(proxyObject);
        return Proxy.newProxyInstance(proxyObject.getClass().getClassLoader(), interfaces, handler);
    }

    private class DynamicProxyHandler implements InvocationHandler
    {
        private Object proxyObject;

        public DynamicProxyHandler(Object proxyObject) 
        {
            this.proxyObject = proxyObject;
        }

        @Override
        public Object invoke(Object proxy, Method method, Object[] args) throws Throwable 
        {
            long startTimestamp = System.currentTimeMillis();
            Object result = method.invoke(proxyObject, args);
            long endTimeStamp = System.currentTimeMillis();
            long responseTime = endTimeStamp - startTimestamp;
            String apiName = proxyObject.getClass().getName() + ":" + method.getName();
            RequestInfo requestInfo = new RequestInfo(apiName, responseTime, startTimestamp);
            metricsCollector.recordRequest(requestInfo);
            return result;
        }
    }
}

// MetricsCollectorProxy 使用举例
MetricsCollectorProxy proxy = new MetricsCollectorProxy();
IUserController userController = (IUserController) proxy.createProxy(new UserController());
```

实际上，**Spring AOP 底层的实现原理就是基于动态代理**。用户配置好需要给哪些类创建代理，并定义好在执行原始类的业务代码前后执行哪些附加功能。Spring 为这些类创建动态代理对象，并在 JVM 中替代原始类对象。**原本在代码中执行的原始类的方法，被换作执行代理类的方法**，也就实现了给原始类添加附加功能的目的。

## 代理模式的应用场景
代理模式的应用场景非常多，我这里列举一些比较常见的用法。

### 业务系统的非功能性需求开发
代理模式最常用的一个应用场景就是，在业务系统中开发一些非功能性需求，比如：监控、统计、鉴权、限流、事务、幂等、日志。我们**将这些附加功能与业务功能解耦，放到代理类中统一处理**，让程序员只需要关注业务方面的开发。

### 代理模式在 RPC、缓存中的应用
实际上，**RPC 框架也可以看作一种代理模式**。客户端在使用 RPC 服务的时候，就像使用本地函数一样，无需了解跟服务器交互的细节。除此之外，RPC 服务的开发者也只需要开发业务逻辑，就像开发本地使用的函数一样，不需要关注跟客户端的交互细节。

我们再来看代理模式在缓存中的应用。假设我们要开发一个接口请求的缓存功能，对于某些接口请求，如果入参相同，在设定的过期时间内，直接返回缓存结果，而不用重新进行逻辑处理。比如，针对获取用户个人信息的需求，我们可以**开发两个接口，一个支持缓存，一个支持实时查询**。对于需要实时数据的需求，我们让其调用实时查询接口，对于不需要实时数据的需求，我们让其调用支持缓存的接口。
