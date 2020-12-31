---
title: Template Method Design Pattern
date: 2020-12-16 23:24:34
tags:
  - GoF
---
## 模板模式的原理与实现
`模板模式`，全称是模板方法设计模式，英文是 Template Method Design Pattern。它是这么定义的：
> Define the skeleton of an algorithm in an operation, deferring some steps to subclasses. Template method lets subclasses redefine certain steps of an algorithm without changing the algorithm's structure.

翻译成中文就是：模板方法模式**在一个方法中定义一个算法骨架，并将某些步骤推迟到子类中实现**。模板方法模式可以让子类在不改变算法整体结构的情况下，重新定义算法中的某些步骤。这里的“算法”，我们**可以理解为广义上的“业务逻辑”，并不特指数据结构和算法中的“算法”**。这里的算法骨架就是“模板”，包含算法骨架的方法就是“模板方法”，这也是模板方法模式名字的由来。

原理很简单，代码实现就更加简单，我写了一个示例代码，templateMethod() 函数**定义为 final，是为了避免子类重写它**。method1() 和 method2() **定义为 abstract，是为了强迫子类去实现**。不过，这些都不是必须的，在实际的项目开发中，模板模式的代码实现比较灵活：
<!--more-->
```java
public abstract class AbstractClass 
{
    public final void templateMethod() 
    {
        //...
        method1();
        //...
        method2();
        //...
    }
    
    protected abstract void method1();
    protected abstract void method2();
}

public class ConcreteClass1 extends AbstractClass 
{
    @Override
    protected void method1() 
    {
        //...
    }
    
    @Override
    protected void method2() 
    {
        //...
    }
}

public class ConcreteClass2 extends AbstractClass 
{
    @Override
    protected void method1() 
    {
        //...
    }
    
    @Override
    protected void method2() 
    {
        //...
    }
}

AbstractClass demo = ConcreteClass1();
demo.templateMethod();
```

## 模板模式作用一：复用
模板模式**把一个算法中不变的流程抽象到父类的模板方法 templateMethod() 中，将可变的部分 method1()、method2() 留给子类 ConcreteClass1 和 ConcreteClass2 来实现**。所有的子类都可以复用父类中模板方法定义的流程代码。

### Java InputStream
在代码中，**read() 函数是一个模板方法，定义了读取数据的整个流程**，并且暴露了一个可以由子类来定制的抽象方法。不过这个方法也被命名为了 read()，只是参数跟模板方法不同：
```java
public abstract class InputStream implements Closeable 
{
    //...省略其他代码...
    
    public int read(byte b[], int off, int len) throws IOException 
    {
        if (b == null) 
        {
            throw new NullPointerException();
        } 
        else if (off < 0 || len < 0 || len > b.length - off) 
        {
            throw new IndexOutOfBoundsException();
        } 
        else if (len == 0) 
        {
            return 0;
        }

        int c = read();
        if (c == -1) 
        {
            return -1;
        }
        b[off] = (byte)c;

        int i = 1;
        try 
        {
            for (; i < len ; i++) 
            {
                c = read();
                if (c == -1) 
                {
                    break;
                }
                b[off + i] = (byte)c;
            }
        } 
        catch (IOException ee) {}
        return i;
    }
    
    public abstract int read() throws IOException;
}

public class ByteArrayInputStream extends InputStream 
{
    //...省略其他代码...
    
    @Override
    public synchronized int read() 
    {
        return (pos < count) ? (buf[pos++] & 0xff) : -1;
    }
}
```

### Java AbstractList
在 Java AbstractList 类中，addAll() 函数可以看作模板方法，add() 是子类需要重写的方法，尽管没有声明为 abstract 的，但函数实现**直接抛出了 UnsupportedOperationException 异常**（如果子类不重写是不能使用的）：
```java
public boolean addAll(int index, Collection<? extends E> c) 
{
    rangeCheckForAdd(index);
    boolean modified = false;
    for (E e : c) 
    {
        add(index++, e);
        modified = true;
    }
    return modified;
}

public void add(int index, E element) 
{
    throw new UnsupportedOperationException();
}
```

## 模板模式作用二：扩展
模板模式的第二大作用的是扩展。这里所说的扩展，并不是指代码的扩展性，而是指框架的扩展性，有点类似我们之前讲到的`控制反转`。基于这个作用，模板模式常用在框架的开发中，**让框架用户可以在不修改框架源码的情况下，定制化框架的功能**。

### Java Servlet
对于 Java Web 项目开发来说，如果我们抛开高级框架来开发 Web 项目，必然会用到 Servlet。实际上，使用比较底层的 Servlet 来开发 Web 项目也不难。我们**只需要定义一个继承 HttpServlet 的类，并且重写其中的 doGet() 或 doPost() 方法**，来分别处理 get 和 post 请求。具体的代码示例如下所示：
```java
public class HelloServlet extends HttpServlet 
{
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException 
    {
        this.doPost(req, resp);
    }
    
    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException 
    {
        resp.getWriter().write("Hello World.");
    }
}
```

除此之外，我们还需要在配置文件 web.xml 中做如下配置。**Tomcat、Jetty 等 Servlet 容器**在启动的时候，会自动加载这个配置文件中的 URL 和 Servlet 之间的映射关系：
```xml
<servlet>
    <servlet-name>HelloServlet</servlet-name>
    <servlet-class>com.xzg.cd.HelloServlet</servlet-class>
</servlet>

<servlet-mapping>
    <servlet-name>HelloServlet</servlet-name>
    <url-pattern>/hello</url-pattern>
</servlet-mapping>
```

当我们在浏览器中输入网址的时候，Servlet 容器会接收到相应的请求，并且根据 URL 和 Servlet 之间的映射关系，找到相应的 Servlet（HelloServlet），然后执行它的 service() 方法。service() 方法定义在父类 HttpServlet 中，它会调用 doGet() 或 doPost() 方法，然后输出数据（“Hello world”）到网页。

我们现在来看，HttpServlet 的 service() 函数长什么样子：
```java
public void service(ServletRequest req, ServletResponse res) throws ServletException, IOException
{
    HttpServletRequest  request;
    HttpServletResponse response;
    if (!(req instanceof HttpServletRequest && res instanceof HttpServletResponse)) 
    {
        throw new ServletException("non-HTTP request or response");
    }
    request = (HttpServletRequest) req;
    response = (HttpServletResponse) res;
    service(request, response);
}

protected void service(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException
{
    String method = req.getMethod();
    if (method.equals(METHOD_GET)) 
    {
        long lastModified = getLastModified(req);
        if (lastModified == -1) 
        {
            // servlet doesn't support if-modified-since, no reason
            // to go through further expensive logic
            doGet(req, resp);
        } 
        else 
        {
            long ifModifiedSince = req.getDateHeader(HEADER_IFMODSINCE);
            if (ifModifiedSince < lastModified) 
            {
                // If the servlet mod time is later, call doGet()
                // Round down to the nearest second for a proper compare
                // A ifModifiedSince of -1 will always be less
                maybeSetLastModified(resp, lastModified);
                doGet(req, resp);
            } 
            else 
            {
                resp.setStatus(HttpServletResponse.SC_NOT_MODIFIED);
            }
        }
    } 
    else if (method.equals(METHOD_HEAD)) 
    {
        long lastModified = getLastModified(req);
        maybeSetLastModified(resp, lastModified);
        doHead(req, resp);
    } 
    else if (method.equals(METHOD_POST)) 
    {
        doPost(req, resp);
    } 
    else if (method.equals(METHOD_PUT)) 
    {
        doPut(req, resp);
    } 
    else if (method.equals(METHOD_DELETE)) 
    {
        doDelete(req, resp);
    } 
    else if (method.equals(METHOD_OPTIONS)) 
    {
        doOptions(req,resp);
    } 
    else if (method.equals(METHOD_TRACE)) 
    {
        doTrace(req,resp);
    } 
    else 
    {
        String errMsg = lStrings.getString("http.method_not_implemented");
        Object[] errArgs = new Object[1];
        errArgs[0] = method;
        errMsg = MessageFormat.format(errMsg, errArgs);
        resp.sendError(HttpServletResponse.SC_NOT_IMPLEMENTED, errMsg);
    }
}
```

从上面的代码中我们可以看出，HttpServlet 的 service() 方法就是一个模板方法，它实现了整个 HTTP 请求的执行流程，doGet()、doPost() 是模板中可以由子类来定制的部分。实际上，这就**相当于 Servlet 框架提供了一个扩展点**，让框架用户在不用修改 Servlet 框架源码的情况下，将业务代码通过扩展点镶嵌到框架中执行。

### JUnit TestCase
在使用 JUnit 测试框架来编写单元测试的时候，我们编写的测试类都要继承框架提供的 TestCase 类。**在 TestCase 类中，runBare() 函数是模板方法，它定义了执行测试用例的整体流程**：先执行 setUp() 做些准备工作，然后执行 runTest() 运行真正的测试代码，最后执行 tearDown() 做扫尾工作。

尽管 setUp()、tearDown() 并不是抽象函数，还提供了默认的实现，**不强制子类去重新实现，但这部分也是可以在子类中定制的**，所以也符合模板模式的定义：
```java
public abstract class TestCase extends Assert implements Test 
{
    public void runBare() throws Throwable 
    {
        Throwable exception = null;
        setUp();
        try 
        {
            runTest();
        } 
        catch (Throwable running) 
        {
            exception = running;
        } 
        finally 
        {
            try 
            {
                tearDown();
            } 
            catch (Throwable tearingDown) 
            {
                if (exception == null) exception = tearingDown;
            }
        }
        if (exception != null) throw exception;
    }
    
    /**
     * Sets up the fixture, for example, open a network connection.
     * This method is called before a test is executed.
     */
    protected void setUp() throws Exception {}

    /**
     * Tears down the fixture, for example, close a network connection.
     * This method is called after a test is executed.
     */
    protected void tearDown() throws Exception {}
}
```

## 回调的原理解析
**相对于普通的函数调用来说，回调是一种双向调用关系**。A 类事先注册某个函数 F 到 B 类，A 类在调用 B 类的 P 函数的时候，B 类反过来调用 A 类注册给它的 F 函数。这里的 F 函数就是回调函数。A 调用 B，B 反过来又调用 A，这种调用机制就叫作`回调`。

不同的编程语言，有不同的实现方法。**C 语言可以使用函数指针，Java 则需要使用包裹了回调函数的类对象**，我们简称为回调对象。代码如下所示：
```java
public interface ICallback 
{
    void methodToCallback();
}

public class BClass 
{
    public void process(ICallback callback) 
    {
        //...
        callback.methodToCallback();
        //...
    }
}

public class AClass 
{
    public static void main(String[] args) 
    {
        BClass b = new BClass();
        b.process(new ICallback() 
        { 
            // 回调对象
            @Override
            public void methodToCallback() 
            {
                System.out.println("Callback me.");
            }
        });
    }
}
```

从代码实现中，我们可以看出，回调跟模板模式一样，也具有复用和扩展的功能。除了回调函数之外，**BClass 类的 process() 函数中的逻辑都可以复用**。如果 ICallback、BClass 类是框架代码，AClass 是使用框架的客户端代码，我们**可以通过 ICallback 定制 process() 函数**，也就是说，框架因此具有了扩展的能力。

实际上，**回调不仅可以应用在代码设计上，在更高层次的架构设计上也比较常用**。比如，通过三方支付系统来实现支付功能，用户在发起支付请求之后，一般不会一直阻塞到支付结果返回，而是注册回调接口（类似回调函数，一般是一个回调用的 URL）给三方支付系统，等三方支付系统执行完成之后，将结果通过回调接口返回给用户。

回调可以分为同步回调和异步回调。**同步回调指在函数返回之前执行回调函数；异步回调指的是在函数返回之后执行回调函数**。上面的代码实际上是同步回调的实现方式，在 process() 函数返回之前，执行完回调函数 methodToCallback()。而上面支付的例子是异步回调的实现方式，发起支付之后不需要等待回调接口被调用就直接返回。

> 从应用场景上来看，同步回调看起来更像模板模式，异步回调看起来更像观察者模式。

## 应用举例一：JdbcTemplate
Spring 提供了很多 Template 类，比如，JdbcTemplate、RedisTemplate、RestTemplate。**尽管都叫作 xxxTemplate，但它们并非基于模板模式来实现的**，而是基于回调来实现的，确切地说应该是同步回调。而同步回调从应用场景上很像模板模式，所以，在命名上，这些类使用 Template 这个单词作为后缀。

Java 提供了 JDBC 类库来封装不同类型的数据库操作。不过，直接使用 JDBC 来编写操作数据库的代码，还是有点复杂的。比如，下面这段是使用 JDBC 来查询用户信息的代码：
```java
public class JdbcDemo 
{
    public User queryUser(long id) 
    {
        Connection conn = null;
        Statement stmt = null;
        try 
        {
            // 1. 加载驱动
            Class.forName("com.mysql.jdbc.Driver");
            conn = DriverManager.getConnection("jdbc:mysql://localhost:3306/demo", "xzg", "xzg");

            // 2. 创建 statement 类对象，用来执行 SQL 语句
            stmt = conn.createStatement();

            // 3. ResultSet 类，用来存放获取的结果集
            String sql = "select * from user where id=" + id;
            ResultSet resultSet = stmt.executeQuery(sql);

            String eid = null, ename = null, price = null;

            while (resultSet.next()) 
            {
                User user = new User();
                user.setId(resultSet.getLong("id"));
                user.setName(resultSet.getString("name"));
                user.setTelephone(resultSet.getString("telephone"));
                return user;
            }
        } 
        catch (ClassNotFoundException e) 
        {
            // TODO: log...
        } 
        catch (SQLException e) 
        {
            // TODO: log...
        } 
        finally 
        {
            if (conn != null) 
            {
                try 
                {
                    conn.close();
                } 
                catch (SQLException e) 
                {
                    // TODO: log...
                }
            }
            if (stmt != null)
            {
                try 
                {
                    stmt.close();
                } 
                catch (SQLException e) 
                {
                    // TODO: log...
                }
            }
        }
        return null;
    }
}
```

queryUser() 函数包含很多流程性质的代码，跟业务无关，比如，加载驱动、创建数据库连接、创建 statement、关闭连接、关闭 statement、处理异常。**针对不同的 SQL 执行请求，这些流程性质的代码是相同的、可以复用的**，我们不需要每次都重新敲一遍。

针对这个问题，**Spring 提供了 JdbcTemplate，对 JDBC 进一步封装，来简化数据库编程**。使用 JdbcTemplate 查询用户信息，我们只需要编写跟这个业务有关的代码，其中包括，查询用户的 SQL 语句、查询结果与 User 对象之间的映射关系。其他流程性质的代码都封装在了 JdbcTemplate 类中，不需要我们每次都重新编写：
```java
public class JdbcTemplateDemo 
{
    private JdbcTemplate jdbcTemplate;

    public User queryUser(long id) 
    {
        String sql = "select * from user where id="+id;
        return jdbcTemplate.query(sql, new UserRowMapper()).get(0);
    }

    class UserRowMapper implements RowMapper<User> 
    {
        public User mapRow(ResultSet rs, int rowNum) throws SQLException 
        {
            User user = new User();
            user.setId(rs.getLong("id"));
            user.setName(rs.getString("name"));
            user.setTelephone(rs.getString("telephone"));
            return user;
        }
    }
}
```

我们来看一下 JdbcTemplate 的源码。其中，JdbcTemplate 通过回调的机制，**将不变的执行流程抽离出来，放到模板方法 execute() 中，将可变的部分设计成回调 StatementCallback，由用户来定制**。query() 函数是对 execute() 函数的二次封装，让接口用起来更加方便：
```java
@Override
public <T> List<T> query(String sql, RowMapper<T> rowMapper) throws DataAccessException 
{
    return query(sql, new RowMapperResultSetExtractor<T>(rowMapper));
}

@Override
public <T> T query(final String sql, final ResultSetExtractor<T> rse) throws DataAccessException 
{
    Assert.notNull(sql, "SQL must not be null");
    Assert.notNull(rse, "ResultSetExtractor must not be null");
    if (logger.isDebugEnabled()) 
    {
        logger.debug("Executing SQL query [" + sql + "]");
    }

    class QueryStatementCallback implements StatementCallback<T>, SqlProvider 
    {
        @Override
        public T doInStatement(Statement stmt) throws SQLException 
        {
            ResultSet rs = null;
            try 
            {
                rs = stmt.executeQuery(sql);
                ResultSet rsToUse = rs;
                if (nativeJdbcExtractor != null) 
                {
                    rsToUse = nativeJdbcExtractor.getNativeResultSet(rs);
                }
                return rse.extractData(rsToUse);
            }
            finally 
            {
                JdbcUtils.closeResultSet(rs);
            }
        }
        @Override
        public String getSql() 
        {
            return sql;
        }
    }
    return execute(new QueryStatementCallback());
}

@Override
public <T> T execute(StatementCallback<T> action) throws DataAccessException 
{
    Assert.notNull(action, "Callback object must not be null");

    Connection con = DataSourceUtils.getConnection(getDataSource());
    Statement stmt = null;
    try 
    {
        Connection conToUse = con;
        if (this.nativeJdbcExtractor != null && this.nativeJdbcExtractor.isNativeConnectionNecessaryForNativeStatements()) 
        {
            conToUse = this.nativeJdbcExtractor.getNativeConnection(con);
        }
        stmt = conToUse.createStatement();
        applyStatementSettings(stmt);
        Statement stmtToUse = stmt;
        if (this.nativeJdbcExtractor != null) 
        {
            stmtToUse = this.nativeJdbcExtractor.getNativeStatement(stmt);
        }
        T result = action.doInStatement(stmtToUse);
        handleWarnings(stmt);
        return result;
    }
    catch (SQLException ex) 
    {
        // Release Connection early, to avoid potential connection pool deadlock
        // in the case when the exception translator hasn't been initialized yet.
        JdbcUtils.closeStatement(stmt);
        stmt = null;
        DataSourceUtils.releaseConnection(con, getDataSource());
        con = null;
        throw getExceptionTranslator().translate("StatementCallback", getSql(action), ex);
    }
    finally 
    {
        JdbcUtils.closeStatement(stmt);
        DataSourceUtils.releaseConnection(con, getDataSource());
    }
}
```

## 应用举例二：setClickListener(）
**在客户端开发中，我们经常给控件注册事件监听器**，比如下面这段代码，就是在 Android 应用开发中，给 Button 控件的点击事件注册监听器：
```java
Button button = (Button)findViewById(R.id.button);
button.setOnClickListener(new OnClickListener() 
{
    @Override
    public void onClick(View v) 
    {
        System.out.println("I am clicked.");
    }
});
```

从代码结构上来看，事件监听器很像回调，即传递一个包含回调函数（onClick()）的对象给另一个函数。从应用场景上来看，它又很像观察者模式，即事先注册观察者（OnClickListener），当用户点击按钮的时候，发送点击事件给观察者，并且执行相应的 onClick() 函数。**这里的回调算是异步回调，我们往 setOnClickListener() 函数中注册好回调函数之后，并不需要等待回调函数执行**。

## 应用举例三：addShutdownHook()
Hook 是 Callback 的一种应用。**Callback 更侧重语法机制的描述，Hook 更加侧重应用场景的描述**。Hook 比较经典的应用场景是 Tomcat 和 JVM 的 shutdown hook。JVM 提供了 Runtime.addShutdownHook(Thread hook) 方法，可以注册一个 JVM 关闭的 Hook。当应用程序关闭的时候，JVM 会自动调用 Hook 代码。代码示例如下所示：
```java
public class ShutdownHookDemo 
{
    private static class ShutdownHook extends Thread 
    {
        public void run() 
        {
            System.out.println("I am called during shutting down.");
        }
    }

    public static void main(String[] args) 
    {
        Runtime.getRuntime().addShutdownHook(new ShutdownHook());
    }
}
```

我们再来看 addShutdownHook() 的代码实现，如下所示：
```java
public class Runtime 
{
    public void addShutdownHook(Thread hook) 
    {
        SecurityManager sm = System.getSecurityManager();
        if (sm != null) 
        {
            sm.checkPermission(new RuntimePermission("shutdownHooks"));
        }
        ApplicationShutdownHooks.add(hook);
    }
}

class ApplicationShutdownHooks 
{
    /* The set of registered hooks */
    private static IdentityHashMap<Thread, Thread> hooks;
    static 
    {
        try
        {
            hooks = new IdentityHashMap<>();
        } 
        catch (IllegalStateException e) 
        {
            hooks = null;
        }
    }

    static synchronized void add(Thread hook) 
    {
        if(hooks == null)
        {
            throw new IllegalStateException("Shutdown in progress");
        }

        if (hook.isAlive())
        {
            throw new IllegalArgumentException("Hook already running");
        }

        if (hooks.containsKey(hook))
        {
            throw new IllegalArgumentException("Hook previously registered");
        }

        hooks.put(hook, hook);
    }

    static void runHooks() 
    {
        Collection<Thread> threads;
        synchronized(ApplicationShutdownHooks.class) 
        {
            threads = hooks.keySet();
            hooks = null;
        }

        for (Thread hook : threads) 
        {
            hook.start();
        }
        for (Thread hook : threads) 
        {
            while (true) 
            {
                try 
                {
                    hook.join();
                    break;
                } 
                catch (InterruptedException ignored) {}
            }
        }
    }
}
```

从代码中我们可以发现，有关 Hook 的逻辑都被封装到 ApplicationShutdownHooks 类中了。当应用程序关闭的时候，JVM 会调用这个类的 runHooks() 方法，创建多个线程，并发地执行多个 Hook。**我们在注册完 Hook 之后，并不需要等待 Hook 执行完成**，所以，这也算是一种异步回调。

## 模板模式 vs. 回调
接下来，我们从应用场景和代码实现两个角度，来对比一下模板模式和回调。

### 应用场景
从应用场景上来看，**同步回调跟模板模式几乎一致**。它们都是在一个大的算法骨架中，自由替换其中的某个步骤，起到代码复用和扩展的目的。而**异步回调跟模板模式有较大差别，更像是观察者模式**。

### 代码实现
从代码实现上来看，回调和模板模式完全不同。**回调基于组合关系来实现，把一个对象传递给另一个对象，是一种对象之间的关系**；**模板模式基于继承关系来实现，子类重写父类的抽象方法，是一种类之间的关系**。

组合优于继承，这里也不例外。在代码实现上，回调相对于模板模式会更加灵活，主要体现在下面几点：
- 像 Java 这种只支持单继承的语言，基于模板模式编写的子类，已经继承了一个父类，**不再具有继承的能力**；
- 回调可以使用匿名类来创建回调对象，**可以不用事先定义类**；而模板模式针对不同的实现都要定义不同的子类；
- 如果某个类中定义了多个模板方法，每个方法都有对应的抽象方法，那即便我们只用到其中的一个模板方法，子类也必须实现所有的抽象方法。而回调就更加灵活，我们**只需要往用到的模板方法中注入回调对象即可**；
