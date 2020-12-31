---
title: Decorator Design Pattern
date: 2020-12-05 19:25:33
tags:
  - GoF
---
## Java IO 类的“奇怪”用法
Java IO 类库非常庞大和复杂，有几十个类，负责 IO 数据的读取和写入。如果对 Java IO 类做一下分类，我们可以从下面两个维度将它划分为四类：
![](https://raw.githubusercontent.com/was48i/mPOST/master/GoF/13.png)

针对不同的读取和写入场景，Java IO 又在这四个父类基础之上，扩展出了很多子类。具体如下所示：
<!--more-->
![](https://raw.githubusercontent.com/was48i/mPOST/master/GoF/14.png)

在我初学 Java 的时候，曾经对 Java IO 的一些用法产生过很大疑惑。比如下面这样一段代码，其中，InputStream 是一个抽象类，FileInputStream 是专门用来读取文件流的子类。BufferedInputStream 是一个支持带缓存功能的数据读取类，可以提高数据读取的效率：
```java
InputStream in = new FileInputStream("/user/wangzheng/test.txt");
InputStream bin = new BufferedInputStream(in);
byte[] data = new byte[128];
while (bin.read(data) != -1) 
{
    //...
}
```

初看上面的代码，我们会觉得 Java IO 的用法比较麻烦，需要先创建一个 FileInputStream 对象，然后再传递给 BufferedInputStream 对象来使用。我在想，Java IO 为什么不设计一个继承 FileInputStream 并且支持缓存的 BufferedFileInputStream 类呢？这样我们就可以像下面的代码中这样，直接创建一个 BufferedFileInputStream 类对象，打开文件读取数据：
```java
InputStream bin = new BufferedFileInputStream("/user/wangzheng/test.txt");
byte[] data = new byte[128];
while (bin.read(data) != -1) 
{
    //...
}
```

## 基于继承的设计方案
如果 InputStream 只有一个子类 FileInputStream 的话，那我们在 FileInputStream 基础之上，再设计一个孙子类 BufferedFileInputStream，也算是可以接受的，毕竟继承结构还算简单。但实际上，继承 InputStream 的子类有很多。我们需要给每一个 InputStream 的子类，再继续派生支持缓存读取的子类。

除了支持缓存读取之外，如果我们还需要对功能进行其他方面的增强，比如下面的 DataInputStream 类，支持按照基本数据类型（int、boolean、long 等）来读取数据：
```java
FileInputStream in = new FileInputStream("/user/wangzheng/test.txt");
DataInputStream din = new DataInputStream(in);
int data = din.readInt();
```

在这种情况下，如果我们继续按照继承的方式来实现的话，就需要再继续派生出 DataFileInputStream、DataPipedInputStream 等类。如果我们还需要既支持缓存、又支持按照基本类型读取数据的类，那就要再继续派生出 BufferedDataFileInputStream、BufferedDataPipedInputStream 等 n 多类。这还只是附加了两个增强功能，如果我们需要附加更多的增强功能，那就会导致组合爆炸，**类继承结构变得无比复杂，代码既不好扩展，也不好维护**。

## 基于装饰器模式的设计方案
针对刚刚的继承结构过于复杂的问题，我们可以通过**将继承关系改为组合关系**来解决。下面的代码展示了 Java IO 的这种设计思路：
```java
public abstract class InputStream 
{
    //...
    public int read(byte b[]) throws IOException 
    {
        return read(b, 0, b.length);
    }
    
    public int read(byte b[], int off, int len) throws IOException 
    {
        //...
    }
    
    public long skip(long n) throws IOException 
    {
        //...
    }

    public int available() throws IOException 
    {
        return 0;
    }
    
    public void close() throws IOException 
    {
        //...
    }

    public synchronized void mark(int readLimit) 
    {
        //...
    }
        
    public synchronized void reset() throws IOException 
    {
        throw new IOException("Mark/reset not supported.");
    }

    public boolean markSupported() 
    {
        return false;
    }
}

public class BufferedInputStream extends InputStream 
{
    protected volatile InputStream in;

    protected BufferedInputStream(InputStream in) 
    {
        this.in = in;
    }
    
    //...实现基于缓存的读数据接口...  
}

public class DataInputStream extends InputStream 
{
    protected volatile InputStream in;

    protected DataInputStream(InputStream in) 
    {
        this.in = in;
    }
    
    //...实现读取基本类型数据的接口
}
```

从 Java IO 的设计来看，装饰器模式相对于简单的组合关系，还有两个比较特殊的地方：
1. 装饰器类和原始类继承同样的父类，这样我们**可以对原始类“嵌套”多个装饰器类**。
比如，下面这样一段代码，我们对 FileInputStream 嵌套了两个装饰器类：BufferedInputStream 和 DataInputStream，让它既支持缓存读取，又支持按照基本数据类型来读取数据：
```java
InputStream in = new FileInputStream("/user/wangzheng/test.txt");
InputStream bin = new BufferedInputStream(in);
DataInputStream din = new DataInputStream(bin);
int data = din.readInt();
```
2. **装饰器类是对功能的增强**，这也是装饰器模式应用场景的一个重要特点。
实际上，符合“组合关系”这种代码结构的设计模式有很多，比如之前讲过的代理模式、桥接模式，还有现在的装饰器模式。尽管它们的代码结构很相似，但是每种设计模式的意图是不同的。就拿比较相似的代理模式和装饰器模式来说吧，**代理模式中，代理类附加的是跟原始类无关的功能，而在装饰器模式中，装饰器类附加的是跟原始类相关的增强功能**：
```java
// 代理模式的代码结构(下面的接口也可以替换成抽象类)
public interface IA 
{
    void f();
}
public class A implements IA 
{
    public void f() 
    {
        //... 
    }
}
public class AProxy implements IA 
{
    private IA a;
    public AProxy(IA a) 
    {
        this.a = a;
    }
    
    public void f() 
    {
        // 新添加的代理逻辑
        a.f();
        // 新添加的代理逻辑
    }
}

// 装饰器模式的代码结构(下面的接口也可以替换成抽象类)
public interface IA 
{
    void f();
}
public class A implements IA 
{
    public void f() 
    {
        //... 
    }
}
public class ADecorator implements IA 
{
    private IA a;
    public ADecorator(IA a) 
    {
        this.a = a;
    }
    
    public void f() 
    {
        // 功能增强代码
        a.f();
        // 功能增强代码
    }
}
```

实际上，如果去查看 JDK 的源码，你会发现，**BufferedInputStream、DataInputStream 并非继承自 InputStream，而是另外一个叫 FilterInputStream 的类**。因为对于即便是不需要增加缓存功能的函数来说，BufferedInputStream 还是必须把它重新实现一遍，简单包裹对 InputStream 对象的函数调用。如果不重新实现，那 BufferedInputStream 类就无法将最终读取数据的任务，委托给传递进来的 InputStream 对象来完成：
```java
public class BufferedInputStream extends InputStream 
{
    protected volatile InputStream in;

    protected BufferedInputStream(InputStream in) 
    {
        this.in = in;
    }
    
    // f() 函数不需要增强，只是重新调用一下 InputStream in 对象的 f()
    public void f() 
    {
        in.f();
    }  
}
```

实际上，DataInputStream 也存在跟 BufferedInputStream 同样的问题。**为了避免代码重复，Java IO 抽象出了一个装饰器父类 FilterInputStream**。InputStream 的所有的装饰器类都继承自这个装饰器父类。这样，装饰器类只需要实现它需要增强的方法就可以了，其他方法继承装饰器父类的默认实现：
```java
public class FilterInputStream extends InputStream 
{
    protected volatile InputStream in;

    protected FilterInputStream(InputStream in) 
    {
        this.in = in;
    }

    public int read() throws IOException 
    {
        return in.read();
    }

    public int read(byte b[]) throws IOException 
    {
        return read(b, 0, b.length);
    }
    
    public int read(byte b[], int off, int len) throws IOException 
    {
        return in.read(b, off, len);
    }

    public long skip(long n) throws IOException 
    {
        return in.skip(n);
    }

    public int available() throws IOException 
    {
        return in.available();
    }

    public void close() throws IOException 
    {
        in.close();
    }

    public synchronized void mark(int readLimit) 
    {
        in.mark(readLimit);
    }

    public synchronized void reset() throws IOException 
    {
        in.reset();
    }

    public boolean markSupported() 
    {
        return in.markSupported();
    }
}
```
