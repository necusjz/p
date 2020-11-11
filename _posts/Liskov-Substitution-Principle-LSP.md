---
title: Liskov Substitution Principle (LSP)
date: 2020-09-28 00:39:47
tags:
  - GoF
---
## 如何理解 LSP
里式替换原则的英文翻译是：Liskov Substitution Principle，缩写为 LSP。这个原则最早是在 1986 年由 Barbara Liskov 提出，他是这么描述这条原则的：
> If S is a subtype of T, then objects of type T may be replaced with objects of type S, without breaking the program.

在 1996 年，Robert Martin 在他的 SOLID 原则中，重新描述了这个原则，英文原话是这样的：
> Functions that use pointers of references to base classes must be able to use objects of derived classes without knowing it.

我们综合两者的描述，将这条原则用中文描述出来，是这样的：**子类对象能够替换程序中父类对象出现的任何地方，并且保证原来程序的逻辑行为（behavior）不变及正确性不被破坏**。

这么说还是比较抽象，我们通过一个例子来解释一下。如下代码中，父类 Transporter 使用 org.apache.http 库中的 HttpClient 类来传输网络数据。子类 SecurityTransporter 继承父类 Transporter，增加了额外的功能，支持传输 appId 和 appToken 安全认证信息：
<!--more-->
```
public class Transporter 
{
    private HttpClient httpClient;
    
    public Transporter(HttpClient httpClient) 
    {
        this.httpClient = httpClient;
    }

    public Response sendRequest(Request request) 
    {
        //...use httpClient to send request
    }
}

public class SecurityTransporter extends Transporter 
{
    private String appId;
    private String appToken;

    public SecurityTransporter(HttpClient httpClient, String appId, String appToken) 
    {
        super(httpClient);
        this.appId = appId;
        this.appToken = appToken;
    }

    @Override
    public Response sendRequest(Request request) 
    {
        if (StringUtils.isNotBlank(appId) && StringUtils.isNotBlank(appToken)) 
        {
            request.addPayload("app-id", appId);
            request.addPayload("app-token", appToken);
        }
        return super.sendRequest(request);
    }
}

public class Demo 
{    
    public void demoFunction(Transporter transporter) 
    {    
        Request request = new Request();
        //...省略设置request中数据值的代码...
        Response response = transporter.sendRequest(request);
        //...省略其他逻辑...
    }
}

// 里式替换原则
Demo demo = new Demo();
demo.demoFunction(new SecurityTransporter(/*省略参数*/););
```

在上面的代码中，子类 SecurityTransporter 的设计完全符合里式替换原则，**可以替换父类出现的任何位置，并且原来代码的逻辑行为不变且正确性也没有被破坏**。

虽然从定义描述和代码实现上来看，多态和里式替换有点类似，但它们关注的角度是不一样的。**多态是面向对象编程的一大特性**，也是面向对象编程语言的一种语法。它是一种代码实现的思路。而**里式替换是一种设计原则**，是用来指导继承关系中子类该如何设计的，子类的设计要保证在替换父类的时候，不改变原有程序的逻辑以及不破坏原有程序的正确性。

## 哪些代码明显违背了 LSP
实际上，里式替换原则还有另外一个更加能落地、更有指导意义的描述，那就是 ``Design By Contract``，中文翻译就是：**按照协议来设计**。

看起来比较抽象，我来进一步解读一下。子类在设计的时候，要遵守父类的行为约定（或者叫协议）。父类定义了函数的行为约定，那子类可以改变函数的内部实现逻辑，但不能改变函数原有的行为约定。这里的行为约定包括：函数声明要实现的功能；对输入、输出、异常的约定；甚至包括注释中所罗列的任何特殊说明。实际上，**定义中父类和子类之间的关系，也可以替换成接口和实现类之间的关系**。

### 子类违背父类声明要实现的功能
父类中提供的 sortOrdersByAmount() 订单排序函数，是按照金额从小到大来给订单排序的，而子类重写这个 sortOrdersByAmount() 订单排序函数之后，是按照创建日期来给订单排序的。那子类的设计就违背里式替换原则。

### 子类违背父类对输入、输出、异常的约定
在父类中，某个函数约定，输入数据可以是任意整数，但子类实现的时候，只允许输入数据是正整数，负数就抛出，也就是说，子类对输入的数据的校验比父类更加严格，那子类的设计就违背了里式替换原则。

在父类中，某个函数约定，只会抛出 ArgumentNullException 异常，那子类的设计实现中只允许抛出 ArgumentNullException 异常，任何其他异常的抛出，都会导致子类违背里式替换原则。

### 子类违背父类注释中所罗列的任何特殊说明
父类中定义的 withdraw() 提现函数的注释是这么写的：“用户的提现金额不得超过账户余额...”，而子类重写 withdraw() 函数之后，针对 VIP 账号实现了透支提现的功能，也就是提现金额可以大于账户余额，那这个子类的设计也是不符合里式替换原则的。

以上便是三种典型的违背里式替换原则的情况。除此之外，判断子类的设计实现是否违背里式替换原则，还有一个小窍门，那就是**拿父类的单元测试去验证子类的代码**。如果某些单元测试运行失败，就有可能说明，子类的设计实现没有完全地遵守父类的约定，子类有可能违背了里式替换原则。
