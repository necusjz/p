---
title: Iterator Design Pattern
date: 2020-12-23 13:58:38
tags:
  - GoF
---
## 迭代器模式的原理和实现
`迭代器模式`（Iterator Design Pattern），也叫作游标模式（Cursor Design Pattern）。它用来遍历集合对象，这里说的“集合对象”也可以叫“容器”、“聚合对象”，实际上就是包含一组对象的对象，比如数组、链表、树、图、跳表。**迭代器模式将集合对象的遍历操作从集合类中拆分出来，放到迭代器类中，让两者的职责更加单一**。

迭代器是用来遍历容器的，所以，一个完整的迭代器模式一般会涉及`容器`和`容器迭代器`两部分内容。为了达到基于接口而非实现编程的目的，容器又包含容器接口、容器实现类，迭代器又包含迭代器接口、迭代器实现类：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/GoF/25.png)

大部分编程语言都提供了遍历容器的迭代器类，我们在平时开发中，直接拿来用即可，几乎不大可能从零编写一个迭代器。不过，这里为了讲解迭代器的实现原理，我们**假设某个新的编程语言的基础类库中，还没有提供线性容器对应的迭代器，需要我们从零开始开发**。线性数据结构包括数组和链表，假设在这种新的编程语言中，这两个数据结构分别对应 ArrayList 和 LinkedList 两个类。除此之外，我们**从两个类中抽象出公共的接口，定义为 List 接口，以方便开发者基于接口而非实现编程**，编写的代码能在两种数据存储结构之间灵活切换。

现在，我们针对 ArrayList 和 LinkedList 两个线性容器，设计实现对应的迭代器。按照之前给出的迭代器模式的类图，我们**定义一个迭代器接口 Iterator，以及针对两种容器的具体的迭代器实现类 ArrayIterator 和 ListIterator**。我们先来看下 Iterator 接口的定义：
<!--more-->
```java
// 接口定义方式一
public interface Iterator<E> 
{
    boolean hasNext();
    void next();
    E currentItem();
}

// 接口定义方式二
public interface Iterator<E> 
{
    boolean hasNext();
    E next();
}
```

在第一种定义中，next() 函数用来将游标后移一位元素，currentItem() 函数用来返回当前游标指向的元素。在第二种定义中，返回当前元素与后移一位这两个操作，要放到同一个函数 next() 中完成。第一种定义方式更加灵活一些，比如我们**可以多次调用 currentItem() 查询当前元素，而不移动游标**。

现在，我们再来看下 ArrayIterator 的代码实现：
```java
public class ArrayIterator<E> implements Iterator<E> 
{
    private int cursor;
    private ArrayList<E> arrayList;

    public ArrayIterator(ArrayList<E> arrayList) 
    {
        this.cursor = 0;
        this.arrayList = arrayList;
    }

    @Override
    public boolean hasNext() 
    {
        return cursor != arrayList.size(); // 注意这里，cursor 在指向最后一个元素的时候，hasNext() 仍旧返回 true
    }

    @Override
    public void next() 
    {
        cursor++;
    }

    @Override
    public E currentItem() 
    {
        if (cursor >= arrayList.size()) 
        {
            throw new NoSuchElementException();
        }
        return arrayList.get(cursor);
    }
}

public class Demo 
{
    public static void main(String[] args) 
    {
        ArrayList<String> names = new ArrayList<>();
        names.add("xzg");
        names.add("wang");
        names.add("zheng");
        
        Iterator<String> iterator = new ArrayIterator(names);
        while (iterator.hasNext()) 
        {
            System.out.println(iterator.currentItem());
            iterator.next();
        }
    }
}
```

在上面的代码实现中，我们需要将待遍历的容器对象，通过构造函数传递给迭代器类。实际上，**为了封装迭代器的创建细节，我们可以在容器中定义一个 iterator() 方法**，来创建对应的迭代器。为了能实现基于接口而非实现编程，我们还需要将这个方法定义在 List 接口中：
```java
public interface List<E> 
{
    Iterator iterator();
    //...省略其他接口函数...
}

public class ArrayList<E> implements List<E> 
{
    //...
    public Iterator iterator() 
    {
        return new ArrayIterator(this);
    }
    //...省略其他代码
}

public class Demo 
{
    public static void main(String[] args) 
    {
        List<String> names = new ArrayList<>();
        names.add("xzg");
        names.add("wang");
        names.add("zheng");
        
        Iterator<String> iterator = names.iterator();
        while (iterator.hasNext()) 
        {
            System.out.println(iterator.currentItem());
            iterator.next();
        }
    }
}
```

结合刚刚的例子，我们来总结一下迭代器的设计思路。总结下来就三句话：
1. 迭代器中需要定义 hasNext()、currentItem()、next() 三个最基本的方法；
2. 待遍历的容器对象通过依赖注入传递到迭代器类中；
3. 容器通过 iterator() 方法来创建迭代器；

这里我画了一张类图，如下所示。实际上就是对上面那张类图的细化：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/GoF/26.png)

## 迭代器模式的优势
一般来讲，遍历集合数据有三种方法：`for 循环`、`foreach 循环`、`iterator 迭代器`。具体的代码如下所示：
```java
List<String> names = new ArrayList<>();
names.add("xzg");
names.add("wang");
names.add("zheng");

// 第一种遍历方式：for 循环
for (int i = 0; i < names.size(); i++) 
{
    System.out.print(names.get(i) + ",");
}

// 第二种遍历方式：foreach 循环
for (String name : names) 
{
    System.out.print(name + ",")
}

// 第三种遍历方式：迭代器遍历
Iterator<String> iterator = names.iterator();
while (iterator.hasNext()) 
{
    System.out.print(iterator.next() + ","); // Java 中的迭代器接口是第二种定义方式，next() 既移动游标又返回数据
}
```

实际上，**foreach 循环只是一个语法糖而已，底层是基于迭代器来实现的**。也就是说，上面代码中的第二种遍历方式（foreach 循环代码）的底层实现，就是第三种遍历方式（迭代器遍历代码）。

相对于 for 循环遍历，利用迭代器来遍历有下面三个优势：
- 迭代器模式封装集合内部的复杂数据结构，开发者不需要了解如何遍历，直接使用容器提供的迭代器即可；
- 迭代器模式将集合对象的遍历操作从集合类中拆分出来，放到迭代器类中，让两者的职责更加单一；
- 迭代器模式让添加新的遍历算法更加容易，更符合开闭原则。除此之外，因为迭代器都实现自相同的接口，在开发中，基于接口而非实现编程，替换迭代器也变得更加容易；

## 在遍历的同时增删集合元素会发生什么？
在通过迭代器来遍历集合元素的同时，增加或者删除集合中的元素，有可能会导致某个元素被重复遍历或遍历不到。不过，并不是所有情况下都会遍历出错，有的时候也可以正常遍历，所以，这种行为称为`未决行为`，也就是说，运行结果到底是对还是错，要视情况而定。我们通过一个例子来解释一下：
```java
public interface Iterator<E> 
{
    boolean hasNext();
    void next();
    E currentItem();
}

public class ArrayIterator<E> implements Iterator<E> 
{
    private int cursor;
    private ArrayList<E> arrayList;

    public ArrayIterator(ArrayList<E> arrayList) 
    {
        this.cursor = 0;
        this.arrayList = arrayList;
    }

    @Override
    public boolean hasNext() 
    {
        return cursor < arrayList.size();
    }

    @Override
    public void next() 
    {
        cursor++;
    }

    @Override
    public E currentItem() 
    {
        if (cursor >= arrayList.size()) 
        {
            throw new NoSuchElementException();
        }
        return arrayList.get(cursor);
    }
}

public interface List<E> 
{
    Iterator iterator();
}

public class ArrayList<E> implements List<E> 
{
    //...
    public Iterator iterator() 
    {
        return new ArrayIterator(this);
    }
    //...
}

public class Demo 
{
    public static void main(String[] args) 
    {
        List<String> names = new ArrayList<>();
        names.add("a");
        names.add("b");
        names.add("c");
        names.add("d");

        Iterator<String> iterator = names.iterator();
        iterator.next();
        names.remove("a");
    }
}
```

我们知道，ArrayList 底层对应的是数组这种数据结构，在执行完第 67 行代码的时候，数组中存储的是 a、b、c、d 四个元素，迭代器的游标 cursor 指向元素 a。当执行完第 68 行代码的时候，游标指向元素 b，到这里都没有问题。

**为了保持数组存储数据的连续性，数组的删除操作会涉及元素的搬移**。当执行到第 69 行代码的时候，我们从数组中将元素 a 删除掉，b、c、d 三个元素会依次往前搬移一位，这就会导致游标本来指向元素 b，现在变成了指向元素 c。原本在执行完第 68 行代码之后，我们还可以遍历到 b、c、d 三个元素，但在执行完第 69 行代码之后，我们只能遍历到 c、d 两个元素，b 遍历不到了：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/GoF/27.png)

还是结合刚刚那个例子来讲解，我们将上面的代码稍微改造一下，**把删除元素改为添加元素**。具体的代码如下所示：
```java
public class Demo 
{
    public static void main(String[] args) 
    {
        List<String> names = new ArrayList<>();
        names.add("a");
        names.add("b");
        names.add("c");
        names.add("d");

        Iterator<String> iterator = names.iterator();
        iterator.next();
        names.add(0, "x");
    }
}
```

在执行完第 12 行代码之后，数组中包含 a、b、c、d 四个元素，游标指向 b 这个元素，已经跳过了元素 a。在执行完第 13 行代码之后，我们将 x 插入到下标为 0 的位置，a、b、c、d 四个元素依次往后移动一位。这个时候，游标又重新指向了元素 a。元素 a 被游标重复指向两次，也就是说，元素 a 存在被重复遍历的情况：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/GoF/28.png)

## 如何应对遍历时改变集合导致的未决行为？
当通过迭代器来遍历集合的时候，增加、删除集合元素会导致不可预期的遍历结果。实际上，**不可预期比直接出错更加可怕**，有的时候运行正确，有的时候运行错误，一些隐藏很深、很难 debug 的 bug 就是这么产生的。

有两种比较干脆利索的解决方案：
1. 遍历的时候不允许增删元素；
2. 增删元素之后让遍历报错；

实际上，**第一种解决方案比较难实现，我们要确定遍历开始和结束的时间点**。遍历开始的时间节点我们很容易获得。我们可以把创建迭代器的时间点作为遍历开始的时间点。但是，遍历结束的时间点该如何来确定呢？在实际的软件开发中，**每次使用迭代器来遍历元素，并不一定非要把所有元素都遍历一遍**。你可能还会说，那我们可以在迭代器类中定义一个新的接口 finishIteration()，主动告知容器迭代器使用完了，你可以增删元素了。但是，这就要求程序员在使用完迭代器之后要主动调用这个函数，也**增加了开发成本，还很容易漏掉**。

第二种解决方法更加合理。Java 语言就是采用的这种解决方案，**增删元素之后，让遍历报错**。我们在 ArrayList 中定义一个成员变量 modCount，记录集合被修改的次数，集合每调用一次增加或删除元素的函数，就会给 modCount 加 1。当通过调用集合上的 iterator() 函数来创建迭代器的时候，我们把 modCount 值传递给迭代器的 expectedModCount 成员变量，之后**每次调用迭代器上的 hasNext()、next()、currentItem() 函数，我们都会检查集合上的 modCount 是否等于 expectedModCount**。

如果两个值不相同，那就说明集合存储的元素已经改变了，要么增加了元素，要么删除了元素，之前创建的迭代器已经不能正确运行了，再继续使用就会产生不可预期的结果，所以我们选择 `fail-fast` 解决方式，抛出运行时异常，结束掉程序，让程序员尽快修复这个因为不正确使用迭代器而产生的 bug：
```java
public class ArrayIterator implements Iterator 
{
    private int cursor;
    private ArrayList arrayList;
    private int expectedModCount;

    public ArrayIterator(ArrayList arrayList) 
    {
        this.cursor = 0;
        this.arrayList = arrayList;
        this.expectedModCount = arrayList.modCount;
    }

    @Override
    public boolean hasNext() 
    {
        checkForModification();
        return cursor < arrayList.size();
    }

    @Override
    public void next() 
    {
        checkForModification();
        cursor++;
    }

    @Override
    public Object currentItem() 
    {
        checkForModification();
        return arrayList.get(cursor);
    }
    
    private void checkForModification() 
    {
        if (arrayList.modCount != expectedModCount) 
        {
            throw new ConcurrentModificationException();
        }
    }
}

// 代码示例
public class Demo 
{
    public static void main(String[] args) 
    {
        List<String> names = new ArrayList<>();
        names.add("a");
        names.add("b");
        names.add("c");
        names.add("d");

        Iterator<String> iterator = names.iterator();
        iterator.next();
        names.remove("a");
        iterator.next(); // 抛出 ConcurrentModificationException 异常
    }
}
```

## 如何在遍历的同时安全地删除集合元素？
像 Java 语言，迭代器类中除了前面提到的几个最基本的方法之外，还定义了一个 `remove() 方法`，能够在遍历集合的同时，安全地删除集合中的元素。不过，需要说明的是，它并没有提供添加元素的方法。毕竟迭代器的主要作用是遍历，添加元素放到迭代器里本身就不合适。我个人觉得，Java 迭代器中提供的 remove() 方法还是比较鸡肋的，作用有限。它**只能删除游标指向的前一个元素，而且一个 next() 函数之后，只能跟着最多一个 remove() 操作**，多次调用 remove() 操作会报错：
```java
public class Demo 
{
    public static void main(String[] args) 
    {
        List<String> names = new ArrayList<>();
        names.add("a");
        names.add("b");
        names.add("c");
        names.add("d");

        Iterator<String> iterator = names.iterator();
        iterator.next();
        iterator.remove();
        iterator.remove(); // 报错，抛出 IllegalStateException 异常
    }
}
```

我们来看下 remove() 函数是如何实现的。稍微提醒一下，在 Java 实现中，**迭代器类是容器类的内部类，并且 next() 函数不仅将游标后移一位，还会返回当前的元素**。代码如下所示：
```java
public class ArrayList<E> 
{
    transient Object[] elementData;
    private int size;

    public Iterator<E> iterator() 
    {
        return new Itr();
    }

    private class Itr implements Iterator<E> 
    {
        int cursor;       // index of next element to return
        int lastRet = -1; // index of last element returned; -1 if no such element
        int expectedModCount = modCount;

        Itr() {}

        public boolean hasNext() 
        {
            return cursor != size;
        }

        @SuppressWarnings("unchecked")
        public E next() 
        {
            checkForModification();
            int i = cursor;
            if (i >= size)
            {
                throw new NoSuchElementException();
            }
            Object[] elementData = ArrayList.this.elementData;
            if (i >= elementData.length)
            {
                throw new ConcurrentModificationException();
            }
            cursor = i + 1;
            return (E) elementData[lastRet = i];
        }
        
        public void remove() 
        {
            if (lastRet < 0)
            {
                throw new IllegalStateException();
            }
            checkForModification();

            try 
            {
                ArrayList.this.remove(lastRet);
                cursor = lastRet;
                lastRet = -1;
                expectedModCount = modCount;
            } 
            catch (IndexOutOfBoundsException ex) 
            {
                throw new ConcurrentModificationException();
            }
        }
    }
}
```

在上面的代码实现中，**迭代器类新增了一个 lastRet 成员变量，用来记录游标指向的前一个元素**。通过迭代器去删除这个元素的时候，我们可以更新迭代器中的游标和 lastRet 值，来保证不会因为删除元素而导致某个元素遍历不到。如果通过容器来删除元素，并且希望更新迭代器中的游标值来保证遍历不出错，我们就要**维护这个容器都创建了哪些迭代器，每个迭代器是否还在使用等信息**，代码实现就变得比较复杂了。

## 问题描述
如何实现一个支持“快照”功能的迭代器模式？理解这个问题最关键的是理解“快照”两个字。所谓“快照”，指我们为容器创建迭代器的时候，相当于给容器拍了一张快照（Snapshot）。之后即便我们增删容器中的元素，快照中的元素并不会做相应的改动。而**迭代器遍历的对象是快照而非容器，这样就避免了在使用迭代器遍历的过程中，增删容器中的元素，导致的不可预期的结果或者报错**。

容器 list 中初始存储了 3、8、2 三个元素。尽管在创建迭代器 iter1 之后，容器 list 删除了元素 3，只剩下 8、2 两个元素，但是，通过 iter1 遍历的对象是快照，而非容器 list 本身。所以，遍历的结果仍然是 3、8、2。同理，iter2、iter3 也是在各自的快照上遍历，输出的结果如代码中注释所示：
```java
List<Integer> list = new ArrayList<>();
list.add(3);
list.add(8);
list.add(2);

Iterator<Integer> iter1 = list.iterator(); // snapshot: 3, 8, 2
list.remove(new Integer(2)); // list：3, 8
Iterator<Integer> iter2 = list.iterator(); // snapshot: 3, 8
list.remove(new Integer(3));// list：8
Iterator<Integer> iter3 = list.iterator(); // snapshot: 3

// 输出结果：3 8 2
while (iter1.hasNext()) 
{
    System.out.print(iter1.next() + " ");
}
System.out.println();

// 输出结果：3 8
while (iter2.hasNext()) 
{
    System.out.print(iter1.next() + " ");
}
System.out.println();

// 输出结果：8
while (iter3.hasNext()) 
{
    System.out.print(iter1.next() + " ");
}
System.out.println();
```

下面是针对这个功能需求的骨架代码，其中包含 ArrayList、SnapshotArrayIterator 两个类。对于这两个类，我**只定义了必须的几个关键接口，完整的代码实现我并没有给出**：
```java
public ArrayList<E> implements List<E> 
{
    // TODO: 成员变量、私有函数等随便你定义
    
    @Override
    public void add(E obj) 
    {
        // TODO: 由你来完善
    }
    
    @Override
    public void remove(E obj) 
    {
        // TODO: 由你来完善
    }
    
    @Override
    public Iterator<E> iterator() 
    {
        return new SnapshotArrayIterator(this);
    }
}

public class SnapshotArrayIterator<E> implements Iterator<E> 
{
    // TODO: 成员变量、私有函数等随便你定义
    
    @Override
    public boolean hasNext() 
    {
        // TODO: 由你来完善
    }
    
    @Override
    public E next() 
    {
        // 返回当前元素，并且游标后移一位
        // TODO: 由你来完善
    }
}
```

## 解决方案一
在迭代器类中定义一个成员变量 snapshot 来存储快照。**每当创建迭代器的时候，都拷贝一份容器中的元素到快照中**，后续的遍历操作都基于这个迭代器自己持有的快照来进行：
```java
public class SnapshotArrayIterator<E> implements Iterator<E> 
{
    private int cursor;
    private ArrayList<E> snapshot;

    public SnapshotArrayIterator(ArrayList<E> arrayList) 
    {
        this.cursor = 0;
        this.snapshot = new ArrayList<>();
        this.snapshot.addAll(arrayList);
    }

    @Override
    public boolean hasNext() 
    {
        return cursor < snapshot.size();
    }

    @Override
    public E next() 
    {
        E currentItem = snapshot.get(cursor);
        cursor++;
        return currentItem;
    }
}
```

这个解决方案虽然简单，但代价也有点高。**每次创建迭代器的时候，都要拷贝一份数据到快照中，会增加内存的消耗**。如果一个容器同时有多个迭代器在遍历元素，就会导致数据在内存中重复存储多份。不过，庆幸的是，Java 中的拷贝属于`浅拷贝`，也就是说，容器中的对象并非真的拷贝了多份，而只是拷贝了对象的引用而已。

## 解决方案二
我们可以在容器中，**为每个元素保存两个时间戳，一个是添加时间戳 addTimestamp，一个是删除时间戳 delTimestamp**。当元素被加入到集合中的时候，我们将 addTimestamp 设置为当前时间，将 delTimestamp 设置成最大长整型值（Long.MAX_VALUE）。当元素被删除时，我们将 delTimestamp 更新为当前时间，表示已经被删除。

同时，**每个迭代器也保存一个迭代器创建时间戳 snapshotTimestamp，也就是迭代器对应的快照的创建时间戳**。当使用迭代器来遍历容器的时候，只有满足 `addTimestamp < snapshotTimestamp < delTimestamp` 的元素，才是属于这个迭代器的快照。这样就在不拷贝容器的情况下，在容器本身上借助时间戳实现了快照功能。具体的代码实现如下所示：
```java
public class ArrayList<E> implements List<E> 
{
    private static final int DEFAULT_CAPACITY = 10;

    private int actualSize; // 不包含标记删除元素
    private int totalSize; // 包含标记删除元素

    private Object[] elements;
    private long[] addTimestamps;
    private long[] delTimestamps;

    public ArrayList() 
    {
        this.elements = new Object[DEFAULT_CAPACITY];
        this.addTimestamps = new long[DEFAULT_CAPACITY];
        this.delTimestamps = new long[DEFAULT_CAPACITY];
        this.totalSize = 0;
        this.actualSize = 0;
    }

    @Override
    public void add(E obj) 
    {
        elements[totalSize] = obj;
        addTimestamps[totalSize] = System.currentTimeMillis();
        delTimestamps[totalSize] = Long.MAX_VALUE;
        totalSize++;
        actualSize++;
    }

    @Override
    public void remove(E obj) 
    {
        for (int i = 0; i < totalSize; ++i) 
        {
            if (elements[i].equals(obj) && delTimestamps[i] == Long.MAX_VALUE) // 防止重复删除
            {
                delTimestamps[i] = System.currentTimeMillis();
                actualSize--;
            }
        }
    }

    public int actualSize() 
    {
        return this.actualSize;
    }

    public int totalSize() 
    {
        return this.totalSize;
    }

    public E get(int i) 
    {
        if (i >= totalSize) 
        {
            throw new IndexOutOfBoundsException();
        }
        return (E)elements[i];
    }

    public long getAddTimestamp(int i) 
    {
        if (i >= totalSize) 
        {
            throw new IndexOutOfBoundsException();
        }
        return addTimestamps[i];
    }

    public long getDelTimestamp(int i) 
    {
        if (i >= totalSize) 
        {
            throw new IndexOutOfBoundsException();
        }
        return delTimestamps[i];
    }
}

public class SnapshotArrayIterator<E> implements Iterator<E> 
{
    private long snapshotTimestamp;
    private int cursorInAll; // 在整个容器中的下标，而非快照中的下标
    private int leftCount; // 快照中还有几个元素未被遍历
    private ArrayList<E> arrayList;

    public SnapshotArrayIterator(ArrayList<E> arrayList) 
    {
        this.snapshotTimestamp = System.currentTimeMillis();
        this.cursorInAll = 0;
        this.leftCount = arrayList.actualSize();;
        this.arrayList = arrayList;

        justNext(); // 先跳到这个迭代器快照的第一个元素
    }

    @Override
    public boolean hasNext() 
    {
        return cursorInAll < arrayList.totalSize()；
    }

    @Override
    public E next() 
    {
        E currentItem = arrayList.get(cursorInAll);
        justNext();
        cursorInAll++； // 自增，否则 cursorInAll 一直不变
        return currentItem;
    }

    private void justNext() 
    {
        while (cursorInAll < arrayList.totalSize()) 
        {
            long addTimestamp = arrayList.getAddTimestamp(cursorInAll);
            long delTimestamp = arrayList.getDelTimestamp(cursorInAll);
            if (snapshotTimestamp > addTimestamp && snapshotTimestamp < delTimestamp) 
            {
                leftCount--;
                break;
            }
            cursorInAll++;
        }
    }
}
```

实际上，上面的解决方案相当于解决了一个问题，又引入了另外一个问题。ArrayList 底层依赖数组这种数据结构，原本可以支持快速的随机访问，在 O(1) 时间复杂度内获取下标为 i 的元素，但现在，**删除数据并非真正的删除，只是通过时间戳来标记删除，这就导致无法支持按照下标快速随机访问了**。

解决的方法也不难，我稍微提示一下。我们可以**在 ArrayList 中存储两个数组：一个支持标记删除的，用来实现快照遍历功能；一个不支持标记删除的（也就是将要删除的数据直接从数组中移除）**，用来支持随机访问。
