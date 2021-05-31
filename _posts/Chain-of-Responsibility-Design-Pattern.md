---
title: Chain of Responsibility Design Pattern
date: 2020-12-20 00:34:22
tags:
  - GoF
---
## 职责链模式的原理和实现
`职责链模式`的英文翻译是 Chain of Responsibility Design Pattern。它是这么定义的：
> Avoid coupling the sender of a request to its receiver by giving more than one object a chance to handle the request. Chain the receiving objects and pass the request along the chain until an object handles it.

翻译成中文就是：将请求的发送和接收解耦，让多个接收对象都有机会处理这个请求。**将这些接收对象串成一条链，并沿着这条链传递这个请求，直到链上的某个接收对象能够处理它为止**。在职责链模式中，多个处理器（也就是刚刚定义中说的接收对象）依次处理同一个请求。一个请求先经过 A 处理器处理，然后再把请求传递给 B 处理器，B 处理器处理完后再传递给 C 处理器，以此类推，形成一个链条。**链条上的每个处理器各自承担各自的处理职责，所以叫作职责链模式**。

第一种实现方式如下所示。其中，**Handler 是所有处理器类的抽象父类，handle() 是抽象方法**。每个具体的处理器类的 handle() 函数的代码结构类似，如果它能处理该请求，就不继续往下传递；如果不能处理，则交由后面的处理器来处理（也就是调用 successor.handle()）。**HandlerChain 是处理器链，从数据结构的角度来看，它就是一个记录了链头、链尾的链表**。其中，记录链尾是为了方便添加处理器：
<!--more-->
```java
public abstract class Handler 
{
    protected Handler successor = null;

    public void setSuccessor(Handler successor) 
    {
        this.successor = successor;
    }

    public abstract void handle();
}

public class HandlerA extends Handler 
{
    @Override
    public void handle() 
    {
        boolean handled = false;
        //...
        if (!handled && successor != null) 
        {
            successor.handle();
        }
    }
}

public class HandlerB extends Handler 
{
    @Override
    public void handle() 
    {
        boolean handled = false;
        //...
        if (!handled && successor != null) 
        {
            successor.handle();
        } 
    }
}

public class HandlerChain 
{
    private Handler head = null;
    private Handler tail = null;

    public void addHandler(Handler handler) 
    {
        handler.setSuccessor(null);

        if (head == null) 
        {
            head = handler;
            tail = handler;
            return;
        }

        tail.setSuccessor(handler);
        tail = handler;
    }

    public void handle() 
    {
        if (head != null) 
        {
            head.handle();
        }
    }
}

// 使用举例
public class Application 
{
    public static void main(String[] args) 
    {
        HandlerChain chain = new HandlerChain();
        chain.addHandler(new HandlerA());
        chain.addHandler(new HandlerB());
        chain.handle();
    }
}
```

实际上，上面的代码实现不够优雅。处理器类的 **handle() 函数，不仅包含自己的业务逻辑，还包含对下一个处理器的调用**，也就是代码中的 successor.handle()。一个不熟悉这种代码结构的程序员，在添加新的处理器类的时候，很有可能忘记在 handle() 函数中调用 successor.handle()，这就会导致代码出现 bug。

针对这个问题，我们对代码进行重构，利用模板模式，**将调用 successor.handle() 的逻辑从具体的处理器类中剥离出来，放到抽象父类中**。这样具体的处理器类只需要实现自己的业务逻辑就可以了：
```java
public abstract class Handler 
{
    protected Handler successor = null;

    public void setSuccessor(Handler successor) 
    {
        this.successor = successor;
    }

    public final void handle() 
    {
        boolean handled = doHandle();
        if (successor != null && !handled) 
        {
            successor.handle();
        }
    }

    protected abstract boolean doHandle();
}

public class HandlerA extends Handler 
{
    @Override
    protected boolean doHandle() 
    {
        boolean handled = false;
        //...
        return handled;
    }
}

public class HandlerB extends Handler 
{
    @Override
    protected boolean doHandle() 
    {
        boolean handled = false;
        //...
        return handled;
    }
}

// HandlerChain 和 Application 代码不变
```

我们再来看第二种实现方式，代码如下所示。这种实现方式更加简单。**HandlerChain 类用数组而非链表来保存所有的处理器**，并且需要在 HandlerChain 的 handle() 函数中，依次调用每个处理器的 handle() 函数：
```java
public interface IHandler 
{
    boolean handle();
}

public class HandlerA implements IHandler 
{
    @Override
    public boolean handle() 
    {
        boolean handled = false;
        //...
        return handled;
    }
}

public class HandlerB implements IHandler 
{
    @Override
    public boolean handle() 
    {
        boolean handled = false;
        //...
        return handled;
    }
}

public class HandlerChain 
{
    private List<IHandler> handlers = new ArrayList<>();

    public void addHandler(IHandler handler) 
    {
        this.handlers.add(handler);
    }

    public void handle() 
    {
        for (IHandler handler : handlers) 
        {
            boolean handled = handler.handle();
            if (handled) 
            {
                break;
            }
        }
    }
}

// 使用举例
public class Application 
{
    public static void main(String[] args) 
    {
        HandlerChain chain = new HandlerChain();
        chain.addHandler(new HandlerA());
        chain.addHandler(new HandlerB());
        chain.handle();
    }
}
```

在 GoF 给出的定义中，如果处理器链上的某个处理器能够处理这个请求，那就不会继续往下传递请求。实际上，**职责链模式还有一种变体，那就是请求会被所有的处理器都处理一遍**，不存在中途终止的情况。

## 职责链模式的应用场景举例
对于支持 `UGC`（User Generated Content，用户生成内容）的应用（比如论坛）来说，用户生成的内容（比如，在论坛中发表的帖子）可能会包含一些敏感词（比如涉黄、广告、反动等词汇）。针对这个应用场景，我们就**可以利用职责链模式来过滤这些敏感词**。对于包含敏感词的内容，我们有两种处理方式，一种是直接禁止发布，另一种是给敏感词打马赛克（比如，用 *** 替换敏感词）之后再发布。第一种处理方式符合 GoF 给出的职责链模式的定义，第二种处理方式是职责链模式的变体。

我们这里只给出第一种实现方式的代码示例，如下所示，并且，我们只给出了代码实现的骨架，具体的敏感词过滤算法并没有给出：
```java
public interface SensitiveWordFilter 
{
    boolean doFilter(Content content);
}

public class SexyWordFilter implements SensitiveWordFilter 
{
    @Override
    public boolean doFilter(Content content) 
    {
        boolean legal = true;
        //...
        return legal;
    }
}

// PoliticalWordFilter、AdsWordFilter 类代码结构与 SexyWordFilter 类似

public class SensitiveWordFilterChain 
{
    private List<SensitiveWordFilter> filters = new ArrayList<>();

    public void addFilter(SensitiveWordFilter filter) 
    {
        this.filters.add(filter);
    }

    // return true if content doesn't contain sensitive words.
    public boolean filter(Content content) 
    {
        for (SensitiveWordFilter filter : filters) 
        {
            if (!filter.doFilter(content)) 
            {
                return false;
            }
        }
        return true;
    }
}

public class ApplicationDemo 
{
    public static void main(String[] args) 
    {
        SensitiveWordFilterChain filterChain = new SensitiveWordFilterChain();
        filterChain.addFilter(new AdsWordFilter());
        filterChain.addFilter(new SexyWordFilter());
        filterChain.addFilter(new PoliticalWordFilter());

        boolean legal = filterChain.filter(new Content());
        if (!legal) 
        {
            // 不发表
        } 
        else 
        {
            // 发表
        }
    }
}
```

看了上面的实现，你可能会说，为什么非要使用职责链模式呢？像下面这样也可以实现敏感词过滤功能，而且代码更加简单：
```java
public class SensitiveWordFilter 
{
    // return true if content doesn't contain sensitive words.
    public boolean filter(Content content) 
    {
        if (!filterSexyWord(content)) 
        {
            return false;
        }

        if (!filterAdsWord(content)) 
        {
            return false;
        }

        if (!filterPoliticalWord(content)) 
        {
            return false;
        }

        return true;
    }

    private boolean filterSexyWord(Content content) 
    {
        //...
    }

    private boolean filterAdsWord(Content content) 
    {
        //...
    }

    private boolean filterPoliticalWord(Content content) 
    {
        //...
    }
}
```

### 应对代码的复杂性
**将大块代码逻辑拆分成函数，将大类拆分成小类，是应对代码复杂性的常用方法**。应用职责链模式，我们把各个敏感词过滤函数继续拆分出来，设计成独立的类，进一步简化了 SensitiveWordFilter 类，让 SensitiveWordFilter 类的代码不会过多，过复杂。

### 提高代码的扩展性
当我们要扩展新的过滤算法的时候，比如，我们还需要过滤特殊符号，按照非职责链模式的代码实现方式，我们需要修改 SensitiveWordFilter 的代码，违反开闭原则。不过，这样的修改还算比较集中，也是可以接受的。而**职责链模式的实现方式更加优雅，只需要新添加一个 Filter 类**，并且通过 addFilter() 函数将它添加到 FilterChain 中即可，其他代码完全不需要修改。

实际上，细化一下的话，我们**可以把上面的代码分成两类：框架代码和客户端代码**。其中，ApplicationDemo 属于客户端代码，也就是使用框架的代码。除 ApplicationDemo 之外的代码属于敏感词过滤框架代码。假设敏感词过滤框架并不是我们开发维护的，而是我们引入的一个第三方框架，我们要扩展一个新的过滤算法，不可能直接去修改框架的源码。这个时候，利用职责链模式就能达到开篇所说的，在不修改框架源码的情况下，基于职责链模式提供的扩展点，来扩展新的功能。换句话说，我们**在框架这个代码范围内实现了开闭原则**。

除此之外，利用职责链模式相对于不用职责链的实现方式，还有一个好处，那就是**配置过滤算法更加灵活，可以只选择使用某几个过滤算法**。

## Servlet Filter
Servlet Filter 是 Java Servlet 规范中定义的组件，翻译成中文就是过滤器，它可以实现对 HTTP 请求的过滤功能，比如鉴权、限流、记录日志、验证参数等等。因为它是 Servlet 规范的一部分，所以，**只要是支持 Servlet 的 Web 容器（比如，Tomcat、Jetty 等），都支持过滤器功能**。为了帮助你理解，我画了一张示意图阐述它的工作原理，如下所示：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/GoF/21.png)

在实际项目中，添加一个过滤器，我们只需要**定义一个实现 javax.servlet.Filter 接口的过滤器类，并且将它配置在 web.xml 配置文件中**。Web 容器启动的时候，会读取 web.xml 中的配置，创建过滤器对象。当有请求到来的时候，会先经过过滤器，然后才由 Servlet 来处理：
```java
public class LogFilter implements Filter 
{
    @Override
    public void init(FilterConfig filterConfig) throws ServletException 
    {
        // 在创建 Filter 时自动调用，
        // 其中 filterConfig 包含这个 Filter 的配置参数，比如 name 之类的（从配置文件中读取的）
    }

    @Override
    public void doFilter(ServletRequest request, ServletResponse response, FilterChain chain) throws IOException, ServletException 
    {
        System.out.println("拦截客户端发送来的请求.");
        chain.doFilter(request, response);
        System.out.println("拦截发送给客户端的响应.");
    }

    @Override
    public void destroy() 
    {
        // 在销毁 Filter 时自动调用
    }
}

// 在 web.xml 配置文件中如下配置：
<filter>
    <filter-name>logFilter</filter-name>
    <filter-class>com.xzg.cd.LogFilter</filter-class>
</filter>
<filter-mapping>
    <filter-name>logFilter</filter-name>
    <url-pattern>/*</url-pattern>
</filter-mapping>
```

从刚刚的示例代码中，我们发现，添加过滤器非常方便，不需要修改任何代码，定义一个实现 javax.servlet.Filter 的类，再改改配置就搞定了，完全符合开闭原则。职责链模式的实现包含处理器接口（IHandler）或抽象类（Handler），以及处理器链（HandlerChain）。对应到 Servlet Filter，**javax.servlet.Filter 就是处理器接口，FilterChain 就是处理器链**。接下来，我们重点来看 FilterChain 是如何实现的。

不过，我们前面也讲过，**Servlet 只是一个规范，并不包含具体的实现**，所以，Servlet 中的 FilterChain 只是一个接口定义。具体的实现类由遵从 Servlet 规范的 Web 容器来提供，比如，ApplicationFilterChain 类就是 Tomcat 提供的 FilterChain 的实现类，源码如下所示：
```java
public final class ApplicationFilterChain implements FilterChain 
{
    private int pos = 0; // 当前执行到了哪个 filter
    private int n; // filter 的个数
    private ApplicationFilterConfig[] filters;
    private Servlet servlet;
    
    @Override
    public void doFilter(ServletRequest request, ServletResponse response) 
    {
        if (pos < n) 
        {
            ApplicationFilterConfig filterConfig = filters[pos++];
            Filter filter = filterConfig.getFilter();
            filter.doFilter(request, response, this);
        } 
        else 
        {
            // filter 都处理完毕后，执行 servlet
            servlet.service(request, response);
        }
    }
    
    public void addFilter(ApplicationFilterConfig filterConfig) 
    {
        for (ApplicationFilterConfig filter : filters)
        {
            if (filter == filterConfig)
            {
                return;
            }
        }

        if (n == filters.length) 
        {
            // 扩容
            ApplicationFilterConfig[] newFilters = new ApplicationFilterConfig[n + INCREMENT];
            System.arraycopy(filters, 0, newFilters, 0, n);
            filters = newFilters;
        }
        filters[n++] = filterConfig;
    }
}
```

ApplicationFilterChain 中的 **doFilter() 函数的代码实现比较有技巧，实际上是一个递归调用**。你可以用每个 Filter 的 doFilter() 的代码实现，直接替换 ApplicationFilterChain 的第 15 行代码：
```java
@Override
public void doFilter(ServletRequest request, ServletResponse response) 
{
    if (pos < n) 
    {
        ApplicationFilterConfig filterConfig = filters[pos++];
        Filter filter = filterConfig.getFilter();
        // filter.doFilter(request, response, this);
        // 把 filter.doFilter 的代码实现展开替换到这里
        System.out.println("拦截客户端发送来的请求");
        chain.doFilter(request, response); // chain 就是 this
        System.out.println("拦截发送给客户端的响应")
    } 
    else 
    {
        // filter 都处理完毕后，执行 servlet
        servlet.service(request, response);
    }
}
```

这样实现主要是为了在一个 doFilter() 方法中，**支持双向拦截，既能拦截客户端发送来的请求，也能拦截发送给客户端的响应**。

## Spring Interceptor
Spring Interceptor，翻译成中文就是拦截器。尽管英文单词和中文翻译都不同，但和 Servlet Filter 基本上可以看作一个概念，都用来实现对 HTTP 请求进行拦截处理。它们不同之处在于，**Servlet Filter 是 Servlet 规范的一部分，实现依赖于 Web 容器**。**Spring Interceptor 是 Spring MVC 框架的一部分，由 Spring MVC 框架来提供实现**。客户端发送的请求，会先经过 Servlet Filter，然后再经过 Spring Interceptor，最后到达具体的业务代码中。我画了一张图来阐述一个请求的处理流程，具体如下所示：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/GoF/22.png)

LogInterceptor 实现的功能跟刚才的 LogFilter 完全相同，只是实现方式上稍有区别。LogFilter 对请求和响应的拦截是在 doFilter() 一个函数中实现的，而 LogInterceptor **对请求的拦截在 preHandle() 中实现，对响应的拦截在 postHandle() 中实现**：
```java
public class LogInterceptor implements HandlerInterceptor 
{
    @Override
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) throws Exception 
    {
        System.out.println("拦截客户端发送来的请求");
        return true; // 继续后续的处理
    }

    @Override
    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) throws Exception 
    {
        System.out.println("拦截发送给客户端的响应");
    }

    @Override
    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) throws Exception 
    {
        System.out.println("这里总是被执行");
    }
}

// 在 Spring MVC 配置文件中配置 interceptors
<mvc:interceptors>
    <mvc:interceptor>
        <mvc:mapping path="/*"/>
        <bean class="com.xzg.cd.LogInterceptor"/>
    </mvc:interceptor>
</mvc:interceptors>
```

当然，它也是基于职责链模式实现的。其中，HandlerExecutionChain 类是职责链模式中的处理器链。它的实现**相较于 Tomcat 中的 ApplicationFilterChain 来说，逻辑更加清晰，不需要使用递归来实现**，主要是因为它将请求和响应的拦截工作，拆分到了两个函数中实现。HandlerExecutionChain 的源码如下所示：
```java
public class HandlerExecutionChain 
{
    private final Object handler;
    private HandlerInterceptor[] interceptors;
    
    public void addInterceptor(HandlerInterceptor interceptor) 
    {
        initInterceptorList().add(interceptor);
    }

    boolean applyPreHandle(HttpServletRequest request, HttpServletResponse response) throws Exception 
    {
        HandlerInterceptor[] interceptors = getInterceptors();
        if (!ObjectUtils.isEmpty(interceptors)) 
        {
            for (int i = 0; i < interceptors.length; i++) 
            {
                HandlerInterceptor interceptor = interceptors[i];
                if (!interceptor.preHandle(request, response, this.handler)) 
                {
                    triggerAfterCompletion(request, response, null);
                    return false;
                }
            }
        }
        return true;
    }

    void applyPostHandle(HttpServletRequest request, HttpServletResponse response, ModelAndView mv) throws Exception 
    {
        HandlerInterceptor[] interceptors = getInterceptors();
        if (!ObjectUtils.isEmpty(interceptors)) 
        {
            for (int i = interceptors.length - 1; i >= 0; i--) 
            {
                HandlerInterceptor interceptor = interceptors[i];
                interceptor.postHandle(request, response, this.handler, mv);
            }
        }
    }

    void triggerAfterCompletion(HttpServletRequest request, HttpServletResponse response, Exception ex) throws Exception 
    {
        HandlerInterceptor[] interceptors = getInterceptors();
        if (!ObjectUtils.isEmpty(interceptors)) 
        {
            for (int i = this.interceptorIndex; i >= 0; i--) 
            {
                HandlerInterceptor interceptor = interceptors[i];
                try 
                {
                    interceptor.afterCompletion(request, response, this.handler, ex);
                } 
                catch (Throwable ex2) 
                {
                    logger.error("HandlerInterceptor.afterCompletion threw exception", ex2);
                }
            }
        }
    }
}
```

**在 Spring 框架中，通过 DispatcherServlet 的 doDispatch() 方法来分发请求**，它在真正的业务逻辑执行前后，执行 HandlerExecutionChain 中的 applyPreHandle() 和 applyPostHandle() 函数，用来实现拦截的功能。
