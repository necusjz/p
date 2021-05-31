---
title: Bridge Design Pattern
date: 2020-12-05 01:27:29
tags:
  - GoF
---
## 桥接模式的原理解析
`桥接模式`（Bridge Design Pattern）的定义：
> Decouple an abstraction from its implementation so that the two can vary independently. -- GoF

翻译成中文就是：**将抽象和实现解耦，让它们可以独立变化**。GoF 给出的定义非常的简短，单凭这一句话，估计没几个人能看懂是什么意思。所以，我们通过 JDBC 驱动的例子来解释一下。**JDBC 驱动是桥接模式的经典应用**。我们先来看一下，如何利用 JDBC 驱动来查询数据库。具体的代码如下所示：
```java
Class.forName("com.mysql.jdbc.Driver"); // 加载及注册 JDBC 驱动程序
String url = "jdbc:mysql://localhost:3306/sample_db?user=root&password=your_password";
Connection con = DriverManager.getConnection(url);
Statement stmt = con.createStatement()；
String query = "select * from test";
ResultSet rs = stmt.executeQuery(query);
while(rs.next()) 
{
    rs.getString(1);
    rs.getInt(2);
}
```

如果我们想要把 MySQL 数据库换成 Oracle 数据库，只需要把第一行代码中的 com.mysql.jdbc.Driver 换成 oracle.jdbc.driver.OracleDriver 就可以了。当然，也有更灵活的实现方式，我们可以把需要加载的 Driver 类写到配置文件中，**当程序启动的时候，自动从配置文件中加载**，这样在切换数据库的时候，我们都不需要修改代码，只需要修改配置文件就可以了。

如此优雅的数据库切换是如何实现的呢？源码之下无秘密，我们先从 com.mysql.jdbc.Driver 这个类的代码看起：
<!--more-->
```java
package com.mysql.jdbc;
import java.sql.SQLException;

public class Driver extends NonRegisteringDriver implements java.sql.Driver 
{
    static 
    {
        try 
        {
            java.sql.DriverManager.registerDriver(new Driver());
        } 
        catch (SQLException E) 
        {
            throw new RuntimeException("Can't register driver!");
        }
    }

    /**
     * Construct a new driver and register it with DriverManager
     * @throws SQLException if a database error occurs.
     */
    public Driver() throws SQLException 
    {
        // Required for Class.forName().newInstance()
    }
}
```

结合 com.mysql.jdbc.Driver 的代码实现，我们可以发现，当执行 Class.forName(“com.mysql.jdbc.Driver”) 这条语句的时候，实际上是做了两件事情：
1. 要求 JVM 查找并加载指定的 Driver 类；
2. 执行该类的静态代码，也就是将 MySQL Driver 注册到 DriverManager 类中；

当我们把具体的 Driver 实现类（比如，com.mysql.jdbc.Driver）注册到 DriverManager 之后，后续所有对 JDBC 接口的调用，都会委派到对具体的 Driver 实现类来执行。而 **Driver 实现类都实现了相同的接口（java.sql.Driver ）**，这也是可以灵活切换 Driver 的原因：
```java
public class DriverManager 
{
    private final static CopyOnWriteArrayList<DriverInfo> registeredDrivers = new CopyOnWriteArrayList<DriverInfo>();

    //...
    static 
    {
        loadInitialDrivers();
        println("JDBC DriverManager initialized");
    }
    //...

    public static synchronized void registerDriver(java.sql.Driver driver) throws SQLException 
    {
        if (driver != null) 
        {
            registeredDrivers.addIfAbsent(new DriverInfo(driver));
        } 
        else 
        {
            throw new NullPointerException();
        }
    }

    public static Connection getConnection(String url, String user, String password) throws SQLException 
    {
        java.util.Properties info = new java.util.Properties();
        if (user != null) 
        {
            info.put("user", user);
        }
        if (password != null) 
        {
            info.put("password", password);
        }
        return (getConnection(url, info, Reflection.getCallerClass()));
    }
    //...
}
```

实际上，JDBC 本身就相当于“抽象”。注意，这里所说的“抽象”，指的并非“抽象类”或“接口”，而是跟具体的数据库无关的、被抽象出来的一套“类库”。具体的 Driver（比如，com.mysql.jdbc.Driver）就相当于“实现”。注意，这里所说的“实现”，也并非指“接口的实现类”，而是跟具体数据库相关的一套“类库”。**JDBC 和 Driver 独立开发，通过对象之间的组合关系，组装在一起**。JDBC 的所有逻辑操作，最终都委托给 Driver 来执行：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/GoF/12.png)

## 桥接模式的应用举例
一个 API 接口监控告警的例子：根据不同的告警规则，触发不同类型的告警。告警支持多种通知渠道，包括：邮件、短信、微信、自动语音电话。通知的紧急程度有多种类型，包括：SEVERE（严重）、URGENCY（紧急）、NORMAL（普通）、TRIVIAL（无关紧要）。不同的紧急程度对应不同的通知渠道：
```java
public enum NotificationEmergencyLevel 
{
    SEVERE, URGENCY, NORMAL, TRIVIAL
}

public class Notification 
{
    private List<String> emailAddresses;
    private List<String> telephones;
    private List<String> wechatIds;

    public Notification() {}

    public void setEmailAddress(List<String> emailAddress) 
    {
        this.emailAddresses = emailAddress;
    }

    public void setTelephones(List<String> telephones) 
    {
        this.telephones = telephones;
    }

    public void setWechatIds(List<String> wechatIds) 
    {
        this.wechatIds = wechatIds;
    }

    public void notify(NotificationEmergencyLevel level, String message) 
    {
        if (level.equals(NotificationEmergencyLevel.SEVERE)) 
        {
            //...自动语音电话
        } 
        else if (level.equals(NotificationEmergencyLevel.URGENCY)) 
        {
            //...发微信
        } 
        else if (level.equals(NotificationEmergencyLevel.NORMAL)) 
        {
            //...发邮件
        } 
        else if (level.equals(NotificationEmergencyLevel.TRIVIAL)) 
        {
            //...发邮件
        }
    }
}

// 在 API 监控告警的例子中，我们如下方式来使用 Notification 类：
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

Notification 类的代码实现有一个最明显的问题，那就是有很多 if-else 分支逻辑。实际上，**如果每个分支中的代码都不复杂，后期也没有无限膨胀的可能**，那这样的设计问题并不大，没必要非得一定要摒弃 if-else 分支逻辑。不过，Notification 的代码显然不符合这个条件。因为每个 if-else 分支中的代码逻辑都比较复杂，发送通知的所有逻辑都扎堆在 Notification 类中。很多设计模式都是试图**将庞大的类拆分成更细小的类，然后再通过某种更合理的结构组装在一起**。

针对 Notification 的代码，我们将不同渠道的发送逻辑剥离出来，形成独立的消息发送类 -- MsgSender。其中，**Notification 类相当于抽象，MsgSender 类相当于实现**，两者可以独立开发，通过组合关系（也就是桥梁）任意组合在一起。所谓任意组合的意思就是，不同紧急程度的消息和发送渠道之间的对应关系，不是在代码中固定写死的，我们可以动态地去指定：
```java
public interface MsgSender 
{
    void send(String message);
}

public class TelephoneMsgSender implements MsgSender 
{
    private List<String> telephones;

    public TelephoneMsgSender(List<String> telephones) 
    {
        this.telephones = telephones;
    }

    @Override
    public void send(String message) 
    {
        //...
    }
}

public class EmailMsgSender implements MsgSender 
{
    // 与 TelephoneMsgSender 代码结构类似，所以省略...
}

public class WechatMsgSender implements MsgSender 
{
    // 与 TelephoneMsgSender 代码结构类似，所以省略...
}

public abstract class Notification 
{
    protected MsgSender msgSender;

    public Notification(MsgSender msgSender) 
    {
        this.msgSender = msgSender;
    }

    public abstract void notify(String message);
}

public class SevereNotification extends Notification 
{
    public SevereNotification(MsgSender msgSender) 
    {
        super(msgSender);
    }

    @Override
    public void notify(String message) 
    {
        msgSender.send(message);
    }
}

public class UrgencyNotification extends Notification 
{
    // 与 SevereNotification 代码结构类似，所以省略...
}
public class NormalNotification extends Notification 
{
    // 与 SevereNotification 代码结构类似，所以省略...
}
public class TrivialNotification extends Notification 
{
    // 与 SevereNotification 代码结构类似，所以省略...
}
```
