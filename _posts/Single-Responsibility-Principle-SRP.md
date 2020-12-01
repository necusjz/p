---
title: Single Responsibility Principle (SRP)
date: 2020-09-17 23:19:08
tags:
  - GoF
---
## 如何理解 SRP
`单一职责原则`的英文是 Single Responsibility Principle，缩写为 SRP。这个原则的英文描述是这样的：
> A class or module should have a single responsibility.

如果我们把它翻译成中文，那就是：**一个类或者模块只负责完成一个职责（或者功能）**。

注意，这个原则描述的对象包含两个，一个是类（class），一个是模块（module）。关于这两个概念，在专栏中，有两种理解方式。一种理解是：**把模块看作比类更加抽象的概念**，类也可以看作模块。另一种理解是：**把模块看作比类更加粗粒度的代码块**，模块中包含多个类，多个类组成一个模块。

单一职责原则的定义描述非常简单，也不难理解。一个类只负责完成一个职责或者功能。也就是说，**不要设计大而全的类，要设计粒度小、功能单一的类**。换个角度来讲就是，一个类包含了两个或者两个以上业务不相干的功能，那我们就说它职责不够单一，应该将它拆分成多个功能更加单一、粒度更细的类。

## 如何判断 SRP
在一个社交产品中，我们用下面的 UserInfo 类来记录用户的信息。你觉得，UserInfo 类的设计是否满足单一职责原则呢：
```java
public class UserInfo 
{
    private long userId;
    private String username;
    private String email;
    private String telephone;
    private long createTime;
    private long lastLoginTime;
    private String avatarUrl;
    private String provinceOfAddress; // 省
    private String cityOfAddress; // 市
    private String regionOfAddress; // 区 
    private String detailedAddress; // 详细地址
    //...省略其他属性和方法...
}
```
<!--more-->

对于这个问题，有两种不同的观点。一种观点是，UserInfo 类包含的都是跟用户相关的信息，所有的属性和方法都隶属于用户这样一个业务模型，满足单一职责原则；另一种观点是，地址信息在 UserInfo 类中，所占的比重比较高，可以继续拆分成独立的 UserAddress 类，UserInfo 只保留除 Address 之外的其他信息，拆分之后的两个类的职责更加单一。

哪种观点更对呢？实际上，**要从中做出选择，我们不能脱离具体的应用场景**。如果在这个社交产品中，用户的地址信息跟其他信息一样，只是单纯地用来展示，那 UserInfo 现在的设计就是合理的。但是，如果这个社交产品发展得比较好，之后又在产品中添加了电商的模块，用户的地址信息还会用在电商物流中，那我们最好将地址信息从 UserInfo 中拆分出来，独立成用户物流信息（或者叫地址信息、收货信息等）。

除此之外，**从不同的业务层面去看待同一个类的设计，对类是否职责单一，也会有不同的认识**。比如，例子中的 UserInfo 类。如果我们从“用户”这个业务层面来看，UserInfo 包含的信息都属于用户，满足职责单一原则。如果我们从更加细分的“用户展示信息”“地址信息”“登录认证信息”等等这些更细粒度的业务层面来看，那 UserInfo 就应该继续拆分。

综上所述，评价一个类的职责是否足够单一，我们并没有一个非常明确的、可以量化的标准，可以说，这是件非常主观、仁者见仁智者见智的事情。实际上，在真正的软件开发中，我们也没必要过于未雨绸缪，过度设计。所以，我们**可以先写一个粗粒度的类，满足业务需求**。随着业务的发展，如果粗粒度的类越来越庞大，代码越来越多，这个时候，我们就可以将这个粗粒度的类，拆分成几个更细粒度的类。

下面这几条判断原则，比起很主观地去思考类是否职责单一，要更有指导意义、更具有可执行性：
- **类中的代码行数、函数或属性过多**，会影响代码的可读性和可维护性，我们就需要考虑对类进行拆分；
- **类依赖的其他类过多**，或者依赖类的其他类过多，不符合高内聚、低耦合的设计思想，我们就需要考虑对类进行拆分；
- **私有方法过多**，我们就要考虑能否将私有方法独立到新的类中，设置为 public 方法，供更多的类使用，从而提高代码的复用性；
- **比较难给类起一个合适名字**，很难用一个业务名词概括，或者只能用一些笼统的 Manager、Context 之类的词语来命名，这就说明类的职责定义得可能不够清晰；
- **类中大量的方法都是集中操作类中的某几个属性**，比如，在 UserInfo 例子中，如果一半的方法都是在操作 address 信息，那就可以考虑将这几个属性和对应的方法拆分出来;

实际上， 从另一个角度来看，当一个类的代码，读起来让你头大了，实现某个功能时不知道该用哪个函数了，想用哪个函数翻半天都找不到了，只用到一个小功能要引入整个类（类中包含很多无关此功能实现的函数）的时候，这就说明类的行数、函数、属性过多了。实际上，等你做多项目了，代码写多了，在开发中慢慢“品尝”，自然就知道什么是“放盐少许”了，这就是所谓的“专业第六感”。

## 类的职责是否越单一越好
为了满足单一职责原则，是不是把类拆得越细就越好呢？答案是否定的。我们还是通过一个例子来解释一下。Serialization 类实现了一个简单协议的序列化和反序列功能，具体代码如下：
```java
/**
 * Protocol format: identifier-string;{gson string}
 * For example: UEUEUE;{"a":"A","b":"B"}
 */
public class Serialization 
{
    private static final String IDENTIFIER_STRING = "UEUEUE;";
    private Gson gson;
    
    public Serialization() 
    {
        this.gson = new Gson();
    }
    
    public String serialize(Map<String, String> object) 
    {
        StringBuilder textBuilder = new StringBuilder();
        textBuilder.append(IDENTIFIER_STRING);
        textBuilder.append(gson.toJson(object));
        return textBuilder.toString();
    }
    
    public Map<String, String> deserialize(String text) 
    {
        if (!text.startsWith(IDENTIFIER_STRING)) 
        {
            return Collections.emptyMap();
        }
        String gsonStr = text.substring(IDENTIFIER_STRING.length());
        return gson.fromJson(gsonStr, Map.class);
    }
}
```

如果我们想让类的职责更加单一，我们对 Serialization 类进一步拆分，拆分成一个只负责序列化工作的 Serializer 类和另一个只负责反序列化工作的 Deserializer 类。拆分后的具体代码如下所示：
```java
public class Serializer 
{
    private static final String IDENTIFIER_STRING = "UEUEUE;";
    private Gson gson;
    
    public Serializer() 
    {
        this.gson = new Gson();
    }
    
    public String serialize(Map<String, String> object) 
    {
        StringBuilder textBuilder = new StringBuilder();
        textBuilder.append(IDENTIFIER_STRING);
        textBuilder.append(gson.toJson(object));
        return textBuilder.toString();
    }
}

public class Deserializer 
{
    private static final String IDENTIFIER_STRING = "UEUEUE;";
    private Gson gson;
    
    public Deserializer() 
    {
        this.gson = new Gson();
    }
    
    public Map<String, String> deserialize(String text) 
    {
        if (!text.startsWith(IDENTIFIER_STRING)) 
        {
            return Collections.emptyMap();
        }
        String gsonStr = text.substring(IDENTIFIER_STRING.length());
        return gson.fromJson(gsonStr, Map.class);
    }
}
```

虽然经过拆分之后，Serializer 类和 Deserializer 类的职责更加单一了，但也随之带来了新的问题。如果我们修改了协议的格式，数据标识从“UEUEUE”改为“DFDFDF”，或者序列化方式从 JSON 改为了 XML，那 Serializer 类和 Deserializer 类都需要做相应的修改，**代码的内聚性显然没有原来 Serialization 高了**。而且，如果我们仅仅对 Serializer 类做了协议修改，而忘记了修改 Deserializer 类的代码，那就会导致序列化、反序列化不匹配，程序运行出错，也就是说，**拆分之后，代码的可维护性变差了**。

实际上，不管是应用设计原则还是设计模式，**最终的目的还是提高代码的可读性、可扩展性、复用性、可维护性等**。我们在考虑应用某一个设计原则是否合理的时候，也可以以此作为最终的考量标准。
