---
title: 抽象类 vs. 接口
date: 2020-08-29 23:00:12
tags:
  - GoF
---
在面向对象编程中，抽象类和接口是两个经常被用到的语法概念，是面向对象四大特性，以及很多设计模式、设计思想、设计原则编程实现的基础。比如，我们可以**使用抽象类来实现面向对象的继承特性和模版设计模式，使用接口来实现面向对象的抽象特性、多态特性和基于接口而非实现的设计原则**。

不过，并不是所有的面向对象编程语言都支持这两个语法概念，比如，C++ 这种编程语言只支持抽象类，不支持接口；而像 Python 这样的动态编程语言，既不支持抽象类，也不支持接口。尽管有些编程语言没有提供现成的语法来支持接口和抽象类，我们仍然可以**通过一些手段来模拟实现这两个语法概念**。

## 什么是抽象类和接口
Java 这种编程语言，既支持抽象类，也支持接口，所以，为了让你对这两个语法概念有比较直观的认识，我们拿 Java 这种编程语言来举例讲解。
### 抽象类
下面这段代码是一个比较典型的抽象类的使用场景（`模板设计模式`）。Logger 是一个记录日志的抽象类，FileLogger 和 MessageQueueLogger 继承 Logger，分别实现两种不同的日志记录方式：记录日志到文件中和记录日志到消息队列中。FileLogger 和 MessageQueueLogger 两个子类复用了父类 Logger 中的 name、enabled、minPermittedLevel 属性和 log() 方法，但因为这两个子类写日志的方式不同，它们又各自重写了父类中的 doLog() 方法：
<!--more-->
```java
// 抽象类
public abstract class Logger 
{
    private String name;
    private boolean enabled;
    private Level minPermittedLevel;

    public Logger(String name, boolean enabled, Level minPermittedLevel) 
    {
        this.name = name;
        this.enabled = enabled;
        this.minPermittedLevel = minPermittedLevel;
    }
    
    public void log(Level level, String message) 
    {
        boolean loggable = enabled && (minPermittedLevel.intValue() <= level.intValue());
        if (!loggable) return;
        doLog(level, message);
    }
    
    protected abstract void doLog(Level level, String message);
}
// 抽象类的子类: 输出日志到文件
public class FileLogger extends Logger 
{
    private Writer fileWriter;

    public FileLogger(String name, boolean enabled, Level minPermittedLevel, String filepath) 
    {
        super(name, enabled, minPermittedLevel);
        this.fileWriter = new FileWriter(filepath); 
    }
    
    @Override
    public void doLog(Level level, String message) 
    {
        // 格式化level和message, 输出到日志文件
        fileWriter.write(...);
    }
}
// 抽象类的子类: 输出日志到消息中间件(比如kafka)
public class MessageQueueLogger extends Logger 
{
    private MessageQueueClient msgQueueClient;
    
    public MessageQueueLogger(String name, boolean enabled, Level minPermittedLevel, MessageQueueClient msgQueueClient) 
    {
        super(name, enabled, minPermittedLevel);
        this.msgQueueClient = msgQueueClient;
    }
    
    @Override
    protected void doLog(Level level, String message) 
    {
        // 格式化level和message, 输出到消息中间件
        msgQueueClient.send(...);
    }
}
```

通过上面的这个例子，我们来看一下，抽象类具有哪些特性。我总结了下面三点：
- **抽象类不允许被实例化，只能被继承**。也就是说，你不能 new 一个抽象类的对象出来（Logger logger = new Logger(...); 会报编译错误）；
- **抽象类可以包含属性和方法**。方法既可以包含代码实现（比如 Logger 中的 log() 方法），也可以不包含代码实现（比如 Logger 中的 doLog() 方法）。不包含代码实现的方法叫作`抽象方法`；
- **子类继承抽象类，必须实现抽象类中的所有抽象方法**。对应到例子代码中就是，所有继承 Logger 抽象类的子类，都必须重写 doLog() 方法；

### 接口
```java
// 接口
public interface Filter 
{
    void doFilter(RpcRequest req) throws RpcException;
}
// 接口实现类：鉴权过滤器
public class AuthenticationFilter implements Filter 
{
    @Override
    public void doFilter(RpcRequest req) throws RpcException 
    {
        //...鉴权逻辑..
    }
}
// 接口实现类：限流过滤器
public class RateLimitFilter implements Filter 
{
    @Override
    public void doFilter(RpcRequest req) throws RpcException 
    {
        //...限流逻辑...
    }
}
// 过滤器使用demo
public class Application 
{
    // filters.add(new AuthenticationFilter());
    // filters.add(new RateLimitFilter());
    private List<Filter> filters = new ArrayList<>();
    
    public void handleRpcRequest(RpcRequest req) 
    {
        try 
        {
            for (Filter filter : filters) 
            {
                filter.doFilter(req);
            }
        } 
        catch(RpcException e) 
        {
            //...处理过滤结果...
        }
        //...省略其他处理逻辑...
    }
}
```

上面这段代码是一个比较典型的接口的使用场景。我们通过 Java 中的 interface 关键字定义了一个 Filter 接口。AuthenticationFilter 和 RateLimitFilter 是接口的两个实现类，分别实现了对 RPC 请求鉴权和限流的过滤功能。

代码非常简洁。结合代码，我们再来看一下，接口都有哪些特性。我也总结了三点：
- 接口**不能包含属性**（也就是成员变量）；
- 接口**只能声明方法**，方法不能包含代码实现；
- 类实现接口的时候，**必须实现接口中声明的所有方法**；

从语法特性上对比，这两者有比较大的区别，比如抽象类中可以定义属性、方法的实现，而接口中不能定义属性，方法也不能包含代码实现等等。**除了语法特性，从设计的角度，两者也有比较大的区别**。抽象类实际上就是类，只不过是一种特殊的类，这种类不能被实例化为对象，只能被子类继承。我们知道，继承关系是一种 is-a 的关系，那抽象类既然属于类，也表示一种 is-a 的关系。**相对于抽象类的 is-a 关系来说，接口表示一种 has-a 关系**，表示具有某些功能。对于接口，有一个更加形象的叫法，那就是`协议（contract）`。

## 能解决什么编程问题
刚刚我们学习了抽象类和接口的定义和区别，现在我们再来学习一下，抽象类和接口存在的意义，让你知其然知其所以然。

### 抽象类
刚刚我们讲到，抽象类不能实例化，只能被继承。而前面的章节中，我们还讲到，继承能解决代码复用的问题。所以，抽象类也是为代码复用而生的。**多个子类可以继承抽象类中定义的属性和方法，避免在子类中，重复编写相同的代码**。

不过，既然继承本身就能达到代码复用的目的，而继承也并不要求父类一定是抽象类，那我们不使用抽象类，照样也可以实现继承和复用。从这个角度上来讲，我们貌似并不需要抽象类这种语法呀。那**抽象类除了解决代码复用的问题，还有什么其他存在的意义吗？**

我们还是拿之前那个打印日志的例子来讲解。我们先对上面的代码做下改造。在改造之后的代码中，Logger 不再是抽象类，只是一个普通的父类，删除了 Logger 中 log()、doLog() 方法，新增了 isLoggable() 方法。FileLogger 和 MessageQueueLogger 还是继承 Logger 父类，以达到代码复用的目的。具体的代码如下：
```java
// 父类: 非抽象类, 就是普通的类. 删除了log(), doLog(), 新增了isLoggable()
public class Logger 
{
    private String name;
    private boolean enabled;
    private Level minPermittedLevel;

    public Logger(String name, boolean enabled, Level minPermittedLevel) 
    {
        //...构造函数不变，代码省略...
    }

    protected boolean isLoggable() 
    {
        boolean loggable = enabled && (minPermittedLevel.intValue() <= level.intValue());
        return loggable;
    }
}
// 子类：输出日志到文件
public class FileLogger extends Logger 
{
    private Writer fileWriter;

    public FileLogger(String name, boolean enabled, Level minPermittedLevel, String filepath) 
    {
        //...构造函数不变，代码省略...
    }
  
    public void log(Level level, String message) 
    {
        if (!isLoggable()) return;
        // 格式化 level 和 message，输出到日志文件
        fileWriter.write(...);
    }
}
// 子类: 输出日志到消息中间件(比如 kafka)
public class MessageQueueLogger extends Logger 
{
    private MessageQueueClient msgQueueClient;
    
    public MessageQueueLogger(String name, boolean enabled, Level minPermittedLevel, MessageQueueClient msgQueueClient) 
    {
        //...构造函数不变，代码省略...
    }
    
    public void log(Level level, String message) 
    {
        if (!isLoggable()) return;
        // 格式化 level 和 message，输出到消息中间件
        msgQueueClient.send(...);
    }
}
```

这个设计思路虽然达到了代码复用的目的，但是**无法使用多态特性**了。像下面这样编写代码，就会出现编译错误，因为 Logger 中并没有定义 log() 方法：
```java
Logger logger = new FileLogger("access-log", true, Level.WARN, "/users/wangzheng/access.log");
logger.log(Level.ERROR, "This is a test log message.");
```

你可能会说，这个问题解决起来很简单啊。我们在 Logger 父类中，定义一个空的 log() 方法，让子类重写父类的 log() 方法，实现自己的记录日志的逻辑，不就可以了吗？这个设计思路能用，但是，它显然没有之前通过抽象类的实现思路优雅。我为什么这么说呢？主要有以下几点原因：
- 在 Logger 中定义一个空的方法，**会影响代码的可读性**。如果我们不熟悉 Logger 背后的设计思想，代码注释又不怎么给力，我们在阅读 Logger 代码的时候，就可能对为什么定义一个空的 log() 方法而感到疑惑，需要查看 Logger、FileLogger、MessageQueueLogger 之间的继承关系，才能弄明白其设计意图；
- 当创建一个新的子类继承 Logger 父类的时候，我们**有可能会忘记重新实现 log() 方法**。之前基于抽象类的设计思路，编译器会强制要求子类重写 log() 方法，否则会报编译错误。你可能会说，我既然要定义一个新的 Logger 子类，怎么会忘记重新实现 log() 方法呢？我们举的例子比较简单，Logger 中的方法不多，代码行数也很少。但是，如果 Logger 有几百行，有 n 多方法，除非你对 Logger 的设计非常熟悉，否则忘记重新实现 log() 方法，也不是不可能的；
- Logger 可以被实例化，换句话说，我们可以 new 一个 Logger 出来，并且调用空的 log() 方法。这也增加了类被误用的风险。当然，这个问题**可以通过设置私有的构造函数的方式来解决。不过，显然没有通过抽象类来的优雅**；

### 接口
**抽象类更多的是为了代码复用，而接口就更侧重于解耦**。接口是对行为的一种抽象，相当于一组协议或者契约，你可以联想类比一下 API 接口。调用者只需要关注抽象的接口，不需要了解具体的实现，具体的实现代码对调用者透明。接口实现了约定和实现相分离，可以降低代码间的耦合性，提高代码的可扩展性。

## 模拟抽象类和接口
在前面举的例子中，我们使用 Java 的接口语法实现了一个 Filter 过滤器。不过，如果你熟悉的是 C++ 这种编程语言，你可能会说，**C++ 只有抽象类，并没有接口**，那从代码实现的角度上来说，是不是就无法实现 Filter 的设计思路了呢？

我们先来回忆一下接口的定义：**接口中没有成员变量，只有方法声明，没有方法实现，实现接口的类必须实现接口中的所有方法**。只要满足这样几点，从设计的角度上来说，我们就可以把它叫作接口。实际上，要满足接口的这些语法特性并不难。在下面这段 C++ 代码中，我们就用抽象类模拟了一个接口（下面这段代码实际上是`策略模式`中的一段代码）：
```java
class Strategy 
{ 
    // 用抽象类模拟接口
    public:
        ~Strategy();
        virtual void algorithm()=0;
    protected:
        Strategy();
};
```

抽象类 Strategy 没有定义任何属性，并且所有的方法都声明为 virtual 类型（**等同于 Java 中的 abstract 关键字**），这样，所有的方法都不能有代码实现，并且所有继承这个抽象类的子类，都要实现这些方法。从语法特性上来看，这个抽象类就相当于一个接口。

## 抽象类 or 接口
实际上，判断的标准很简单。如果我们要表示一种 `is-a` 的关系，并且是为了解决代码复用的问题，我们就用抽象类；如果我们要表示一种 `has-a` 的关系，并且是为了解决抽象而非代码复用的问题，那我们就可以使用接口。

从类的继承层次上来看，**抽象类是一种自下而上的设计思路**，先有子类的代码重复，然后再抽象成上层的父类（也就是抽象类）。而**接口是一种自上而下的设计思路**，我们在编程的时候，一般都是先设计接口，再去考虑具体的实现。
