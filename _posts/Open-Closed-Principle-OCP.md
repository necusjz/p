---
title: Open Closed Principle (OCP)
date: 2020-09-18 22:28:06
tags:
  - GoF
---
## 如何理解 OCP
开闭原则的英文全称是 Open Closed Principle，简写为 OCP。它的英文描述是：
> Software entities (modules, classes, functions, etc.) should be open for extension, but closed for modification.

我们把它翻译成中文就是：**软件实体（模块、类、方法等）应该“对扩展开放、对修改关闭”**。

这个描述比较简略，如果我们详细表述一下，那就是，添加一个新的功能应该是，**在已有代码基础上扩展代码（新增模块、类、方法等），而非修改已有代码（修改模块、类、方法等）**。

这是一段 API 接口监控告警的代码。其中，AlertRule 存储告警规则，可以自由设置。Notification 是告警通知类，支持邮件、短信、微信、手机等多种通知渠道。NotificationEmergencyLevel 表示通知的紧急程度，包括 SEVERE（严重）、URGENCY（紧急）、NORMAL（普通）、TRIVIAL（无关紧要），不同的紧急程度对应不同的发送渠道：
```
public class Alert 
{
    private AlertRule rule;
    private Notification notification;

    public Alert(AlertRule rule, Notification notification) 
    {
        this.rule = rule;
        this.notification = notification;
    }

    public void check(String api, long requestCount, long errorCount, long durationOfSeconds) 
    {
        long tps = requestCount / durationOfSeconds;
        if (tps > rule.getMatchedRule(api).getMaxTps()) 
        {
            notification.notify(NotificationEmergencyLevel.URGENCY, "...");
        }
        if (errorCount > rule.getMatchedRule(api).getMaxErrorCount()) 
        {
            notification.notify(NotificationEmergencyLevel.SEVERE, "...");
        }
    }
}
```
<!--more-->

上面这段代码非常简单，业务逻辑主要集中在 check() 函数中。当接口的 TPS 超过某个预先设置的最大值时，以及当接口请求出错数大于某个最大允许值时，就会触发告警，通知接口的相关负责人或者团队。

现在，如果我们需要添加一个功能，当每秒钟接口超时请求个数，超过某个预先设置的最大阈值时，我们也要触发告警发送通知。这个时候，我们该如何改动代码呢？主要的改动有两处：第一处是修改 check() 函数的入参，添加一个新的统计数据 timeoutCount，表示超时接口请求数；第二处是在 check() 函数中添加新的告警逻辑。具体的代码改动如下所示：
```
public class Alert 
{
    //...省略AlertRule/Notification属性和构造函数...
    
    // 改动一：添加参数timeoutCount
    public void check(String api, long requestCount, long errorCount, long timeoutCount, long durationOfSeconds) 
    {
        long tps = requestCount / durationOfSeconds;
        if (tps > rule.getMatchedRule(api).getMaxTps()) 
        {
            notification.notify(NotificationEmergencyLevel.URGENCY, "...");
        }
        if (errorCount > rule.getMatchedRule(api).getMaxErrorCount()) 
        {
            notification.notify(NotificationEmergencyLevel.SEVERE, "...");
        }
        // 改动二：添加接口超时处理逻辑
        long timeoutTps = timeoutCount / durationOfSeconds;
        if (timeoutTps > rule.getMatchedRule(api).getMaxTimeoutTps()) 
        {
            notification.notify(NotificationEmergencyLevel.URGENCY, "...");
        }
    }
}
```

这样的代码修改实际上存在挺多问题的。一方面，我们对接口进行了修改，这就意味着**调用这个接口的代码都要做相应的修改**。另一方面，修改了 check() 函数，**相应的单元测试都需要修改**。

上面的代码改动是基于“修改”的方式来实现新功能的。如果我们遵循开闭原则，也就是“对扩展开放、对修改关闭”。那如何通过“扩展”的方式，来实现同样的功能呢？

我们先重构一下之前的 Alert 代码，让它的扩展性更好一些。重构的内容主要包含两部分：
- 第一部分是将 check() 函数的**多个入参封装成 ApiStatInfo 类**；
- 第二部分是引入 handler 的概念，**将 if 判断逻辑分散在各个 handler 中**；

具体的代码实现如下所示：
```
public class Alert 
{
    private List<AlertHandler> alertHandlers = new ArrayList<>();
    
    public void addAlertHandler(AlertHandler alertHandler) 
    {
        this.alertHandlers.add(alertHandler);
    }

    public void check(ApiStatInfo apiStatInfo) 
    {
        for (AlertHandler handler : alertHandlers) 
        {
            handler.check(apiStatInfo);
        }
    }
}

public class ApiStatInfo 
{
    // 省略constructor/getter/setter方法
    private String api;
    private long requestCount;
    private long errorCount;
    private long durationOfSeconds;
}

public abstract class AlertHandler 
{
    protected AlertRule rule;
    protected Notification notification;
    public AlertHandler(AlertRule rule, Notification notification) 
    {
        this.rule = rule;
        this.notification = notification;
    }
    public abstract void check(ApiStatInfo apiStatInfo);
}

public class TpsAlertHandler extends AlertHandler 
{
    public TpsAlertHandler(AlertRule rule, Notification notification) 
    {
        super(rule, notification);
    }

    @Override
    public void check(ApiStatInfo apiStatInfo) 
    {
        long tps = apiStatInfo.getRequestCount() / apiStatInfo.getDurationOfSeconds();
        if (tps > rule.getMatchedRule(apiStatInfo.getApi()).getMaxTps()) 
        {
            notification.notify(NotificationEmergencyLevel.URGENCY, "...");
        }
    }
}

public class ErrorAlertHandler extends AlertHandler 
{
    public ErrorAlertHandler(AlertRule rule, Notification notification)
    {
        super(rule, notification);
    }

    @Override
    public void check(ApiStatInfo apiStatInfo) 
    {
        if (apiStatInfo.getErrorCount() > rule.getMatchedRule(apiStatInfo.getApi()).getMaxErrorCount()) 
        {
            notification.notify(NotificationEmergencyLevel.SEVERE, "...");
        }
    }
}
```

上面的代码是对 Alert 的重构，我们再来看下，重构之后的 Alert 该如何使用呢？其中，ApplicationContext 是一个单例类，负责 Alert 的创建、组装（alertRule 和 notification 的依赖注入）、初始化（添加 handlers）工作：
```
public class ApplicationContext 
{
    private AlertRule alertRule;
    private Notification notification;
    private Alert alert;
    
    public void initializeBeans() 
    {
        alertRule = new AlertRule(/*.省略参数.*/); // 省略一些初始化代码
        notification = new Notification(/*.省略参数.*/); // 省略一些初始化代码
        alert = new Alert();
        alert.addAlertHandler(new TpsAlertHandler(alertRule, notification));
        alert.addAlertHandler(new ErrorAlertHandler(alertRule, notification));
    }
    public Alert getAlert() 
    { 
        return alert; 
    }

    // 饿汉式单例
    private static final ApplicationContext instance = new ApplicationContext();
    private ApplicationContext() 
    {
        initializeBeans();
    }
    public static ApplicationContext getInstance() 
    {
        return instance;
    }
}

public class Demo 
{
    public static void main(String[] args) 
    {
        ApiStatInfo apiStatInfo = new ApiStatInfo();
        //...省略设置apiStatInfo数据值的代码
        ApplicationContext.getInstance().getAlert().check(apiStatInfo);
    }
}
```

现在，我们再来看下，基于重构之后的代码，如果再添加上面讲到的那个新功能，每秒钟接口超时请求个数超过某个最大阈值就告警，我们又该如何改动代码呢？主要的改动有下面四处：
- 在 ApiStatInfo 类中添加新的属性 timeoutCount；
- 添加新的 TimeoutAlertHandler 类；
- 在 ApplicationContext 类的 initializeBeans() 方法中，往 alert 对象中注册新的 timeoutAlertHandler；
- 在使用 Alert 类的时候，需要给 check() 函数的入参 apiStatInfo 对象设置 timeoutCount 的值；

改动之后的代码如下所示：
```
public class Alert 
{ 
    // 代码未改动... 
}
public class ApiStatInfo 
{
    // 省略constructor/getter/setter方法
    private String api;
    private long requestCount;
    private long errorCount;
    private long durationOfSeconds;
    private long timeoutCount; // 改动一：添加新字段
}
public abstract class AlertHandler 
{ 
    // 代码未改动... 
}
public class TpsAlertHandler extends AlertHandler 
{
    // 代码未改动...
}
public class ErrorAlertHandler extends AlertHandler 
{
    // 代码未改动...
}
// 改动二：添加新的handler
public class TimeoutAlertHandler extends AlertHandler 
{
    // 省略代码...
}

public class ApplicationContext 
{
    private AlertRule alertRule;
    private Notification notification;
    private Alert alert;
    
    public void initializeBeans() 
    {
        alertRule = new AlertRule(/*.省略参数.*/); // 省略一些初始化代码
        notification = new Notification(/*.省略参数.*/); // 省略一些初始化代码
        alert = new Alert();
        alert.addAlertHandler(new TpsAlertHandler(alertRule, notification));
        alert.addAlertHandler(new ErrorAlertHandler(alertRule, notification));
        // 改动三：注册handler
        alert.addAlertHandler(new TimeoutAlertHandler(alertRule, notification));
    }
    //...省略其他未改动代码...
}

public class Demo 
{
    public static void main(String[] args) 
    {
        ApiStatInfo apiStatInfo = new ApiStatInfo();
        //...省略apiStatInfo的set字段代码
        apiStatInfo.setTimeoutCount(289); // 改动四：设置timeoutCount值
        ApplicationContext.getInstance().getAlert().check(apiStatInfo);
    }
}
```

**重构之后的代码更加灵活和易扩展**。如果我们要想添加新的告警逻辑，只需要基于扩展的方式创建新的 handler 类即可，不需要改动原来的 check() 函数的逻辑。而且，我们只需要为新的 handler 类添加单元测试，老的单元测试都不会失败，也不用修改。

## 修改代码违背 OCP 吗
看了上面重构之后的代码，你可能还会有疑问：在添加新的告警逻辑的时候，尽管改动二（添加新的 handler 类）是基于扩展而非修改的方式来完成的，但改动一、三、四貌似不是基于扩展而是基于修改的方式来完成的，那改动一、三、四不就违背了开闭原则吗？

### 改动一
> 往 ApiStatInfo 类中，添加新的属性 timeoutCount。

从定义中，我们可以看出，开闭原则可以应用在不同粒度的代码中，可以是模块，也可以类，还可以是方法（及其属性）。**同样一个代码改动，在粗代码粒度下，被认定为“修改”，在细代码粒度下，又可以被认定为“扩展”**。比如，改动一，添加属性和方法相当于修改类，在类这个层面，这个代码改动可以被认定为“修改”；但这个代码改动并没有修改已有的属性和方法，在方法（及其属性）这一层面，它又可以被认定为“扩展”。

实际上，我们也没必要纠结某个代码改动是“修改”还是“扩展”，更没必要太纠结它是否违反“开闭原则”。我们回到这条原则的设计初衷：**只要它没有破坏原有的代码的正常运行，没有破坏原有的单元测试**，我们就可以说，这是一个合格的代码改动。

### 改动三和改动四
> 在 ApplicationContext 类的 initializeBeans() 方法中，往 alert 对象中注册新的 timeoutAlertHandler；在使用 Alert 类的时候，需要给 check() 函数的入参 apiStatInfo 对象设置 timeoutCount 的值。

我们要认识到，添加一个新功能，不可能任何模块、类、方法的代码都不“修改”，这个是做不到的。类需要创建、组装、并且做一些初始化操作，才能构建成可运行的的程序，这部分代码的修改是在所难免的。我们要做的是**尽量让修改操作更集中、更少、更上层，尽量让最核心、最复杂的那部分逻辑代码满足开闭原则**。

## 如何做到 OCP
在讲具体的方法论之前，我们先来看一些更加偏向顶层的指导思想。为了尽量写出扩展性好的代码，我们要**时刻具备扩展意识、抽象意识、封装意识**。这些“潜意识”可能比任何开发技巧都重要。

在写代码的时候后，我们要多花点时间往前多思考一下，**这段代码未来可能有哪些需求变更、如何设计代码结构，事先留好扩展点**，以便在未来需求变更的时候，不需要改动代码整体结构、做到最小代码改动的情况下，新的代码能够很灵活地插入到扩展点上，做到“对扩展开放、对修改关闭”。

还有，在识别出代码可变部分和不可变部分之后，我们要**将可变部分封装起来，隔离变化，提供抽象化的不可变接口，给上层系统使用**。当具体的实现发生变化的时候，我们只需要基于相同的抽象接口，扩展一个新的实现，替换掉老的实现即可，上游系统的代码几乎不需要修改。

实际上，多态、依赖注入、基于接口而非实现编程，以及前面提到的抽象意识，说的都是同一种设计思路，只是从不同的角度、不同的层面来阐述而已。这也体现了“**很多设计原则、思想、模式都是相通的**”这一思想。

比如，我们代码中通过 Kafka 来发送异步消息。对于这样一个功能的开发，我们要学会将其抽象成一组跟具体消息队列（Kafka）无关的异步消息接口。所有上层系统都依赖这组抽象的接口编程，并且通过依赖注入的方式来调用。当我们要替换新的消息队列的时候，比如将 Kafka 替换成 RocketMQ，可以很方便地拔掉老的消息队列实现，插入新的消息队列实现。具体代码如下所示：
```
// 这一部分体现了抽象意识
public interface MessageQueue 
{ 
    //... 
}
public class KafkaMessageQueue implements MessageQueue 
{ 
    //... 
}
public class RocketMQMessageQueue implements MessageQueue 
{
    //...
}

public interface MessageFormatter 
{ 
    //... 
}
public class JsonMessageFormatter implements MessageFormatter 
{
    //...
}
public class ProtoBufMessageFormatter implements MessageFormatter 
{
    //...
}

public class Demo 
{
    private MessageQueue msgQueue; // 基于接口而非实现编程
    public Demo(MessageQueue msgQueue) 
    { 
        // 依赖注入
        this.msgQueue = msgQueue;
    }
    
    // msgFormatter：多态、依赖注入
    public void sendNotification(Notification notification, MessageFormatter msgFormatter) 
    {
        //...    
    }
}
```

## 如何灵活应用 OCP
如果你开发的是一个业务导向的系统，比如金融系统、电商系统、物流系统等，要想识别出尽可能多的扩展点，就要**对业务有足够的了解，能够知道当下以及未来可能要支持的业务需求**。如果你开发的是跟业务无关的、通用的、偏底层的系统，比如，框架、组件、类库，你需要了解“**它们会被如何使用？今后你打算添加哪些功能？使用者未来会有哪些更多的功能需求？**”等问题。

最合理的做法是，对于一些比较确定的、短期内可能就会扩展，或者需求改动对代码结构影响比较大的情况，或者实现成本不高的扩展点，在编写代码的时候之后，我们就可以事先做些扩展性设计。但对于一些不确定未来是否要支持的需求，或者实现起来比较复杂的扩展点，我们可以**等到有需求驱动的时候，再通过重构代码的方式来支持扩展的需求**。

在我们之前举的 Alert 告警的例子中，如果告警规则并不是很多、也不复杂，那 check() 函数中的 if 语句就不会很多，代码逻辑也不复杂，代码行数也不多，那最初的**第一种代码实现思路简单易读**，就是比较合理的选择。相反，如果告警规则很多、很复杂，check() 函数的 if 语句、代码逻辑就会很多、很复杂，相应的代码行数也会很多，可读性、可维护性就会变差，那重构之后的第二种代码实现思路就是更加合理的选择了。
