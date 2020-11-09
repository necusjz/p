---
title: 迪米特法则（LoD）
date: 2020-11-07 18:27:05
tags:
  - GoF
---
## 何为“高内聚、松耦合”？
“高内聚、松耦合”是一个非常重要的设计思想，能够有效地提高代码的可读性和可维护性，缩小功能改动导致的代码改动范围。实际上，“高内聚、松耦合”是一个比较通用的设计思想，可以用来指导不同粒度代码的设计与开发，比如**系统、模块、类，甚至是函数**，也可以应用到不同的开发场景中，比如**微服务、框架、组件、类库**等。

为了方便我讲解，接下来我以“类”作为这个设计思想的应用对象来展开讲解，其他应用场景你可以自行类比。在这个设计思想中，`高内聚`用来指导类本身的设计，`松耦合`用来指导类与类之间依赖关系的设计。不过，这两者并非完全独立不相干。**高内聚有助于松耦合，松耦合又需要高内聚的支持**。

### 高内聚
所谓高内聚，就是指相近的功能应该放到同一个类中，不相近的功能不要放到同一个类中。相近的功能往往会被同时修改，放到同一个类中，**修改会比较集中，代码容易维护**。

### 松耦合
所谓松耦合是说，在代码中，类与类之间的依赖关系简单清晰。即使两个类有依赖关系，**一个类的代码改动不会或者很少导致依赖类的代码改动**。

### 内聚和耦合的关系
高内聚有助于松耦合，同理，**低内聚也会导致紧耦合**。关于这一点，我画了一张对比图来解释。图中左边部分的代码结构是“高内聚、松耦合”；右边部分正好相反，是“低内聚、紧耦合”：
<!--more-->
![](https://raw.githubusercontent.com/was48i/mPOST/master/GoF/00.png)

从图中我们也可以看出，高内聚、低耦合的代码结构更加简单、清晰，相应地，在可维护性和可读性上确实要好很多。

## 迪米特法则理论描述
迪米特法则的英文翻译是：Law of Demeter，缩写是 LoD。它还有另外一个更加达意的名字，叫作最小知识原则，英文翻译为：
> The Least Knowledge Principle.

关于这个设计原则，我们先来看一下它最原汁原味的英文定义：
> Each unit should have only limited knowledge about other units: only units “closely” related to the current unit. Or: Each unit should only talk to its friends; Don’t talk to strangers.

我们之前讲过，大部分设计原则和思想都非常抽象，有各种各样的解读，**要想灵活地应用到实际的开发中，需要有实战经验的积累**。迪米特法则也不例外。所以，我结合我自己的理解和经验，对刚刚的定义重新描述一下：
> 不该有直接依赖关系的类之间，不要有依赖；有依赖关系的类之间，尽量只依赖必要的接口（也就是定义中的**有限知识**）。

### 不该有直接依赖关系的类之间，不要有依赖
这个例子实现了简化版的搜索引擎爬取网页的功能。代码中包含三个主要的类。其中，NetworkTransporter 类负责底层网络通信，根据请求获取数据；HtmlDownloader 类用来通过 URL 获取网页；Document 表示网页文档，后续的网页内容抽取、分词、索引都是以此为处理对象。具体的代码实现如下所示：
```
public class NetworkTransporter 
{
    // 省略属性和其他方法...
    public Byte[] send(HtmlRequest htmlRequest) 
    {
        //...
    }
}

public class HtmlDownloader 
{
    private NetworkTransporter transporter; // 通过构造函数或 IoC 注入
    
    public Html downloadHtml(String url) 
    {
        Byte[] rawHtml = transporter.send(new HtmlRequest(url));
        return new Html(rawHtml);
    }
}

public class Document 
{
    private Html html;
    private String url;
    
    public Document(String url) 
    {
        this.url = url;
        HtmlDownloader downloader = new HtmlDownloader();
        this.html = downloader.downloadHtml(url);
    }
    //...
}
```

这段代码虽然“能用”，能实现我们想要的功能，但是它不够“好用”，**有比较多的设计缺陷**。

#### NetworkTransporter 类
作为一个底层网络通信类，我们希望它的功能尽可能通用，而不只是服务于下载 HTML，所以，我们不应该直接依赖太具体的发送对象 HtmlRequest。从这一点上讲，NetworkTransporter 类的设计违背迪米特法则，**依赖了不该有直接依赖关系的 HtmlRequest 类**。

我这里有个形象的比喻。假如你现在要去商店买东西，你肯定不会直接把钱包给收银员，让收银员自己从里面拿钱，而是你从钱包里把钱拿出来交给收银员。这里的 HtmlRequest 对象就相当于钱包，HtmlRequest 里的 address 和 content 对象就相当于钱。我们**应该把 address 和 content 交给 NetworkTransporter**，而非是直接把 HtmlRequest 交给 NetworkTransporter。根据这个思路，NetworkTransporter 重构之后的代码如下所示：
```
public class NetworkTransporter 
{
    // 省略属性和其他方法...
    public Byte[] send(String address, Byte[] data) 
    {
        //...
    }
}
```

#### HtmlDownloader 类
这个类的设计没有问题。不过，我们修改了 NetworkTransporter 的 send() 函数的定义，而这个类用到了 send() 函数，所以**我们需要对它做相应的修改**：
```
public class HtmlDownloader 
{
    private NetworkTransporter transporter; // 通过构造函数或 IoC 注入
    
    // HtmlDownloader 这里也要有相应的修改
    public Html downloadHtml(String url) 
    {
        HtmlRequest htmlRequest = new HtmlRequest(url);
        Byte[] rawHtml = transporter.send(
            htmlRequest.getAddress(), htmlRequest.getContent().getBytes());
        return new Html(rawHtml);
    }
}
```

#### Document 类
这个类的问题比较多，主要有三点：
- 构造函数中的 downloader.downloadHtml() 逻辑复杂，耗时长，不应该放到构造函数中，会影响代码的可测试性；
- HtmlDownloader 对象在构造函数中通过 new 来创建，违反了基于接口而非实现编程的设计思想；
- 从业务含义上来讲，Document 网页文档没必要依赖 HtmlDownloader 类，违背了迪米特法则；

虽然 Document 类的问题很多，但修改起来比较简单，只要一处改动就可以解决所有问题：
```
public class Document 
{
    private Html html;
    private String url;
    
    public Document(String url, Html html) 
    {
        this.html = html;
        this.url = url;
    }
    //...
}

// 通过一个工厂方法来创建 Document
public class DocumentFactory 
{
    private HtmlDownloader downloader;
    
    public DocumentFactory(HtmlDownloader downloader) 
    {
        this.downloader = downloader;
    }
    
    public Document createDocument(String url) 
    {
        Html html = downloader.downloadHtml(url);
        return new Document(url, html);
    }
}
```

### 有依赖关系的类之间，尽量只依赖必要的接口
下面这段代码非常简单，Serialization 类负责对象的序列化和反序列化：
```
public class Serialization 
{
    public String serialize(Object object) 
    {
        String serializedResult = ...;
        //...
        return serializedResult;
    }
    
    public Object deserialize(String str) 
    {
        Object deserializedResult = ...;
        //...
        return deserializedResult;
    }
}
```

单看这个类的设计，没有一点问题。不过，**如果我们把它放到一定的应用场景里，那就还有继续优化的空间**。假设在我们的项目中，有些类只用到了序列化操作，而另一些类只用到反序列化操作。只用到序列化操作的那部分类不应该依赖反序列化接口；同理，只用到反序列化操作的那部分类不应该依赖序列化接口。

根据这个思路，我们应该将 Serialization 类拆分为两个更小粒度的类，一个只负责序列化（Serializer 类），一个只负责反序列化（Deserializer 类）。拆分之后，使用序列化操作的类只需要依赖 Serializer 类，使用反序列化操作的类只需要依赖 Deserializer 类：
```
public class Serializer 
{
    public String serialize(Object object) 
    {
        String serializedResult = ...;
        ...
        return serializedResult;
    }
}

public class Deserializer 
{
    public Object deserialize(String str) 
    {
        Object deserializedResult = ...;
        ...
        return deserializedResult;
    }
}
```

尽管拆分之后的代码**更能满足迪米特法则，但却违背了高内聚的设计思想**。如果我们修改了序列化的实现方式，比如从 JSON 换成了 XML，那反序列化的实现逻辑也需要一并修改。在未拆分的情况下，我们只需要修改一个类即可。在拆分之后，我们需要修改两个类。显然，**这种设计思路的代码改动范围变大了**。

通过引入两个接口就能轻松解决这个问题：
```
public interface Serializable 
{
    String serialize(Object object);
}

public interface Deserializable 
{
    Object deserialize(String text);
}

public class Serialization implements Serializable, Deserializable 
{
    @Override
    public String serialize(Object object) 
    {
        String serializedResult = ...;
        ...
        return serializedResult;
    }
    
    @Override
    public Object deserialize(String str) 
    {
        Object deserializedResult = ...;
        ...
        return deserializedResult;
    }
}

public class DemoClass_1 
{
    private Serializable serializer;
    
    public Demo(Serializable serializer) 
    {
        this.serializer = serializer;
    }
    //...
}

public class DemoClass_2 
{
    private Deserializable deserializer;
    
    public Demo(Deserializable deserializer) 
    {
        this.deserializer = deserializer;
    }
    //...
}
```

尽管我们还是要往 DemoClass_1 的构造函数中，传入包含序列化和反序列化的 Serialization 实现类，但是，我们依赖的 Serializable 接口只包含序列化操作，**DemoClass_1 无法使用 Serialization 类中的反序列化接口，对反序列化操作无感知**，这也就符合了迪米特法则后半部分所说的“依赖有限接口”的要求。

实际上，上面的的代码实现思路，也体现了“基于接口而非实现编程”的设计原则，结合迪米特法则，我们可以总结出一条新的设计原则，那就是：**基于最小接口而非最大实现编程**。
