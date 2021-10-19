---
title: MyBatis
date: 2021-03-31 11:14:09
tags:
  - OpenSource
---
## MyBatis 和 ORM 框架介绍
MyBatis 是一个 ORM（Object-Relational Mapping）框架。ORM 框架主要是根据类和数据库表之间的映射关系，帮助程序员自动实现对象与数据库中数据之间的互相转化。说得更具体点就是，**ORM 负责将程序中的对象存储到数据库中、将数据库中的数据转化为程序中的对象**。实际上，Java 中的 ORM 框架有很多，除了刚刚提到的 MyBatis 之外，还有 Hibernate、TopLink 等。

如果用一句话来总结框架作用的话，那就是简化开发。MyBatis 框架也不例外，它**简化的是数据库方面的开发**。因为 MyBatis 依赖 JDBC 驱动，所以，在项目中使用 MyBatis，除了需要引入 MyBatis 框架本身（mybatis.jar）之外，还需要引入 JDBC 驱动（比如，访问 MySQL 的 JDBC 驱动实现类库 mysql-connector-java.jar）。将两个 jar 包引入项目之后，我们就可以开始编程了。使用 MyBatis 来访问数据库中用户信息的代码如下所示：
<!--more-->
```java
// 1. 定义 UserDO
public class UserDo {
    private long id;
    private String name;
    private String telephone;
    // 省略 setter/getter 方法
}

// 2. 定义访问接口
public interface UserMapper {
    public UserDo selectById(long id);
}

// 3. 定义映射关系：UserMapper.xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org/DTD Mapper 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="cn.xzg.cd.a87.repo.mapper.UserMapper">
    <select id="selectById" resultType="cn.xzg.cd.a87.repo.UserDo">
        select * from user where id=#{id}
    </select>
</mapper>

// 4. 全局配置文件：mybatis.xml
<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE configuration PUBLIC "-//mybatis.org//DTD Config 3.0//EN"
    "http://mybatis.org/dtd/mybatis-3-config.dtd">
<configuration>
    <environments default="dev">
        <environment id="dev">
            <transactionManager type="JDBC"></transactionManager>
            <dataSource type="POOLED">
                <property name="driver" value="com.mysql.jdbc.Driver" />
                <property name="url" value="jdbc:mysql://localhost:3306/test?useUnicode=true&characterEncoding=UTF-8" />
                <property name="username" value="root" />
                <property name="password" value="..." />
            </dataSource>
        </environment>
    </environments>
    <mappers>
        <mapper resource="mapper/UserMapper.xml"/>
    </mappers>
</configuration>
```

需要注意的是，在 UserMapper.xml 配置文件中，我们只定义了接口和 SQL 语句之间的映射关系，并没有显式地定义类（UserDo）字段与数据库表（user）字段之间的映射关系。实际上，这就体现了**约定优于配置**的设计原则。类字段与数据库表字段之间使用了默认映射关系：类字段跟数据库表中拼写相同的字段一一映射。当然，如果没办法做到一一映射，我们也可以自定义它们之间的映射关系。有了上面的代码和配置，我们就可以像下面这样来访问数据库中的用户信息了：
```java
public class MyBatisDemo {
    public static void main(String[] args) throws IOException {
        Reader reader = Resources.getResourceAsReader("mybatis.xml");
        SqlSessionFactory sessionFactory = new SqlSessionFactoryBuilder().build(reader);
        SqlSession session = sessionFactory.openSession();
        UserMapper userMapper = session.getMapper(UserMapper.class);
        UserDo userDo = userMapper.selectById(8);
        //...
    }
}
```

从代码中，我们可以看出，相对于使用 JdbcTemplate 的实现方式，使用 MyBatis 的实现方式更加灵活。在使用 JdbcTemplate 的实现方式中，对象与数据库中数据之间的转化代码、SQL 语句，是硬编码在业务代码中的。而在使用 MyBatis 的实现方式中，类字段与数据库字段之间的映射关系、接口与 SQL 之间的映射关系，是写在 XML 配置文件中的，是跟代码相分离的，这样会更加灵活、清晰，维护起来更加方便。

## 如何平衡易用性、性能和灵活性？
我们先来看 JdbcTemplate。相对于 MyBatis 来说，JdbcTemplate 更加轻量级。因为它对 JDBC 只做了很简单的封装，所以性能损耗比较少。相对于其他两个框架来说，它的性能最好。但是，它的缺点也比较明显，那就是 SQL 与代码耦合在一起，而且不具备 ORM 的功能，需要自己编写代码，解析对象跟数据库中的数据之间的映射关系。所以，在易用性上它不及其他两个框架；我们再来看 Hibernate。相对于 MyBatis 来说，Hibernate 更加重量级。Hibernate 提供了更加高级的映射功能，能够根据业务需求自动生成 SQL 语句。我们不需要像使用 MyBatis 那样自己编写 SQL。因此，有的时候，我们也**把 MyBatis 称作半自动化的 ORM 框架，把 Hibernate 称作全自动化的 ORM 框架**。不过，虽然自动生成 SQL 简化了开发，但是毕竟是自动生成的，没有针对性的优化。在性能方面，这样得到的 SQL 可能没有程序员编写得好。同时，这样也丧失了程序员自己编写 SQL 的灵活性。

实际上，不管用哪种实现方式，从数据库中取出数据并且转化成对象，这个过程涉及的代码逻辑基本是一致的。不同实现方式的区别，只不过是哪部分代码逻辑放到了哪里。有的框架提供的功能比较强大，大部分代码逻辑都由框架来完成，程序员只需要实现很小的一部分代码就可以了，这样框架的易用性就更好些。但是，框架集成的功能越多，为了处理逻辑的通用性，就会引入更多额外的处理代码。比起针对具体问题具体编程，这样性能损耗就相对大一些。所以，粗略地讲，有的时候，框架的易用性和性能成对立关系。**追求易用性，那性能就差一些；相反，追求性能，易用性就差一些**。除此之外，使用起来越简单，那灵活性就越差。这就好比我们用的照相机，傻瓜相机按下快门就能拍照，但没有复杂的单反灵活。

JdbcTemplate 提供的功能最简单，易用性最差，性能损耗最少，用它编程性能最好。Hibernate 提供的功能最完善，易用性最好，但相对来说性能损耗就最高了。MyBatis 介于两者中间，在易用性、性能、灵活性三个方面做到了权衡。它支撑程序员自己编写 SQL，能够延续程序员对 SQL 知识的积累。相对于完全黑盒子的 Hibernate，很多程序员反倒是更加喜欢 MyBatis 这种半透明的框架。这也提醒我们，**过度封装，提供过于简化的开发方式，也会丧失开发的灵活性**。

## MyBatis Plugin 功能介绍
实际上，MyBatis Plugin 跟 Servlet Filter、Spring Interceptor 的功能是类似的，都是**在不需要修改原有流程代码的情况下，拦截某些方法调用，在拦截的方法调用的前后，执行一些额外的代码逻辑**。它们的唯一区别在于拦截的位置是不同的。Servlet Filter 主要拦截 Servlet 请求，Spring Interceptor 主要拦截 Spring 管理的 Bean 方法（比如 Controller 类的方法等），而 MyBatis Plugin 主要拦截的是 MyBatis 在执行 SQL 的过程中涉及的一些方法。

假设我们需要统计应用中每个 SQL 的执行耗时，如果使用 MyBatis Plugin 来实现的话，我们**只需要定义一个 SqlCostTimeInterceptor 类，让它实现 MyBatis 的 Interceptor 接口，并且，在 MyBatis 的全局配置文件中，简单声明一下这个插件就可以了**。具体的代码和配置如下所示：
```java
@Intercepts({
    @Signature(type = StatementHandler.class, method = "query", args = {Statement.class, ResultHandler.class}),
    @Signature(type = StatementHandler.class, method = "update", args = {Statement.class}),
    @Signature(type = StatementHandler.class, method = "batch", args = {Statement.class})})
public class SqlCostTimeInterceptor implements Interceptor {
    private static Logger logger = LoggerFactory.getLogger(SqlCostTimeInterceptor.class);

    @Override
    public Object intercept(Invocation invocation) throws Throwable {
        Object target = invocation.getTarget();
        long startTime = System.currentTimeMillis();
        StatementHandler statementHandler = (StatementHandler) target;
        try {
            return invocation.proceed();
        } 
        finally {
            long costTime = System.currentTimeMillis() - startTime;
            BoundSql boundSql = statementHandler.getBoundSql();
            String sql = boundSql.getSql();
            logger.info("执行 SQL：[ {} ]执行耗时[ {} ms]", sql, costTime);
        }
    }

    @Override
    public Object plugin(Object target) {
        return Plugin.wrap(target, this);
    }

    @Override
    public void setProperties(Properties properties) {
        System.out.println("插件配置的信息："+properties);
    }
}

<!-- MyBatis 全局配置文件：mybatis-config.xml -->
<plugins>
    <plugin interceptor="com.xzg.cd.a88.SqlCostTimeInterceptor">
        <property name="someProperty" value="100"/>
    </plugin>
</plugins>
```

我们知道，**不管是拦截器、过滤器还是插件，都需要明确地标明拦截的目标方法**。@Intercepts 注解实际上就是起了这个作用。其中，@Intercepts 注解又可以嵌套 @Signature 注解。一个 @Signature 注解标明一个要拦截的目标方法。如果要拦截多个方法，我们可以像例子中那样，编写多条 @Signature 注解。@Signature 注解包含三个元素：type、method、args。其中，type 指明要拦截的类、method 指明方法名、args 指明方法的参数列表。通过指定这三个元素，我们就能完全确定一个要拦截的方法。默认情况下，MyBatis Plugin 允许拦截的方法有下面这样几个：
![](https://raw.githubusercontent.com/necusjz/p/master/OpenSource/geek/26.png)

MyBatis 底层是通过 Executor 类来执行 SQL 的。Executor 类会创建 StatementHandler、ParameterHandler、ResultSetHandler 三个对象，并且，首先使用 ParameterHandler 设置 SQL 中的占位符参数，然后使用 StatementHandler 执行 SQL 语句，最后使用 ResultSetHandler 封装执行结果。所以，我们**只需要拦截 Executor、ParameterHandler、ResultSetHandler、StatementHandler 这几个类的方法，基本上就能满足我们对整个 SQL 执行流程的拦截了**。

实际上，除了统计 SQL 的执行耗时，利用 MyBatis Plugin，我们还可以做很多事情，比如分库分表、自动分页、数据脱敏、加密解密等等。如果感兴趣的话，你可以自己实现一下。

## MyBatis Plugin 的设计与实现
职责链模式的实现一般包含处理器和处理器链两部分。这两个部分对应到 Servlet Filter 的源码就是 Filter 和 FilterChain，对应到 Spring Interceptor 的源码就是 HandlerInterceptor 和 HandlerExecutionChain，对应到 MyBatis Plugin 的源码就是 Interceptor 和 InterceptorChain。除此之外，MyBatis Plugin 还包含另外一个非常重要的类：**Plugin 类，它用来生成被拦截对象的动态代理**。

在这三种应用场景中，职责链模式的实现思路都不大一样。其中，**Servlet Filter 采用递归来实现拦截方法前后添加逻辑。Spring Interceptor 的实现比较简单，把拦截方法前后要添加的逻辑放到两个方法中实现**。MyBatis Plugin 采用嵌套动态代理的方法来实现，实现思路很有技巧。

## SqlSessionFactoryBuilder：为什么要用建造者模式来创建？
我们通过一个查询用户的例子展示了用 MyBatis 进行数据库编程：
```java
public class MyBatisDemo {
    public static void main(String[] args) throws IOException {
        Reader reader = Resources.getResourceAsReader("mybatis.xml");
        SqlSessionFactory sessionFactory = new SqlSessionFactoryBuilder().build(reader);
        SqlSession session = sessionFactory.openSession();
        UserMapper userMapper = session.getMapper(UserMapper.class);
        UserDo userDo = userMapper.selectById(8);
        //...
    }
}
```

之前讲到建造者模式的时候，我们使用 Builder 类来创建对象，一般都是先级联一组 setXXX() 方法来设置属性，然后再调用 build() 方法最终创建对象。但是，在上面这段代码中，**通过 SqlSessionFactoryBuilder 来创建 SqlSessionFactory 并不符合这个套路。它既没有 setter 方法，而且 build() 方法也并非无参，需要传递参数**。除此之外，从上面的代码来看，SqlSessionFactory 对象的创建过程也并不复杂。那直接通过构造函数来创建 SqlSessionFactory 不就行了吗？为什么还要借助建造者模式创建 SqlSessionFactory 呢？SqlSessionFactoryBuilder 类中有大量的 build() 重载函数：
```java
public class SqlSessionFactoryBuilder {
    public SqlSessionFactory build(Reader reader);
    public SqlSessionFactory build(Reader reader, String environment);
    public SqlSessionFactory build(Reader reader, Properties properties);
    public SqlSessionFactory build(Reader reader, String environment, Properties properties);
    
    public SqlSessionFactory build(InputStream inputStream);
    public SqlSessionFactory build(InputStream inputStream, String environment);
    public SqlSessionFactory build(InputStream inputStream, Properties properties);
    public SqlSessionFactory build(InputStream inputStream, String environment, Properties properties);

    // 上面所有的方法最终都调用这个方法    
    public SqlSessionFactory build(Configuration config);
}
```

从建造者模式的设计初衷上来看，SqlSessionFactoryBuilder 虽然带有 Builder 后缀，但不要被它的名字所迷惑，它并不是标准的建造者模式。一方面，原始类 SqlSessionFactory 的构建只需要一个参数，并不复杂。另一方面，Builder 类 SqlSessionFactoryBuilder 仍然定义了 n 多包含不同参数列表的构造函数。实际上，SqlSessionFactoryBuilder 设计的初衷只不过是为了简化开发。因为构建 SqlSessionFactory 需要先构建 Configuration，而构建 Configuration 是非常复杂的，需要做很多工作，比如配置的读取、解析、创建 n 多对象等。**为了将构建 SqlSessionFactory 的过程隐藏起来，对程序员透明，MyBatis 就设计了 SqlSessionFactoryBuilder 类封装这些构建细节**。

## SqlSessionFactory：到底属于工厂模式还是建造者模式？
从名字上，你可能已经猜到，SqlSessionFactory 是一个工厂类，用到的设计模式是工厂模式。不过，它跟 SqlSessionFactoryBuilder 类似，名字有很大的迷惑性。实际上，它也并不是标准的工厂模式：
```java
public interface SqlSessionFactory {
    SqlSession openSession();
    SqlSession openSession(boolean autoCommit);
    SqlSession openSession(Connection connection);
    SqlSession openSession(TransactionIsolationLevel level);
    SqlSession openSession(ExecutorType execType);
    SqlSession openSession(ExecutorType execType, boolean autoCommit);
    SqlSession openSession(ExecutorType execType, TransactionIsolationLevel level);
    SqlSession openSession(ExecutorType execType, Connection connection);
    Configuration getConfiguration();
}
```

**SqlSessionFactory 是一个接口，DefaultSqlSessionFactory 是它唯一的实现类**。从 SqlSessionFactory 和 DefaultSqlSessionFactory 的源码来看，它的设计非常类似刚刚讲到的 SqlSessionFactoryBuilder，通过重载多个 openSession() 函数，支持通过组合 autoCommit、Executor、Transaction 等不同参数，来创建 SqlSession 对象。标准的工厂模式通过 type 来创建继承同一个父类的不同子类对象，而这里只不过是通过传递进不同的参数，来创建同一个类的对象。所以，它更像建造者模式。

实际上，**这两个类的作用只不过是为了创建 SqlSession 对象，没有其他作用**。所以，我更建议参照 Spring 的设计思路，把 SqlSessionFactoryBuilder 和 SqlSessionFactory 的逻辑，放到一个叫“ApplicationContext”的类中。让这个类来全权负责读入配置文件，创建 Configuration，生成 SqlSession。

## BaseExecutor：模板模式跟普通的继承有什么区别？
如果去查阅 SqlSession 与 DefaultSqlSession 的源码，你会发现，**SqlSession 执行 SQL 的业务逻辑，都是委托给了 Executor 来实现**。Executor 相关的类主要是用来执行 SQL。其中，Executor 本身是一个接口；BaseExecutor 是一个抽象类，实现了 Executor 接口；而 BatchExecutor、SimpleExecutor、ReuseExecutor 三个类继承 BaseExecutor 抽象类。那 BatchExecutor、SimpleExecutor、ReuseExecutor 三个类跟 BaseExecutor 是简单的继承关系，还是模板模式关系呢？怎么来判断呢？

模板模式基于继承来实现代码复用。如果抽象类中包含模板方法，模板方法调用有待子类实现的抽象方法，那这一般就是模板模式的代码实现。而且，**在命名上，模板方法与抽象方法一般是一一对应的，抽象方法在模板方法前面多一个“do”**，比如，在 BaseExecutor 类中，其中一个模板方法叫 update()，那对应的抽象方法就叫 doUpdate()。

## SqlNode：如何利用解释器模式来解析动态 SQL？
**支持配置文件中编写动态 SQL，是 MyBatis 一个非常强大的功能**。所谓动态 SQL，就是在 SQL 中可以包含在 trim、if、#{} 等语法标签，在运行时根据条件来生成不同的 SQL：
```xml
<update id="update" parameterType="com.xzg.cd.a89.User"
    UPDATE user
    <trim prefix="SET" prefixOverrides=",">
        <if test="name != null and name != ''">
            name = #{name}
        </if>
        <if test="age != null and age != ''">
            , age = #{age}
        </if>
        <if test="birthday != null and birthday != ''">
            , birthday = #{birthday}
        </if>
    </trim>
    where id = ${id}
</update>
```

显然，动态 SQL 的语法规则是 MyBatis 自定义的。如果想要根据语法规则，替换掉动态 SQL 中的动态元素，生成真正可以执行的 SQL 语句，MyBatis 还需要实现对应的解释器。这一部分功能就可以看做是解释器模式的应用。实际上，如果你去查看它的代码实现，你会发现，它跟我们在前面讲解释器模式时举的那两个例子的代码结构非常相似。**解释器模式在解释语法规则的时候，一般会把规则分割成小的单元，特别是可以嵌套的小单元，针对每个小单元来解析，最终再把解析结果合并在一起**。这里也不例外。MyBatis 把每个语法小单元叫 SqlNode：
```java
public interface SqlNode {
    boolean apply(DynamicContext context);
}
```

整个解释器的调用入口在 DynamicSqlSource.getBoundSql 方法中，它调用了 rootSqlNode.apply(context) 方法。对于不同的语法小单元，MyBatis 定义不同的 SqlNode 实现类：
![](https://raw.githubusercontent.com/necusjz/p/master/OpenSource/geek/27.png)

## ErrorContext：如何实现一个线程唯一的单例模式？
在 MyBatis 中，ErrorContext 这个类就是标准单例的变形：线程唯一的单例。它**基于 Java 中的 ThreadLocal 来实现**：
```java
public class ErrorContext {
    private static final String LINE_SEPARATOR = System.getProperty("line.separator","\n");
    private static final ThreadLocal<ErrorContext> LOCAL = new ThreadLocal<ErrorContext>();

    private ErrorContext stored;
    private String resource;
    private String activity;
    private String object;
    private String message;
    private String sql;
    private Throwable cause;

    private ErrorContext() {
    }

    public static ErrorContext instance() {
        ErrorContext context = LOCAL.get();
        if (context == null) {
            context = new ErrorContext();
            LOCAL.set(context);
        }
        return context;
    }
}
```

## Cache：为什么要用装饰器模式而不设计成继承子类？
在 MyBatis 中，缓存功能由接口 Cache 定义。PerpetualCache 类是最基础的缓存类，是一个大小无限的缓存。除此之外，MyBatis 还设计了 9 个包裹 PerpetualCache 类的装饰器类，用来实现功能增强。它们分别是：FifoCache、LoggingCache、LruCache、ScheduledCache、SerializedCache、SoftCache、SynchronizedCache、WeakCache、TransactionalCache：
```java
public interface Cache {
    String getId();
    void putObject(Object key, Object value);
    Object getObject(Object key);
    Object removeObject(Object key);
    void clear();
    int getSize();
    ReadWriteLock getReadWriteLock();
}

public class PerpetualCache implements Cache {
    private final String id;
    private Map<Object, Object> cache = new HashMap<Object, Object>();

    public PerpetualCache(String id) {
        this.id = id;
    }

    @Override
    public String getId() {
        return id;
    }

    @Override
    public int getSize() {
        return cache.size();
    }

    @Override
    public void putObject(Object key, Object value) {
        cache.put(key, value);
    }

    @Override
    public Object getObject(Object key) {
        return cache.get(key);
    }

    @Override
    public Object removeObject(Object key) {
        return cache.remove(key);
    }

    @Override
    public void clear() {
        cache.clear();
    }

    @Override
    public ReadWriteLock getReadWriteLock() {
        return null;
    }
    //省略部分代码...
}
```

之所以 MyBatis 采用装饰器模式来实现缓存功能，是因为**装饰器模式采用了组合，而非继承，更加灵活，能够有效地避免继承关系的组合爆炸**。

## PropertyTokenizer：如何利用迭代器模式实现一个属性解析器？
Mybatis 的 PropertyTokenizer 类实现了 Java Iterator 接口，是一个迭代器，用来对配置属性进行解析：
```java
// person[0].birthdate.year 会被分解为 3 个 PropertyTokenizer 对象。其中，第一个 PropertyTokenizer 对象的各个属性值如注释所示
public class PropertyTokenizer implements Iterator<PropertyTokenizer> {
    private String name; // person
    private final String indexedName; // person[0]
    private String index; // 0
    private final String children; // birthdate.year

    public PropertyTokenizer(String fullname) {
        int delim = fullname.indexOf('.');
        if (delim > -1) {
            name = fullname.substring(0, delim);
            children = fullname.substring(delim + 1);
        } 
        else {
            name = fullname;
            children = null;
        }
        indexedName = name;
        delim = name.indexOf('[');
        if (delim > -1) {
            index = name.substring(delim + 1, name.length() - 1);
            name = name.substring(0, delim);
        }
    }

    public String getName() {
        return name;
    }

    public String getIndex() {
        return index;
    }

    public String getIndexedName() {
        return indexedName;
    }

    public String getChildren() {
        return children;
    }

    @Override
    public boolean hasNext() {
        return children != null;
    }

    @Override
    public PropertyTokenizer next() {
        return new PropertyTokenizer(children);
    }

    @Override
    public void remove() {
        throw new UnsupportedOperationException("Remove is not supported, as it has no meaning in the context of properties.");
    }
}
```

实际上，PropertyTokenizer 类也并非标准的迭代器类。它将配置的解析、解析之后的元素、迭代器，这三部分本该放到三个类中的代码，都耦合在一个类中，所以看起来稍微有点难懂。不过，**这样做的好处是能够做到惰性解析**。我们不需要事先将整个配置，解析成多个 PropertyTokenizer 对象。只有当我们在调用 next() 函数的时候，才会解析其中部分配置。

## Log：如何使用适配器模式来适配不同的日志框架？
MyBatis 并没有直接使用 Slf4j 提供的统一日志规范，而是自己又重复造轮子，定义了一套自己的日志访问接口：
```java
public interface Log {
    boolean isDebugEnabled();
    boolean isTraceEnabled();
    void error(String s, Throwable e);
    void error(String s);
    void debug(String s);
    void trace(String s);
    void warn(String s);
}
```

针对 Log 接口，MyBatis 还提供了各种不同的实现类，分别使用不同的日志框架来实现 Log 接口：
![](https://raw.githubusercontent.com/necusjz/p/master/OpenSource/geek/28.png)

我们知道，在适配器模式中，传递给适配器构造函数的是被适配的类对象，而这里是 clazz（相当于日志名称 name），所以，从代码实现上来讲，它并非标准的适配器模式。但是，**从应用场景上来看，这里确实又起到了适配的作用，是典型的适配器模式的应用场景**：
```java
import org.apache.ibatis.logging.Log;
import org.apache.log4j.Level;
import org.apache.log4j.Logger;

public class Log4jImpl implements Log {
    private static final String FQCN = Log4jImpl.class.getName();
    private final Logger log;

    public Log4jImpl(String clazz) {
        log = Logger.getLogger(clazz);
    }

    @Override
    public boolean isDebugEnabled() {
        return log.isDebugEnabled();
    }

    @Override
    public boolean isTraceEnabled() {
        return log.isTraceEnabled();
    }

    @Override
    public void error(String s, Throwable e) {
        log.log(FQCN, Level.ERROR, s, e);
    }

    @Override
    public void error(String s) {
        log.log(FQCN, Level.ERROR, s, null);
    }

    @Override
    public void debug(String s) {
        log.log(FQCN, Level.DEBUG, s, null);
    }

    @Override
    public void trace(String s) {
        log.log(FQCN, Level.TRACE, s, null);
    }

    @Override
    public void warn(String s) {
        log.log(FQCN, Level.WARN, s, null);
    }
}
```
