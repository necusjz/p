---
title: Prototype Design Pattern
tags:
  - GoF
abbrlink: 1979191221
date: 2020-11-29 18:52:39
---
## 原型模式的原理与应用
如果**对象的创建成本比较大，而同一个类的不同对象之间差别不大**（大部分字段都相同），在这种情况下，我们可以利用对已有对象（原型）进行复制（或者叫拷贝）的方式来创建新对象，以达到节省创建时间的目的。这种基于原型来创建对象的方式就叫作`原型设计模式`（Prototype Design Pattern），简称原型模式。

实际上，**创建对象包含的申请内存、给成员变量赋值这一过程**，本身并不会花费太多时间，或者说对于大部分业务系统来说，这点时间完全是可以忽略的。应用一个复杂的模式，只得到一点点的性能提升，这就是所谓的过度设计，得不偿失。但是，如果**对象中的数据需要经过复杂的计算才能得到**（比如排序、计算哈希值），或者需要从 RPC、网络、数据库、文件系统等非常慢速的 IO 中读取，这种情况下，我们就可以利用原型模式，从其他已有对象中直接拷贝得到，而不用每次在创建新对象的时候，都重复执行这些耗时的操作。

假设数据库中存储了大约 10 万条“搜索关键词”信息，每条信息包含关键词、关键词被搜索的次数、信息最近被更新的时间等。系统 A 在启动的时候会加载这份数据到内存中，用于处理某些其他的业务需求。为了方便快速地查找某个关键词对应的信息，我们**给关键词建立一个散列表索引**。如果你熟悉的是 Java 语言，可以直接使用语言中提供的 HashMap 容器来实现。其中，HashMap 的 key 为搜索关键词，value 为关键词详细信息（比如搜索次数）。我们只需要将数据从数据库中读取出来，放入 HashMap 就可以了。

不过，我们还有另外一个系统 B，专门用来分析搜索日志，定期（比如间隔 10 分钟）批量地更新数据库中的数据，并且标记为新的数据版本。比如，在下面的示例图中，我们对 v2 版本的数据进行更新，得到 v3 版本的数据。这里我们假设只有更新和新添关键词，没有删除关键词的行为：
<!--more-->
![](https://raw.githubusercontent.com/necusjz/p/master/GoF/08.png)

为了保证系统 A 中数据的实时性（不一定非常实时，但数据也不能太旧），系统 A 需要定期根据数据库中的数据，更新内存中的索引和数据。我们只需要在系统 A 中，记录当前数据的版本 Va 对应的更新时间 Ta，从数据库中捞出更新时间大于 Ta 的所有搜索关键词，也就是**找出 Va 版本与最新版本数据的差集**，然后针对差集中的每个关键词进行处理。如果它已经在散列表中存在了，我们就更新相应的搜索次数、更新时间等信息；如果它在散列表中不存在，我们就将它插入到散列表中：
```java
public class Demo 
{
    private ConcurrentHashMap<String, SearchWord> currentKeywords = new ConcurrentHashMap<>();
    private long lastUpdateTime = -1;

    public void refresh() 
    {
        // 从数据库中取出更新时间 > lastUpdateTime 的数据，放入到 currentKeywords 中
        List<SearchWord> toBeUpdatedSearchWords = getSearchWords(lastUpdateTime);
        long maxNewUpdatedTime = lastUpdateTime;
        for (SearchWord searchWord : toBeUpdatedSearchWords) 
        {
            if (searchWord.getLastUpdateTime() > maxNewUpdatedTime) 
            {
                maxNewUpdatedTime = searchWord.getLastUpdateTime();
            }
            if (currentKeywords.containsKey(searchWord.getKeyword())) 
            {
                currentKeywords.replace(searchWord.getKeyword(), searchWord);
            } 
            else 
            {
                currentKeywords.put(searchWord.getKeyword(), searchWord);
            }
        }

        lastUpdateTime = maxNewUpdatedTime;
    }

    private List<SearchWord> getSearchWords(long lastUpdateTime) 
    {
        // TODO: 从数据库中取出更新时间 > lastUpdateTime 的数据
        return null;
    }
}
```

不过，现在，我们有一个特殊的要求：任何时刻，系统 A 中的**所有数据都必须是同一个版本的**，要么都是版本 a，要么都是版本 b，不能有的是版本 a，有的是版本 b。那刚刚的更新方式就不能满足这个要求了。除此之外，我们还要求：在更新内存数据的时候，系统 A 不能处于不可用状态，也就是**不能停机更新数据**。

我们把正在使用的数据的版本定义为“服务版本”，当我们要更新内存中的数据的时候，我们并不是直接在服务版本（假设是版本 a 数据）上更新，而是重新创建另一个版本数据（假设是版本 b 数据），**等新的版本数据建好之后，再一次性地将服务版本从版本 a 切换到版本 b**。这样既保证了数据一直可用，又避免了中间状态的存在：
```java
public class Demo 
{
    private HashMap<String, SearchWord> currentKeywords=new HashMap<>();

    public void refresh() 
    {
        HashMap<String, SearchWord> newKeywords = new LinkedHashMap<>();

        // 从数据库中取出所有的数据，放入到 newKeywords 中
        List<SearchWord> toBeUpdatedSearchWords = getSearchWords();
        for (SearchWord searchWord : toBeUpdatedSearchWords) 
        {
            newKeywords.put(searchWord.getKeyword(), searchWord);
        }

        currentKeywords = newKeywords;
    }

    private List<SearchWord> getSearchWords() 
    {
        // TODO: 从数据库中取出所有的数据
        return null;
    }
}
```

不过，在上面的代码实现中，**newKeywords 构建的成本比较高**。我们需要将这 10 万条数据从数据库中读出，然后计算哈希值，构建 newKeywords。我们拷贝 currentKeywords 数据到 newKeywords 中，然后从数据库中只捞出新增或者有更新的关键词，更新到 newKeywords 中。而相对于 10 万条数据来说，**每次新增或者更新的关键词个数是比较少的**，所以，这种策略大大提高了数据更新的效率：
```java
public class Demo 
{
    private HashMap<String, SearchWord> currentKeywords=new HashMap<>();
    private long lastUpdateTime = -1;

    public void refresh() 
    {
        // 原型模式就这么简单，拷贝已有对象的数据，更新少量差值
        HashMap<String, SearchWord> newKeywords = (HashMap<String, SearchWord>) currentKeywords.clone();

        // 从数据库中取出更新时间 > lastUpdateTime 的数据，放入到 newKeywords 中
        List<SearchWord> toBeUpdatedSearchWords = getSearchWords(lastUpdateTime);
        long maxNewUpdatedTime = lastUpdateTime;
        for (SearchWord searchWord : toBeUpdatedSearchWords) 
        {
            if (searchWord.getLastUpdateTime() > maxNewUpdatedTime) 
            {
                maxNewUpdatedTime = searchWord.getLastUpdateTime();
            }
            if (newKeywords.containsKey(searchWord.getKeyword())) 
            {
                SearchWord oldSearchWord = newKeywords.get(searchWord.getKeyword());
                oldSearchWord.setCount(searchWord.getCount());
                oldSearchWord.setLastUpdateTime(searchWord.getLastUpdateTime());
            } 
            else 
            {
                newKeywords.put(searchWord.getKeyword(), searchWord);
            }
        }

        lastUpdateTime = maxNewUpdatedTime;
        currentKeywords = newKeywords;
    }

    private List<SearchWord> getSearchWords(long lastUpdateTime) 
    {
        // TODO: 从数据库中取出更新时间 > lastUpdateTime 的数据
        return null;
    }
}
```

这里我们利用了 Java 中的 clone() 语法来复制一个对象。如果你熟悉的语言没有这个语法，那把数据从 currentKeywords 中一个个取出来，然后再重新计算哈希值，放入到 newKeywords 中也是可以接受的。毕竟，最耗时的还是从数据库中取数据的操作。**相对于数据库的 IO 操作来说，内存操作和 CPU 计算的耗时都是可以忽略的**。

## 原型模式的实现方式：深拷贝和浅拷贝
我们来看，在内存中，用散列表组织的搜索关键词信息是如何存储的。从图中我们可以发现，散列表索引中，每个结点存储的 key 是搜索关键词，value 是 SearchWord 对象的内存地址。**SearchWord 对象本身存储在散列表之外的内存空间中**：
![](https://raw.githubusercontent.com/necusjz/p/master/GoF/09.png)

浅拷贝和深拷贝的区别在于，浅拷贝只会复制图中的索引（散列表），不会复制数据（SearchWord 对象）本身。相反，**深拷贝不仅仅会复制索引，还会复制数据本身**。浅拷贝得到的对象（newKeywords）跟原始对象（currentKeywords）共享数据，而深拷贝得到的是一份完完全全独立的对象。具体的对比如下图所示：
![](https://raw.githubusercontent.com/necusjz/p/master/GoF/10.png)
![](https://raw.githubusercontent.com/necusjz/p/master/GoF/11.png)

在上面的代码中，我们通过调用 HashMap 上的 clone() 浅拷贝方法来实现原型模式。当我们通过 newKeywords 更新 SearchWord 对象的时候，newKeywords 和 currentKeywords 因为指向相同的一组 SearchWord 对象，就会**导致 currentKeywords 中指向的 SearchWord，有的是老版本的，有的是新版本的**，就没法满足我们之前的需求：currentKeywords 中的数据在任何时刻都是同一个版本的，不存在介于老版本与新版本之间的中间状态。

我们可以将浅拷贝替换为深拷贝。newKeywords 不仅仅复制 currentKeywords 的索引，还把 SearchWord 对象也复制一份出来，这样 newKeywords 和 currentKeywords 就指向不同的 SearchWord 对象，也就不存在更新 newKeywords 的数据会导致 currentKeywords 的数据也被更新的问题了：
- 递归拷贝对象、对象的引用对象以及引用对象的引用对象...**直到要拷贝的对象只包含基本数据类型数据，没有引用对象为止**。根据这个思路对之前的代码进行重构。重构之后的代码如下所示：
```java
public class Demo 
{
    private HashMap<String, SearchWord> currentKeywords=new HashMap<>();
    private long lastUpdateTime = -1;

    public void refresh() 
    {
        // Deep copy
        HashMap<String, SearchWord> newKeywords = new HashMap<>();
        for (HashMap.Entry<String, SearchWord> e : currentKeywords.entrySet()) 
        {
            SearchWord searchWord = e.getValue();
            SearchWord newSearchWord = new SearchWord(searchWord.getKeyword(), searchWord.getCount(), searchWord.getLastUpdateTime());
            newKeywords.put(e.getKey(), newSearchWord);
        }

        // 从数据库中取出更新时间 > lastUpdateTime 的数据，放入到 newKeywords 中
        List<SearchWord> toBeUpdatedSearchWords = getSearchWords(lastUpdateTime);
        long maxNewUpdatedTime = lastUpdateTime;
        for (SearchWord searchWord : toBeUpdatedSearchWords) 
        {
            if (searchWord.getLastUpdateTime() > maxNewUpdatedTime) 
            {
                maxNewUpdatedTime = searchWord.getLastUpdateTime();
            }
            if (newKeywords.containsKey(searchWord.getKeyword())) 
            {
                SearchWord oldSearchWord = newKeywords.get(searchWord.getKeyword());
                oldSearchWord.setCount(searchWord.getCount());
                oldSearchWord.setLastUpdateTime(searchWord.getLastUpdateTime());
            } 
            else 
            {
                newKeywords.put(searchWord.getKeyword(), searchWord);
            }
        }

        lastUpdateTime = maxNewUpdatedTime;
        currentKeywords = newKeywords;
    }

    private List<SearchWord> getSearchWords(long lastUpdateTime) 
    {
        // TODO: 从数据库中取出更新时间 > lastUpdateTime 的数据
        return null;
    }
}
```
- **先将对象序列化，然后再反序列化成新的对象**。具体的示例代码如下所示：
```java
public Object deepCopy(Object object) 
{
    ByteArrayOutputStream bo = new ByteArrayOutputStream();
    ObjectOutputStream oo = new ObjectOutputStream(bo);
    oo.writeObject(object);
    
    ByteArrayInputStream bi = new ByteArrayInputStream(bo.toByteArray());
    ObjectInputStream oi = new ObjectInputStream(bi);
    
    return oi.readObject();
}
```

这两种实现方法，不管采用哪种，**深拷贝都要比浅拷贝耗时、耗内存空间**。我们可以先采用浅拷贝的方式创建 newKeywords。**对于需要更新的 SearchWord 对象，我们再使用深度拷贝的方式创建一份新的对象**，替换 newKeywords 中的老对象。毕竟需要更新的数据是很少的。这种方式即利用了浅拷贝节省时间、空间的优点，又能保证 currentKeywords 中的中数据都是老版本的数据：
```java
public class Demo 
{
    private HashMap<String, SearchWord> currentKeywords=new HashMap<>();
    private long lastUpdateTime = -1;

    public void refresh() 
    {
        // Shallow copy
        HashMap<String, SearchWord> newKeywords = (HashMap<String, SearchWord>) currentKeywords.clone();

        // 从数据库中取出更新时间 > lastUpdateTime 的数据，放入到 newKeywords 中
        List<SearchWord> toBeUpdatedSearchWords = getSearchWords(lastUpdateTime);
        long maxNewUpdatedTime = lastUpdateTime;
        for (SearchWord searchWord : toBeUpdatedSearchWords) 
        {
            if (searchWord.getLastUpdateTime() > maxNewUpdatedTime) 
            {
                maxNewUpdatedTime = searchWord.getLastUpdateTime();
            }
            if (newKeywords.containsKey(searchWord.getKeyword())) 
            {
                newKeywords.remove(searchWord.getKeyword());
            }
            newKeywords.put(searchWord.getKeyword(), searchWord);
        }

        lastUpdateTime = maxNewUpdatedTime;
        currentKeywords = newKeywords;
    }

    private List<SearchWord> getSearchWords(long lastUpdateTime) 
    {
        // TODO: 从数据库中取出更新时间 > lastUpdateTime 的数据
        return null;
    }
}
```
