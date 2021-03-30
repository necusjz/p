---
title: Google Guava
date: 2021-03-25 17:25:21
tags:
  - OpenSource
---
## Google Guava 介绍
Google Guava 是 Google 公司内部 Java 开发工具库的开源版本。Google 内部的很多 Java 项目都在使用它。它提供了一些 JDK 没有提供的功能，以及对 JDK 已有功能的增强功能。其中就包括：集合（Collections）、缓存（Caching）、原生类型支持（Primitives Support）、并发库（Concurrency Libraries）、通用注解（Common Annotation）、字符串处理（Strings Processing）、数学计算（Math）、I/O、事件总线（EventBus）等等：
![](https://raw.githubusercontent.com/snlndod/mPOST/master/OpenSource/geek/21.png)
<!--more-->

## 如何发现通用的功能模块？
我们要有善于发现、善于抽象的能力，并且具有扎实的设计、开发能力，能够发现这些非业务的、可复用的功能点，并且从业务逻辑中将其解耦抽象出来，设计并开发成独立的功能模块。在业务开发中，跟业务无关的通用功能模块，常见的一般有三类：
- 类库（Library）；
- 框架（Framework）；
- 功能组件（Component）；

其中，Google Guava 属于类库，提供一组 API 接口；EventBus、DI 容器属于框架，提供骨架代码，能让业务开发人员聚焦在业务开发部分，在预留的扩展点里填充业务代码；ID 生成器、性能计数器属于功能组件，提供一组具有某一特殊功能的 API 接口，**有点类似类库，但更加聚焦和重量级**，比如，ID 生成器有可能会依赖 Redis 等外部系统，不像类库那么简单。实际上，不管是类库、框架还是功能组件，这些通用功能模块有两个最大的特点：**复用和业务无关**。如果没有复用场景，那也就没有了抽离出来、设计成独立模块的必要了。如果与业务有关又可复用，大部分情况下会设计成独立的系统（比如`微服务`），而不是类库、框架或功能组件。

## 如何开发通用的功能模块？
对于这些类库、框架、功能组件的开发，我们**不能闭门造车，要把它们当作“产品”来开发**。这个产品是一个“技术产品”，我们的目标用户是“程序员”，解决的是他们的“开发痛点”。我们要多换位思考，站在用户的角度上，来想他们到底想要什么样的功能。对于一个技术产品来说，尽管 Bug 少、性能好等技术指标至关重要，但是否易用、易集成、易插拔、文档是否全面、是否容易上手等，这些产品素质也非常重要，甚至还能起到决定性作用。往往就是这些很容易忽视、不被重视的东西，会决定一个技术产品是否能在众多的同类中脱颖而出。

具体到 Google Guava，它是一个开发类库，目标用户是 Java 开发工程师，解决用户主要痛点是，相对于 JDK，提供更多的工具类，简化代码编写，比如，它提供了用来判断 null 值的 Preconditions 类；Splitter、Joiner、CharMatcher 字符串处理类；Multisets、Multimaps、Tables 等更丰富的 Collections 类等等。它的优势有这样几点：第一，由 Google 管理、长期维护，经过充分的单元测试，代码质量有保证；第二，可靠、性能好、高度优化，比如 Google Guava 提供的 Immutable Collections 要比 JDK 的 unmodifiableCollection 性能好；第三，全面、完善的文档，容易上手，学习成本低，你可以去看下它的 Github Wiki。

如果你开发的东西是提供给其他团队用的，你**一定要有“服务意识”**。对于程序员来说，这点可能比“产品意识”更加欠缺。首先，从心态上，别的团队使用我们开发出来的技术产品，我们要学会感谢。这点很重要。心态不同了，做起事来就会有微妙的不同。其次，除了写代码，我们还要有抽出大量时间答疑、充当客服角色的心理准备。有了这个心理准备，别的团队的人在问你问题的时候，你也就不会很烦了。相对于业务代码来说，开发这种被多处复用的通用代码，对代码质量的要求更高些，因为这些项目的影响面更大，一旦出现 Bug，会牵连很多系统或其他项目。特别是如果你要把项目开源，影响就更大了。所以，这类项目的代码质量一般都很好，开发这类项目对代码能力的锻炼更大。这也是我经常推荐别人通过阅读著名开源项目代码、参与开源项目来提高技术的原因。

尽管开发这些通用功能模块更加锻炼技术，但我们也不要重复造轮子，能复用的尽量复用。而且，在项目中，如果你想把所有的通用功能都开发为独立的类库、框架、功能组件，这就有点大动干戈了，有可能会得不到领导的支持。毕竟从项目中将这部分通用功能独立出来开发，比起作为项目的一部分来开发，会更加耗时。所以，权衡一下的话，我建议**初期先把这些通用的功能作为项目的一部分来开发**。不过，在开发的时候，我们做好模块化工作，将它们尽量跟其他模块划清界限，通过接口、扩展点等松耦合的方式跟其他模式交互。等到时机成熟了，我们再将它从项目中剥离出来。因为之前模块化做的好，耦合程度低，剥离出来的成本也就不会很高。

## Builder 模式在 Guava 中的应用
在项目开发中，我们经常用到缓存，它可以非常有效地提高访问速度。常用的缓存系统有 Redis、Memcache 等。但是，**如果要缓存的数据比较少，我们完全没必要在项目中独立部署一套缓存系统**。毕竟系统都有一定出错的概率，项目中包含的系统越多，那组合起来，项目整体出错的概率就会升高，可用性就会降低。同时，多引入一个系统就要多维护一个系统，项目维护的成本就会变高。取而代之，我们可以基于 JDK 提供的类，比如 HashMap，从零开始开发内存缓存。不过，从零开发一个内存缓存，涉及的工作就会比较多，比如缓存淘汰策略等。为了简化开发，我们就可以使用 Google Guava 提供的现成的缓存工具类 com.google.common.cache.\*：
```java
public class CacheDemo {
    public static void main(String[] args) {
        Cache<String, String> cache = CacheBuilder.newBuilder()
            .initialCapacity(100)
            .maximumSize(1000)
            .expireAfterWrite(10, TimeUnit.MINUTES)
            .build();

        cache.put("key1", "value1");
        String value = cache.getIfPresent("key1");
        System.out.println(value);
    }
}
```

构建一个缓存，需要配置 n 多参数，比如过期时间、淘汰策略、最大缓存大小等等。相应地，Cache 类就会包含 n 多成员变量。我们需要在构造函数中，设置这些成员变量的值，但又不是所有的值都必须设置，设置哪些值由用户来决定。为了满足这个需求，我们就需要定义多个包含不同参数列表的构造函数。为了避免构造函数的参数列表过长、不同的构造函数过多，我们一般有两种解决方案：
- 使用 Builder 模式；
- 先通过无参构造函数创建对象，然后再通过 setXXX() 方法来逐一设置需要的设置的成员变量；

Guava 选择第一种解决方案的主要原因是，在真正构造 Cache 对象的时候，我们必须做一些必要的参数校验，也就是 build() 函数中前两行代码要做的工作。如果采用无参默认构造函数加 setXXX() 方法的方案，这两个校验就无处安放了。而不经过校验，创建的 Cache 对象有可能是不合法、不可用的：
```java
public <K1 extends K, V1 extends V> Cache<K1, V1> build() {
    this.checkWeightWithWeigher();
    this.checkNonLoadingCache();
    return new LocalManualCache(this);
}

private void checkNonLoadingCache() {
    Preconditions.checkState(this.refreshNanos == -1L, "refreshAfterWrite requires a LoadingCache");
}

private void checkWeightWithWeigher() {
    if (this.weigher == null) {
        Preconditions.checkState(this.maximumWeight == -1L, "maximumWeight requires weigher");
    } else if (this.strictParsing) {
        Preconditions.checkState(this.maximumWeight != -1L, "weigher requires maximumWeight");
    } else if (this.maximumWeight == -1L) {
        logger.log(Level.WARNING, "ignoring weigher specified without maximumWeight");
    }
}
```

## Wrapper 模式在 Guava 中的应用
在 Google Guava 的 collection 包路径下，有一组以 Forwarding 开头命名的类：
![](https://raw.githubusercontent.com/snlndod/mPOST/master/OpenSource/geek/22.png)

这组 Forwarding 类很多，但实现方式都很相似：
```java
@GwtCompatible
public abstract class ForwardingCollection<E> extends ForwardingObject implements Collection<E> {
    protected ForwardingCollection() {}

    protected abstract Collection<E> delegate();

    public Iterator<E> iterator() {
        return this.delegate().iterator();
    }

    public int size() {
        return this.delegate().size();
    }

    @CanIgnoreReturnValue
    public boolean removeAll(Collection<?> collection) {
        return this.delegate().removeAll(collection);
    }

    public boolean isEmpty() {
        return this.delegate().isEmpty();
    }

    public boolean contains(Object object) {
        return this.delegate().contains(object);
    }

    @CanIgnoreReturnValue
    public boolean add(E element) {
        return this.delegate().add(element);
    }

    @CanIgnoreReturnValue
    public boolean remove(Object object) {
        return this.delegate().remove(object);
    }

    public boolean containsAll(Collection<?> collection) {
        return this.delegate().containsAll(collection);
    }

    @CanIgnoreReturnValue
    public boolean addAll(Collection<? extends E> collection) {
        return this.delegate().addAll(collection);
    }

    @CanIgnoreReturnValue
    public boolean retainAll(Collection<?> collection) {
        return this.delegate().retainAll(collection);
    }

    public void clear() {
        this.delegate().clear();
    }

    public Object[] toArray() {
        return this.delegate().toArray();
    }
    //...省略部分代码...
}
```

举一个它的用法示例：
```java
public class AddLoggingCollection<E> extends ForwardingCollection<E> {
    private static final Logger logger = LoggerFactory.getLogger(AddLoggingCollection.class);
    private Collection<E> originalCollection;

    public AddLoggingCollection(Collection<E> originalCollection) {
        this.originalCollection = originalCollection;
    }

    @Override
    protected Collection delegate() {
        return this.originalCollection;
    }

    @Override
    public boolean add(E element) {
        logger.info("Add element: " + element);
        return this.delegate().add(element);
    }

    @Override
    public boolean addAll(Collection<? extends E> collection) {
        logger.info("Size of elements to add: " + collection.size());
        return this.delegate().addAll(collection);
    }
}
```

在上面的代码中，AddLoggingCollection 是基于代理模式实现的一个代理类，它在原始 Collection 类的基础之上，针对“add”相关的操作，添加了记录日志的功能。**代理模式、装饰器、适配器模式可以统称为 Wrapper 模式**，通过 Wrapper 类二次封装原始类。它们的代码实现也很相似，都可以**通过组合的方式，将 Wrapper 类的函数实现委托给原始类的函数来实现**：
```java
public interface Interf {
    void f1();
    void f2();
}
public class OriginalClass implements Interf {
    @Override
    public void f1() {}
    @Override
    public void f2() {}
}

public class WrapperClass implements Interf {
    private OriginalClass oc;
    public WrapperClass(OriginalClass oc) {
        this.oc = oc;
    }
    @Override
    public void f1() {
        //...附加功能...
        this.oc.f1();
        //...附加功能...
    }
    @Override
    public void f2() {
        this.oc.f2();
    }
}
```

实际上，这个 ForwardingCollection 类是一个“默认 Wrapper 类”或者叫“缺省 Wrapper 类”。如果我们不使用这个 ForwardingCollection 类，而是让 AddLoggingCollection 代理类直接实现 Collection 接口，那 Collection 接口中的所有方法，都要在 AddLoggingCollection 类中实现一遍，而真正需要添加日志功能的只有 add() 和 addAll() 两个函数，其他函数的实现，都只是类似 Wrapper 类中 f2() 函数的实现那样，简单地委托给原始 collection 类对象的对应函数。为了简化 Wrapper 模式的代码实现，Guava 提供一系列缺省的 Forwarding 类。用户在实现自己的 Wrapper 类的时候，**基于缺省的 Forwarding 类来扩展，就可以只实现自己关心的方法**，其他不关心的方法使用缺省 Forwarding 类的实现，就像 AddLoggingCollection 类的实现那样。

## Immutable 模式在 Guava 中的应用
Immutable 模式，中文叫作不变模式，它并不属于经典的 23 种设计模式，但作为一种较常用的设计思路，可以总结为一种设计模式来学习。**一个对象的状态在对象创建之后就不再改变**，这就是所谓的不变模式。其中涉及的类就是`不变类`（Immutable Class），对象就是`不变对象`（Immutable Object）。在 Java 中，最常用的不变类就是 String 类，String 对象一旦创建之后就无法改变。

不变模式可以分为两类，一类是普通不变模式，另一类是深度不变模式。**普通的不变模式指的是，对象中包含的引用对象是可以改变的**。如果不特别说明，通常我们所说的不变模式，指的就是普通的不变模式。深度不变模式指的是，对象包含的引用对象也不可变。它们两个之间的关系，有点类似之前讲过的浅拷贝和深拷贝之间的关系：
```java
// 普通不变模式
public class User {
    private String name;
    private int age;
    private Address addr;
    
    public User(String name, int age, Address addr) {
        this.name = name;
        this.age = age;
        this.addr = addr;
    }
    // 只有 getter 方法，无 setter 方法
}

public class Address {
    private String province;
    private String city;
    public Address(String province, String city) {
        this.province = province;
        this.city= city;
    }
    // 有 getter 方法，也有 setter 方法
}

// 深度不变模式
public class User {
    private String name;
    private int age;
    private Address addr;
    
    public User(String name, int age, Address addr) {
        this.name = name;
        this.age = age;
        this.addr = addr;
    }
    // 只有 getter 方法，无 setter 方法
}

public class Address {
    private String province;
    private String city;
    public Address(String province, String city) {
        this.province = province;
        this.city= city;
    }
    // 只有 getter 方法，无 setter 方法
}
```

在某个业务场景下，如果一个对象符合创建之后就不会被修改这个特性，那我们就可以把它设计成不变类。显式地强制它不可变，这样能避免意外被修改。那如何将一个类设置为不变类呢？其实方法很简单，只要这个类满足：**所有的成员变量都通过构造函数一次性设置好，不暴露任何 set 等修改成员变量的方法**。除此之外，**因为数据不变，所以不存在并发读写问题**，因此不变模式常用在多线程环境下，来避免线程加锁。所以，不变模式也常被归类为多线程设计模式。Google Guava 针对集合类（Collection、List、Set、Map...）提供了对应的不变集合类（ImmutableCollection、ImmutableList、ImmutableSet、ImmutableMap...），采用`普通不变模式`，集合中的对象不会增删，但是对象的成员变量（或叫属性值）是可以改变的：
```java
public class ImmutableDemo {
    public static void main(String[] args) {
        List<String> originalList = new ArrayList<>();
        originalList.add("a");
        originalList.add("b");
        originalList.add("c");

        List<String> jdkUnmodifiableList = Collections.unmodifiableList(originalList);
        List<String> guavaImmutableList = ImmutableList.copyOf(originalList);

        // jdkUnmodifiableList.add("d"); 抛出 UnsupportedOperationException
        // guavaImmutableList.add("d"); 抛出 UnsupportedOperationException
        originalList.add("d");

        print(originalList);        // a b c d
        print(jdkUnmodifiableList); // a b c d
        print(guavaImmutableList);  // a b c
    }

    private static void print(List<String> list) {
        for (String s : list) {
            System.out.print(s + " ");
        }
        System.out.println();
    }
}
```

## 到底什么是函数式编程?
每个编程范式都有自己独特的地方，这就是它们会被抽象出来作为一种范式的原因。面向对象编程最大的特点是：以类、对象作为组织代码的单元以及它的四大特性；面向过程编程最大的特点是：以函数作为组织代码的单元，数据与方法相分离；函数式编程认为，**程序可以用一系列数学函数或表达式的组合来表示**，函数式编程是程序面向数学的更底层的抽象，将计算过程描述为表达式。函数式编程有它自己适合的应用场景，比如开篇提到的科学计算、数据处理、统计分析等。在这些领域，程序往往比较容易用数学表达式来表示，比起非函数式编程，实现同样的功能，函数式编程可以用很少的代码就能搞定。但是，对于强业务相关的大型业务系统开发来说，费劲吧啦地将它抽象成数学表达式，硬要用函数式编程来实现，显然是自讨苦吃。相反，在这种应用场景下，面向对象编程更加合适，写出来的代码更加可读、可维护。

函数式编程跟面向过程编程一样，也是以函数作为组织代码的单元。不过，它跟面向过程编程的区别在于，它的函数是`无状态`的。何为无状态？简单点讲就是，**函数内部涉及的变量都是局部变量，不会像面向对象编程那样，共享类成员变量，也不会像面向过程编程那样，共享全局变量**。函数的执行结果只与入参有关，跟其他任何外部变量无关。同样的入参，不管怎么执行，得到的结果都是一样的：
```java
// 有状态函数: 执行结果依赖 b 的值是多少，
// 即便入参相同，多次执行函数，函数的返回值有可能不同，因为 b 值有可能不同
int b;
int increase(int a) {
    return a + b;
}
// 无状态函数：执行结果不依赖任何外部变量值，
// 只要入参相同，不管执行多少次，函数的返回值就相同
int increase(int a, int b) {
    return a + b;
}
```

不同的编程范式之间并不是截然不同的，总是有一些相同的编程规则。比如，不管是面向过程、面向对象还是函数式编程，它们都有变量、函数的概念，最顶层都要有 main 函数执行入口，来组装编程单元（类、函数等）。只不过，**面向对象的编程单元是类或对象，面向过程的编程单元是函数，函数式编程的编程单元是无状态函数**。

## Java 对函数式编程的支持
实现面向对象编程不一定非得使用面向对象编程语言，同理，实现函数式编程也不一定非得使用函数式编程语言。现在，很多面向对象编程语言，也提供了相应的语法、类库来支持函数式编程。接下来，我们就看下 Java 这种面向对象编程语言，对函数式编程的支持：
```java
public class FPDemo {
    public static void main(String[] args) {
        Optional<Integer> result = Stream.of("f", "ba", "hello")
            .map(s -> s.length())
            .filter(l -> l <= 3)
            .max((o1, o2) -> o1 - o2);
        System.out.println(result.get()); // 输出 2
    }
}
```

Java 为函数式编程引入了三个新的语法概念：
- **Stream 类**：支持通过“.”级联多个函数操作的代码编写方式；
- **Lambda 表达式**：简化代码编写；
- **函数接口**：把函数包裹成函数接口，来实现把函数当做参数一样来使用；

> Java 不像 C 一样支持函数指针，可以把函数直接当参数来使用。

### Stream 类
假设我们要计算这样一个表达式：(3-1)*2+5。如果按照普通的函数调用的方式写出来，就是下面这个样子：
```java
add(multiply(subtract(3, 1), 2), 5);
```

不过，这样编写代码看起来会比较难理解，我们换个更易读的写法：
```java
subtract(3, 1).multiply(2).add(5);
```

在 Java 中，“.”表示调用某个对象的方法。为了支持上面这种级联调用方式，我们让每个函数都返回一个通用的类型：Stream 类对象。在 Stream 类上的操作有两种：中间操作和终止操作。**中间操作返回的仍然是 Stream 类对象，而终止操作返回的是确定的值结果**。

### Lambda 表达式
Java 引入 Lambda 表达式的主要作用是简化代码编写。实际上，我们也可以不用 Lambda 表达式来书写例子中的代码，Lambda 表达式在 Java 中只是一个语法糖而已，**底层是基于函数接口来实现的**：
```java
// Stream 中 map 函数的定义
public interface Stream<T> extends BaseStream<T, Stream<T>> {
    <R> Stream<R> map(Function<? super T, ? extends R> mapper);
    //...省略其他函数...
}
// Stream 中 map 的使用方法
Stream.of("fo", "bar", "hello").map(new Function<String, Integer>() {
    @Override
    public Integer apply(String s) {
        return s.length();
    }
});
// 用 Lambda 表达式简化后的写法
Stream.of("fo", "bar", "hello").map(s -> s.length());
```

Lambda 表达式包括三部分：输入、函数体、输出：
```java
(a, b) -> {语句1; 语句2; ...; return 输出;} // a, b 是输入参数
```

实际上，Lambda 表达式的写法非常灵活。我们刚刚给出的是标准写法，还有很多简化写法。比如，如果输入参数只有一个，可以省略 ()，直接写成 a->{...}；如果没有入参，可以直接将输入和箭头都省略掉，只保留函数体；如果函数体只有一个语句，那可以将 {} 省略掉；如果函数没有返回值，return 语句就可以不用写了。

### 函数接口
如果我们把之前例子中的 Lambda 表达式，全部替换为函数接口的实现方式，就是下面这样子的：
```java
Optional<Integer> result = Stream.of("f", "ba", "hello")
    .map(s -> s.length())
    .filter(l -> l <= 3)
    .max((o1, o2) -> o1-o2);
        
// 还原为函数接口的实现方式
Optional<Integer> result2 = Stream.of("fo", "bar", "hello")
    .map(new Function<String, Integer>() {
        @Override
        public Integer apply(String s) {
            return s.length();
        }
    })
    .filter(new Predicate<Integer>() {
        @Override
        public boolean test(Integer l) {
            return l <= 3;
        }
    })
    .max(new Comparator<Integer>() {
        @Override
        public int compare(Integer o1, Integer o2) {
        return o1 - o2;
        }
    });
```

上面一段代码中的 Function、Predicate、Comparator 都是函数接口。我们知道，C 语言支持函数指针，它可以把函数直接当变量来使用。但是，Java 没有函数指针这样的语法，所以，它**通过函数接口，将函数包裹在接口中，当作变量来使用**。实际上，函数接口就是接口，不过，它也有自己特别的地方，那就是要求**只包含一个未实现的方法**。因为只有这样，Lambda 表达式才能明确知道匹配的是哪个接口。如果有两个未实现的方法，并且接口入参、返回值都一样，那 Java 在翻译 Lambda 表达式的时候，就不知道表达式对应哪个方法了。

Java 提供的 Function、Predicate 两个函数接口的源码：
```java
@FunctionalInterface
public interface Function<T, R> {
    R apply(T t);  // 只有这一个未实现的方法
    default <V> Function<V, R> compose(Function<? super V, ? extends T> before) {
        Objects.requireNonNull(before);
        return (V v) -> apply(before.apply(v));
    }
    default <V> Function<T, V> andThen(Function<? super R, ? extends V> after) {
        Objects.requireNonNull(after);
        return (T t) -> after.apply(apply(t));
    }
    static <T> Function<T, T> identity() {
        return t -> t;
    }
}

@FunctionalInterface
public interface Predicate<T> {
    boolean test(T t); // 只有这一个未实现的方法
    default Predicate<T> and(Predicate<? super T> other) {
        Objects.requireNonNull(other);
        return (t) -> test(t) && other.test(t);
    }
    default Predicate<T> negate() {
        return (t) -> !test(t);
    }
    default Predicate<T> or(Predicate<? super T> other) {
        Objects.requireNonNull(other);
        return (t) -> test(t) || other.test(t);
    }
    static <T> Predicate<T> isEqual(Object targetRef) {
        return (null == targetRef)
                ? Objects::isNull
                : object -> targetRef.equals(object);
    }
}
```

## Guava 对函数式编程的增强
**颠覆式创新是很难的**。不过我们可以进行一些补充，一方面，可以增加 Stream 类上的操作（类似 map, filter, max 这样的终止操作和中间操作）；另一方面，也可以增加更多的函数接口（类似 Function、Predicate 这样的函数接口）；实际上，我们还可以设计一些类似 Stream 类的新的支持级联操作的类。这样，使用 Java 配合 Guava 进行函数式编程会更加方便。从 Google Guava 的 GitHub Wiki 中，我们发现，Google 对于函数式编程的使用还是很谨慎的，认为**过度地使用函数式编程，会导致代码可读性变差**，强调不要滥用。这跟我前面对函数式编程的观点是一致的。所以，在函数式编程方面，Google Guava 并没有提供太多的支持。

之所以对遍历集合操作做了优化，主要是因为函数式编程一个重要的应用场景就是遍历集合。如果不使用函数式编程，我们只能 for 循环，一个一个的处理集合中的数据。**使用函数式编程，可以大大简化遍历集合操作的代码编写**，一行代码就能搞定，而且在可读性方面也没有太大损失。
