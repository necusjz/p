---
title: Factory Design Pattern
date: 2020-11-22 16:32:49
tags:
  - GoF
---
## 简单工厂（Simple Factory）
在下面这段代码中，我们根据配置文件的后缀（json、xml...），选择不同的解析器（JsonRuleConfigParser、XmlRuleConfigParser...），将存储在文件中的配置解析成内存对象 RuleConfig：
```java
public class RuleConfigSource 
{
    public RuleConfig load(String ruleConfigFilePath) 
    {
        String ruleConfigFileExtension = getFileExtension(ruleConfigFilePath);
        IRuleConfigParser parser = null;
        if ("json".equalsIgnoreCase(ruleConfigFileExtension)) 
        {
            parser = new JsonRuleConfigParser();
        } 
        else if ("xml".equalsIgnoreCase(ruleConfigFileExtension)) 
        {
            parser = new XmlRuleConfigParser();
        } 
        else if ("yaml".equalsIgnoreCase(ruleConfigFileExtension)) 
        {
            parser = new YamlRuleConfigParser();
        } 
        else if ("properties".equalsIgnoreCase(ruleConfigFileExtension)) 
        {
            parser = new PropertiesRuleConfigParser();
        } 
        else
        {
            throw new InvalidRuleConfigException("Rule config file format is not supported: " + ruleConfigFilePath);
        }

        String configText = "";
        // 从 ruleConfigFilePath 文件中读取配置文本到 configText 中
        RuleConfig ruleConfig = parser.parse(configText);
        return ruleConfig;
    }

    private String getFileExtension(String filePath) 
    {
        //...解析文件名获取扩展名，比如 rule.json，返回 json
        return "json";
    }
}
```
<!--more-->

为了让代码逻辑更加清晰，可读性更好，我们要善于**将功能独立的代码块封装成函数**。按照这个设计思路，我们可以将代码中涉及 parser 创建的部分逻辑剥离出来，抽象成 createParser() 函数：
```java
public RuleConfig load(String ruleConfigFilePath) 
{
    String ruleConfigFileExtension = getFileExtension(ruleConfigFilePath);
    IRuleConfigParser parser = createParser(ruleConfigFileExtension);
    if (parser == null) 
    {
        throw new InvalidRuleConfigException("Rule config file format is not supported: " + ruleConfigFilePath);
    }

    String configText = "";
    // 从 ruleConfigFilePath 文件中读取配置文本到 configText 中
    RuleConfig ruleConfig = parser.parse(configText);
    return ruleConfig;
}

private String getFileExtension(String filePath) 
{
    //...解析文件名获取扩展名，比如 rule.json，返回 json
    return "json";
}

private IRuleConfigParser createParser(String configFormat) 
{
    IRuleConfigParser parser = null;
    if ("json".equalsIgnoreCase(configFormat)) 
    {
        parser = new JsonRuleConfigParser();
    } 
    else if ("xml".equalsIgnoreCase(configFormat)) 
    {
        parser = new XmlRuleConfigParser();
    } 
    else if ("yaml".equalsIgnoreCase(configFormat)) 
    {
        parser = new YamlRuleConfigParser();
    } 
    else if ("properties".equalsIgnoreCase(configFormat)) 
    {
        parser = new PropertiesRuleConfigParser();
    }
    return parser;
}
```

为了让类的职责更加单一、代码更加清晰，我们还可以**进一步将 createParser() 函数剥离到一个独立的类中**，让这个类只负责对象的创建。而这个类就是我们现在要讲的简单工厂模式类。具体的代码如下所示：
```java
public class RuleConfigSource 
{
    public RuleConfig load(String ruleConfigFilePath) 
    {
        String ruleConfigFileExtension = getFileExtension(ruleConfigFilePath);
        IRuleConfigParser parser = RuleConfigParserFactory.createParser(ruleConfigFileExtension);
        if (parser == null) 
        {
            throw new InvalidRuleConfigException("Rule config file format is not supported: " + ruleConfigFilePath);
        }

        String configText = "";
        // 从 ruleConfigFilePath 文件中读取配置文本到 configText 中
        RuleConfig ruleConfig = parser.parse(configText);
        return ruleConfig;
    }

    private String getFileExtension(String filePath) 
    {
        //...解析文件名获取扩展名，比如 rule.json，返回 json
        return "json";
    }
}

public class RuleConfigParserFactory 
{
    public static IRuleConfigParser createParser(String configFormat) 
    {
        IRuleConfigParser parser = null;
        if ("json".equalsIgnoreCase(configFormat)) 
        {
            parser = new JsonRuleConfigParser();
        } 
        else if ("xml".equalsIgnoreCase(configFormat)) 
        {
            parser = new XmlRuleConfigParser();
        } 
        else if ("yaml".equalsIgnoreCase(configFormat)) 
        {
            parser = new YamlRuleConfigParser();
        } 
        else if ("properties".equalsIgnoreCase(configFormat)) 
        {
            parser = new PropertiesRuleConfigParser();
        }
        return parser;
    }
}
```

在上面的代码实现中，我们每次调用 RuleConfigParserFactory 的 createParser() 的时候，都要创建一个新的 parser。实际上，如果 parser 可以复用，**为了节省内存和对象创建的时间，我们可以将 parser 事先创建好缓存起来**。当调用 createParser() 函数的时候，我们从缓存中取出 parser 对象直接使用。

这有点**类似单例模式和简单工厂模式的结合**，具体的代码实现如下所示：
```java
public class RuleConfigParserFactory 
{
    private static final Map<String, RuleConfigParser> cachedParsers = new HashMap<>();

    static 
    {
        cachedParsers.put("json", new JsonRuleConfigParser());
        cachedParsers.put("xml", new XmlRuleConfigParser());
        cachedParsers.put("yaml", new YamlRuleConfigParser());
        cachedParsers.put("properties", new PropertiesRuleConfigParser());
    }

    public static IRuleConfigParser createParser(String configFormat) 
    {
        if (configFormat == null || configFormat.isEmpty()) 
        {
            return null; // 返回 null 还是 IllegalArgumentException 全凭你自己说了算
        }
        IRuleConfigParser parser = cachedParsers.get(configFormat.toLowerCase());
        return parser;
    }
}
```

对于上面两种简单工厂模式的实现方法，如果我们要添加新的 parser，那势必要改动到 RuleConfigParserFactory 的代码，那这是不是违反开闭原则呢？实际上，如果**不是需要频繁地添加新的 parser**，只是偶尔修改一下 RuleConfigParserFactory 代码，稍微不符合开闭原则，也是完全可以接受的。

除此之外，在 RuleConfigParserFactory 的第一种代码实现中，有一组 if 分支判断逻辑，是不是应该用多态或其他设计模式来替代呢？实际上，**如果 if 分支并不是很多，代码中有 if 分支也是完全可以接受的**。应用多态或设计模式来替代 if 分支判断逻辑，也并不是没有任何缺点的，它虽然提高了代码的扩展性，更加符合开闭原则，但也**增加了类的个数，牺牲了代码的可读性**。

## 工厂方法（Factory Method）
如果我们非得要将 if 分支逻辑去掉，那该怎么办呢？比较经典处理方法就是利用`多态`。按照多态的实现思路，对上面的代码进行重构：
```java
public interface IRuleConfigParserFactory 
{
    IRuleConfigParser createParser();
}

public class JsonRuleConfigParserFactory implements IRuleConfigParserFactory 
{
    @Override
    public IRuleConfigParser createParser() 
    {
        return new JsonRuleConfigParser();
    }
}

public class XmlRuleConfigParserFactory implements IRuleConfigParserFactory 
{
    @Override
    public IRuleConfigParser createParser() 
    {
        return new XmlRuleConfigParser();
    }
}

public class YamlRuleConfigParserFactory implements IRuleConfigParserFactory 
{
    @Override
    public IRuleConfigParser createParser() 
    {
        return new YamlRuleConfigParser();
    }
}

public class PropertiesRuleConfigParserFactory implements IRuleConfigParserFactory 
{
    @Override
    public IRuleConfigParser createParser() 
    {
        return new PropertiesRuleConfigParser();
    }
}
```

实际上，这就是**工厂方法模式的典型代码实现**。这样当我们新增一种 parser 的时候，只需要新增一个实现了 IRuleConfigParserFactory 接口的 Factory 类即可。所以，**工厂方法模式比起简单工厂模式更加符合开闭原则**。

从上面的工厂方法的实现来看，一切都很完美，但是实际上存在挺大的问题。**问题存在于这些工厂类的使用上**。接下来，我们看一下，如何用这些工厂类来实现 RuleConfigSource 的 load() 函数：
```java
public class RuleConfigSource 
{
    public RuleConfig load(String ruleConfigFilePath) 
    {
        String ruleConfigFileExtension = getFileExtension(ruleConfigFilePath);

        IRuleConfigParserFactory parserFactory = null;
        if ("json".equalsIgnoreCase(ruleConfigFileExtension)) 
        {
            parserFactory = new JsonRuleConfigParserFactory();
        } 
        else if ("xml".equalsIgnoreCase(ruleConfigFileExtension)) 
        {
            parserFactory = new XmlRuleConfigParserFactory();
        } 
        else if ("yaml".equalsIgnoreCase(ruleConfigFileExtension)) 
        {
            parserFactory = new YamlRuleConfigParserFactory();
        } 
        else if ("properties".equalsIgnoreCase(ruleConfigFileExtension)) 
        {
            parserFactory = new PropertiesRuleConfigParserFactory();
        } 
        else 
        {
            throw new InvalidRuleConfigException("Rule config file format is not supported: " + ruleConfigFilePath);
        }
        IRuleConfigParser parser = parserFactory.createParser();

        String configText = "";
        // 从 ruleConfigFilePath 文件中读取配置文本到 configText 中
        RuleConfig ruleConfig = parser.parse(configText);
        return ruleConfig;
    }

    private String getFileExtension(String filePath) 
    {
        //...解析文件名获取扩展名，比如 rule.json，返回 json
        return "json";
    }
}
```

从上面的代码实现来看，工厂类对象的创建逻辑又耦合进了 load() 函数中，跟我们最初的代码版本非常相似，引入工厂方法非但没有解决问题，反倒让设计变得更加复杂了。我们**可以为工厂类再创建一个简单工厂**，也就是工厂的工厂，用来创建工厂类对象。其中，RuleConfigParserFactoryMap 类是创建工厂对象的工厂类，getParserFactory() 返回的是缓存好的单例工厂对象：
```java
public class RuleConfigSource 
{
    public RuleConfig load(String ruleConfigFilePath) 
    {
        String ruleConfigFileExtension = getFileExtension(ruleConfigFilePath);

        IRuleConfigParserFactory parserFactory = RuleConfigParserFactoryMap.getParserFactory(ruleConfigFileExtension);
        if (parserFactory == null) 
        {
            throw new InvalidRuleConfigException("Rule config file format is not supported: " + ruleConfigFilePath);
        }
        IRuleConfigParser parser = parserFactory.createParser();

        String configText = "";
        // 从 ruleConfigFilePath 文件中读取配置文本到 configText 中
        RuleConfig ruleConfig = parser.parse(configText);
        return ruleConfig;
    }

    private String getFileExtension(String filePath) 
    {
        //...解析文件名获取扩展名，比如 rule.json，返回 json
        return "json";
    }
}

// 因为工厂类只包含方法，不包含成员变量，完全可以复用，
// 不需要每次都创建新的工厂类对象，所以，简单工厂模式的第二种实现思路更加合适
public class RuleConfigParserFactoryMap // 工厂的工厂
{
    private static final Map<String, IRuleConfigParserFactory> cachedFactories = new HashMap<>();

    static
    {
        cachedFactories.put("json", new JsonRuleConfigParserFactory());
        cachedFactories.put("xml", new XmlRuleConfigParserFactory());
        cachedFactories.put("yaml", new YamlRuleConfigParserFactory());
        cachedFactories.put("properties", new PropertiesRuleConfigParserFactory());
    }

    public static IRuleConfigParserFactory getParserFactory(String type) 
    {
        if (type == null || type.isEmpty()) 
        {
            return null;
        }
        IRuleConfigParserFactory parserFactory = cachedFactories.get(type.toLowerCase());
        return parserFactory;
    }
}
```

实际上，对于规则配置文件解析这个应用场景来说，工厂模式需要额外创建诸多 Factory 类，也会增加代码的复杂性，而且，**每个 Factory 类只是做简单的 new 操作，功能非常单薄**，也没必要设计成独立的类，所以，在这个应用场景下，简单工厂模式简单好用，比工厂方法模式更加合适。

当对象的创建逻辑比较复杂，不只是简单的 new 一下就可以，而是要组合其他类对象，做各种初始化操作的时候，我们推荐使用工厂方法模式，**将复杂的创建逻辑拆分到多个工厂类中，让每个工厂类都不至于过于复杂**。

## 抽象工厂（Abstract Factory）
抽象工厂模式的应用场景比较特殊，没有前两种常用。**在简单工厂和工厂方法中，类只有一种分类方式**。比如，在规则配置解析那个例子中，解析器类只会根据配置文件格式（Json、Xml、Yaml...）来分类。但是，如果类有两种分类方式，比如，我们既可以按照配置文件格式来分类，也可以按照解析的对象（Rule 规则配置还是 System 系统配置）来分类，那就会对应下面这 8 个 parser 类：
```
针对规则配置的解析器：基于接口 IRuleConfigParser
JsonRuleConfigParser
XmlRuleConfigParser
YamlRuleConfigParser
PropertiesRuleConfigParser

针对系统配置的解析器：基于接口 ISystemConfigParser
JsonSystemConfigParser
XmlSystemConfigParser
YamlSystemConfigParser
PropertiesSystemConfigParser
```

**过多的类也会让系统难维护，抽象工厂就是针对这种非常特殊的场景而诞生的**。我们可以让一个工厂负责创建多个不同类型的对象（IRuleConfigParser、ISystemConfigParser 等），而不是只创建一种 parser 对象。这样就可以有效地减少工厂类的个数：
```java
public interface IConfigParserFactory 
{
    IRuleConfigParser createRuleParser();
    ISystemConfigParser createSystemParser();
    // 此处可以扩展新的 parser 类型，比如 IBizConfigParser
}

public class JsonConfigParserFactory implements IConfigParserFactory 
{
    @Override
    public IRuleConfigParser createRuleParser() 
    {
        return new JsonRuleConfigParser();
    }

    @Override
    public ISystemConfigParser createSystemParser() 
    {
        return new JsonSystemConfigParser();
    }
}

public class XmlConfigParserFactory implements IConfigParserFactory 
{
    @Override
    public IRuleConfigParser createRuleParser() 
    {
        return new XmlRuleConfigParser();
    }

    @Override
    public ISystemConfigParser createSystemParser() 
    {
        return new XmlSystemConfigParser();
    }
}

// 省略 YamlConfigParserFactory 和 PropertiesConfigParserFactory 代码
```

## 工厂模式的作用
工厂模式的作用无外乎下面这四个。这也是判断要不要使用工厂模式的最本质的参考标准：
- **封装变化**：创建逻辑有可能变化，封装成工厂类之后，创建逻辑的变更对调用者透明；
- **代码复用**：创建代码抽离到独立的工厂类之后可以复用；
- **隔离复杂性**：封装复杂的创建逻辑，调用者无需了解如何创建对象；
- **控制复杂度**：将创建代码抽离出来，让原本的函数或类职责更单一，代码更简洁；

## 工厂模式和 DI 容器有何区别？
创建对象的“大工程” -- 依赖注入框架，或者叫`依赖注入容器`（Dependency Injection Container），简称 DI 容器。实际上，**DI 容器底层最基本的设计思路就是基于工厂模式的**。DI 容器相当于一个大的工厂类，负责在程序启动的时候，根据配置（要创建哪些类对象，每个类对象的创建需要依赖哪些其他类对象）事先创建好对象。当应用程序需要使用某个类对象的时候，直接从容器中获取即可。**正是因为它持有一堆对象，所以这个框架才被称为“容器”**。

工厂模式中，一个工厂类只负责某个类对象或者某一组相关类对象（继承自同一抽象类或者接口的子类）的创建，而 **DI 容器负责的是整个应用中所有类对象的创建**。除此之外，DI 容器负责的事情要比单纯的工厂模式要多。比如，它还包括配置的解析、对象生命周期的管理。

## DI 容器的核心功能有哪些？
一个简单的 DI 容器的核心功能一般有三个：配置解析、对象创建和对象生命周期管理。

### 配置解析
作为一个通用的框架来说，框架代码跟应用代码应该是高度解耦的，DI 容器事先并不知道应用会创建哪些对象，**不可能把某个应用要创建的对象写死在框架代码中**。所以，我们需要通过一种形式，让应用告知 DI 容器要创建哪些对象。

我们将需要由 DI 容器来创建的类对象和创建类对象的必要信息（使用哪个构造函数以及对应的构造函数参数都是什么等等），放到配置文件中。**容器读取配置文件，根据配置文件提供的信息来创建对象**。

下面是一个典型的 Spring 容器的配置文件。Spring 容器读取这个配置文件，解析出要创建的两个对象：rateLimiter 和 redisCounter，并且得到两者的依赖关系：
```java
public class RateLimiter 
{
    private RedisCounter redisCounter;
    public RateLimiter(RedisCounter redisCounter) 
    {
        this.redisCounter = redisCounter;
    }
    public void test() 
    {
        System.out.println("Hello World!");
    }
    //...
}

public class RedisCounter 
{
    private String ipAddress;
    private int port;
    public RedisCounter(String ipAddress, int port) 
    {
        this.ipAddress = ipAddress;
        this.port = port;
    }
    //...
}

配置文件 beans.xml：
<beans>
    <bean id="rateLimiter" class="com.xzg.RateLimiter">
        <constructor-arg ref="redisCounter"/>
    </bean>
    
    <bean id="redisCounter" class="com.xzg.redisCounter">
        <constructor-arg type="String" value="127.0.0.1">
        <constructor-arg type="int" value=1234>
    </bean>
</beans>
```

### 对象创建
在 DI 容器中，如果我们给每个类都对应创建一个工厂类，那项目中类的个数会成倍增加，这会增加代码的维护成本。要解决这个问题并不难。我们只需要**将所有类对象的创建都放到一个工厂类中完成**就可以了，比如 BeansFactory。

借助`反射语法`，**在程序运行的过程中动态地加载类、创建对象**，不需要事先在代码中写死要创建哪些对象。所以，BeansFactory 中的代码不会线性膨胀（代码量跟创建对象的个数成正比）。

### 对象生命周期管理
简单工厂模式有两种实现方式，一种是每次都返回新创建的对象，另一种是每次都返回同一个事先创建好的对象，也就是所谓的单例对象。在 Spring 框架中，我们可以**通过配置 scope 属性，来区分这两种不同类型的对象**。scope=prototype 表示返回新创建的对象，scope=singleton 表示返回单例对象。

除此之外，我们还可以**配置对象是否支持懒加载**。如果 lazy-init=true，对象在真正被使用到的时候（比如：BeansFactory.getBean(“userService”)）才被被创建；如果 lazy-init=false，对象在应用启动的时候就事先创建好。

不仅如此，我们还可以配置对象的 `init-method` 和 `destroy-method` 方法，比如 init-method=loadProperties()，destroy-method=updateConfigFile()。DI 容器在创建好对象之后，会主动调用 init-method 属性指定的方法来初始化对象。在对象被最终销毁之前，DI 容器会主动调用 destroy-method 属性指定的方法来做一些清理工作，比如释放数据库连接池、关闭文件。

## 如何实现一个简单的 DI 容器？
用 Java 语言来实现一个简单的 DI 容器，核心逻辑只需要包括这样两个部分：
1. 配置文件解析；
2. 根据配置文件，通过反射语法创建对象；

### 最小原型设计
像 Spring 框架这样的 DI 容器，它支持的配置格式非常灵活和复杂。为了**简化代码实现，重点讲解原理**，在最小原型中，我们只支持下面配置文件中涉及的配置语法：
```xml
配置文件 beans.xml
<beans>
    <bean id="rateLimiter" class="com.xzg.RateLimiter">
        <constructor-arg ref="redisCounter"/>
    </bean>
    
    <bean id="redisCounter" class="com.xzg.redisCounter" scope="singleton" lazy-init="true">
        <constructor-arg type="String" value="127.0.0.1">
        <constructor-arg type="int" value=1234>
    </bean>
</bean
```

最小原型的使用方式跟 Spring 框架非常类似，示例代码如下所示：
```java
public class Demo 
{
    public static void main(String[] args) 
    {
        ApplicationContext applicationContext = new ClassPathXmlApplicationContext("beans.xml");
        RateLimiter rateLimiter = (RateLimiter) applicationContext.getBean("rateLimiter");
        rateLimiter.test();
        //...
    }
}
```

### 提供执行入口
**面向对象设计的最后一步是：组装类并提供执行入口**。在这里，执行入口就是一组暴露给外部使用的接口和类。通过刚刚的最小原型使用示例代码，我们可以看出，执行入口主要包含两部分：ApplicationContext 和 ClassPathXmlApplicationContext。其中，ApplicationContext 是接口，ClassPathXmlApplicationContext 是接口的实现类：
```java
public interface ApplicationContext 
{
    Object getBean(String beanId);
}

public class ClassPathXmlApplicationContext implements ApplicationContext 
{
    private BeansFactory beansFactory;
    private BeanConfigParser beanConfigParser;

    public ClassPathXmlApplicationContext(String configLocation) 
    {
        this.beansFactory = new BeansFactory();
        this.beanConfigParser = new XmlBeanConfigParser();
        loadBeanDefinitions(configLocation);
    }

    private void loadBeanDefinitions(String configLocation) 
    {
        InputStream in = null;
        try 
        {
            in = this.getClass().getResourceAsStream("/" + configLocation);
            if (in == null) 
            {
                throw new RuntimeException("Can not find config file: " + configLocation);
            }
            List<BeanDefinition> beanDefinitions = beanConfigParser.parse(in);
            beansFactory.addBeanDefinitions(beanDefinitions);
        } 
        finally 
        {
            if (in != null) 
            {
                try 
                {
                    in.close();
                } 
                catch (IOException e) 
                {
                    // TODO: log error
                }
            }
        }
    }

    @Override
    public Object getBean(String beanId) 
    {
        return beansFactory.getBean(beanId);
    }
}
```

从上面的代码中，我们可以看出，ClassPathXmlApplicationContext 负责**组装 BeansFactory 和 BeanConfigParser 两个类，串联执行流程**：从 ClassPath 中加载 XML 格式的配置文件，通过 BeanConfigParser 解析为统一的 BeanDefinition 格式，然后，BeansFactory 根据 BeanDefinition 来创建对象。

### 配置文件解析
配置文件解析主要包含 BeanConfigParser 接口和 XmlBeanConfigParser 实现类，负责将配置文件解析为 BeanDefinition 结构，以便 BeansFactory 根据这个结构来创建对象：
```java
public interface BeanConfigParser 
{
    List<BeanDefinition> parse(InputStream inputStream);
    List<BeanDefinition> parse(String configContent);
}

public class XmlBeanConfigParser implements BeanConfigParser 
{
    @Override
    public List<BeanDefinition> parse(InputStream inputStream) 
    {
        String content = null;
        // TODO: ...
        return parse(content);
    }

    @Override
    public List<BeanDefinition> parse(String configContent) 
    {
        List<BeanDefinition> beanDefinitions = new ArrayList<>();
        // TODO: ...
        return beanDefinitions;
    }
}

public class BeanDefinition 
{
    private String id;
    private String className;
    private List<ConstructorArg> constructorArgs = new ArrayList<>();
    private Scope scope = Scope.SINGLETON;
    private boolean lazyInit = false;
    // 省略必要的 getter/setter/constructors
    
    public boolean isSingleton() 
    {
        return scope.equals(Scope.SINGLETON);
    }

    public static enum Scope 
    {
        SINGLETON,
        PROTOTYPE
    }
    
    public static class ConstructorArg 
    {
        private boolean isRef;
        private Class type;
        private Object arg;
        // 省略必要的 getter/setter/constructors
    }
}
```

### 核心工厂类设计
**BeansFactory 是 DI 容器最核心的一个类**。它负责根据从配置文件解析得到的 BeanDefinition 来创建对象。如果对象的 scope 属性是 singleton，那对象创建之后会缓存在 singletonObjects 这样一个 map 中，下次再请求此对象的时候，直接从 map 中取出返回，不需要重新创建。如果对象的 scope 属性是 prototype，那每次请求对象，BeansFactory 都会创建一个新的对象返回。

实际上，BeansFactory 创建对象用到的主要技术点就是 Java 中的**反射语法：一种动态加载类和创建对象的机制**。我们知道，JVM 在启动的时候会根据代码自动地加载类、创建对象。至于都要加载哪些类、创建哪些对象，这些都是在代码中写死的，或者说提前写好的。但是，如果某个对象的创建并不是写死在代码中，而是放到配置文件中，我们需要在程序运行期间，动态地根据配置文件来加载类、创建对象，那**这部分工作就没法让 JVM 帮我们自动完成**了，我们需要利用 Java 提供的反射语法自己去编写代码：
```java
public class BeansFactory 
{
    private ConcurrentHashMap<String, Object> singletonObjects = new ConcurrentHashMap<>();
    private ConcurrentHashMap<String, BeanDefinition> beanDefinitions = new ConcurrentHashMap<>();

    public void addBeanDefinitions(List<BeanDefinition> beanDefinitionList) 
    {
        for (BeanDefinition beanDefinition : beanDefinitionList) 
        {
            this.beanDefinitions.putIfAbsent(beanDefinition.getId(), beanDefinition);
        }

        for (BeanDefinition beanDefinition : beanDefinitionList) 
        {
            if (beanDefinition.isLazyInit() == false && beanDefinition.isSingleton()) 
            {
                createBean(beanDefinition);
            }
        }
    }

    public Object getBean(String beanId) 
    {
        BeanDefinition beanDefinition = beanDefinitions.get(beanId);
        if (beanDefinition == null) 
        {
            throw new NoSuchBeanDefinitionException("Bean is not defined: " + beanId);
        }
        return createBean(beanDefinition);
    }

    @VisibleForTesting
    protected Object createBean(BeanDefinition beanDefinition) 
    {
        if (beanDefinition.isSingleton() && singletonObjects.containsKey(beanDefinition.getId())) 
        {
            return singletonObjects.get(beanDefinition.getId());
        }

        Object bean = null;
        try 
        {
            Class beanClass = Class.forName(beanDefinition.getClassName());
            List<BeanDefinition.ConstructorArg> args = beanDefinition.getConstructorArgs();
            if (args.isEmpty()) 
            {
                bean = beanClass.newInstance();
            } 
            else 
            {
                Class[] argClasses = new Class[args.size()];
                Object[] argObjects = new Object[args.size()];
                for (int i = 0; i < args.size(); ++i) 
                {
                    BeanDefinition.ConstructorArg arg = args.get(i);
                    if (!arg.getIsRef()) 
                    {
                        argClasses[i] = arg.getType();
                        argObjects[i] = arg.getArg();
                    } 
                    else 
                    {
                        BeanDefinition refBeanDefinition = beanDefinitions.get(arg.getArg());
                        if (refBeanDefinition == null) 
                        {
                            throw new NoSuchBeanDefinitionException("Bean is not defined: " + arg.getArg());
                        }
                        argClasses[i] = Class.forName(refBeanDefinition.getClassName());
                        argObjects[i] = createBean(refBeanDefinition);
                    }
                }
                bean = beanClass.getConstructor(argClasses).newInstance(argObjects);
            }
        }
        catch (ClassNotFoundException | IllegalAccessException | InstantiationException | NoSuchMethodException | InvocationTargetException e) 
        {
            throw new BeanCreationFailureException("", e);
        }

        if (bean != null && beanDefinition.isSingleton()) 
        {
            singletonObjects.putIfAbsent(beanDefinition.getId(), bean);
            return singletonObjects.get(beanDefinition.getId());
        }
        return bean;
    }
}
```
