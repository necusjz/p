---
title: Flyweight Design Pattern
date: 2020-12-09 23:16:07
tags:
  - GoF
---
## 享元模式原理与实现
所谓`享元`，顾名思义就是被共享的单元。享元模式的意图是**复用对象，节省内存，前提是享元对象是不可变对象**。

具体来讲，当一个系统中存在大量重复对象的时候，如果这些重复的对象是不可变对象，我们就可以利用享元模式将对象设计成享元，在内存中只保留一份实例，供多处代码引用。这样可以减少内存中对象的数量，起到节省内存的目的。实际上，不仅仅相同对象可以设计成享元，**对于相似对象，我们也可以将这些对象中相同的部分（字段）提取出来，设计成享元**，让这些大量相似对象引用这些享元。

这里我稍微解释一下，定义中的`不可变对象`指的是，一旦通过构造函数初始化完成之后，它的状态（对象的成员变量或者属性）就不会再被修改了。所以，**不可变对象不能暴露任何 set() 等修改内部状态的方法**。之所以要求享元是不可变对象，那是因为它会被多处代码共享使用，避免一处代码对享元进行了修改，影响到其他使用它的代码。

假设我们在开发一个棋牌游戏（比如象棋）。一个游戏厅中有成千上万个“房间”，每个房间对应一个棋局。棋局要保存每个棋子的数据，比如：棋子类型（将、相、士、炮等）、棋子颜色（红方、黑方）、棋子在棋局中的位置。利用这些数据，我们就能显示一个完整的棋盘给玩家。其中，ChessPiece 类表示棋子，ChessBoard 类表示一个棋局，里面保存了象棋中 30 个棋子的信息：
<!--more-->
```java
public class ChessPiece 
{
    // 棋子
    private int id;
    private String text;
    private Color color;
    private int positionX;
    private int positionY;

    public ChessPiece(int id, String text, Color color, int positionX, int positionY) 
    {
        this.id = id;
        this.text = text;
        this.color = color;
        this.positionX = positionX;
        this.positionY = positionX;
    }

    public static enum Color 
    {
        RED, BLACK
    }

    //...省略其他属性和 getter/setter 方法...
}

public class ChessBoard 
{
    // 棋局
    private Map<Integer, ChessPiece> chessPieces = new HashMap<>();

    public ChessBoard() 
    {
        init();
    }

    private void init() 
    {
        chessPieces.put(1, new ChessPiece(1, "車", ChessPiece.Color.BLACK, 0, 0));
        chessPieces.put(2, new ChessPiece(2, "馬", ChessPiece.Color.BLACK, 0, 1));
        //...省略摆放其他棋子的代码...
    }

    public void move(int chessPieceId, int toPositionX, int toPositionY) 
    {
        //...省略...
    }
}
```

为了记录每个房间当前的棋局情况，我们需要给每个房间都创建一个 ChessBoard 棋局对象。因为游戏大厅中有成千上万的房间，那**保存这么多棋局对象就会消耗大量的内存**。

像刚刚的实现方式，在内存中会有大量的相似对象。这些相似对象的 id、text、color 都是相同的，唯独 positionX、positionY 不同。实际上，我们可以**将棋子的 id、text、color 属性拆分出来，设计成独立的类**，并且作为享元供多个棋盘复用。这样，棋盘只需要记录每个棋子的位置信息就可以了：
```java
// 享元类
public class ChessPieceUnit 
{
    private int id;
    private String text;
    private Color color;

    public ChessPieceUnit(int id, String text, Color color) 
    {
        this.id = id;
        this.text = text;
        this.color = color;
    }

    public static enum Color 
    {
        RED, BLACK
    }

    //...省略其他属性和 getter 方法...
}

public class ChessPieceUnitFactory 
{
    private static final Map<Integer, ChessPieceUnit> pieces = new HashMap<>();

    static 
    {
        pieces.put(1, new ChessPieceUnit(1, "車", ChessPieceUnit.Color.BLACK));
        pieces.put(2, new ChessPieceUnit(2, "馬", ChessPieceUnit.Color.BLACK));
        //...省略摆放其他棋子的代码...
    }

    public static ChessPieceUnit getChessPiece(int chessPieceId) 
    {
        return pieces.get(chessPieceId);
    }
}

public class ChessPiece 
{
    private ChessPieceUnit chessPieceUnit;
    private int positionX;
    private int positionY;

    public ChessPiece(ChessPieceUnit unit, int positionX, int positionY) 
    {
        this.chessPieceUnit = unit;
        this.positionX = positionX;
        this.positionY = positionY;
    }
    // 省略 getter、setter 方法
}

public class ChessBoard 
{
    private Map<Integer, ChessPiece> chessPieces = new HashMap<>();

    public ChessBoard() 
    {
        init();
    }

    private void init() 
    {
        chessPieces.put(1, new ChessPiece(ChessPieceUnitFactory.getChessPiece(1), 0, 0));
        chessPieces.put(1, new ChessPiece(ChessPieceUnitFactory.getChessPiece(2), 1, 0));
        //...省略摆放其他棋子的代码...
    }

    public void move(int chessPieceId, int toPositionX, int toPositionY) 
    {
        //...省略...
    }
}
```

在上面的代码实现中，我们利用工厂类来缓存 ChessPieceUnit 信息（也就是 id、text、color）。通过工厂类获取到的 ChessPieceUnit 就是享元。所有的 ChessBoard 对象共享这 30 个 ChessPieceUnit 对象。在使用享元模式之前，记录 1 万个棋局，我们要创建 30 万个棋子的 ChessPieceUnit 对象。利用享元模式，我们只需要创建 30 个享元对象供所有棋局共享使用即可，大大节省了内存。

实际上，它的代码实现非常简单，主要是**通过工厂模式，在工厂类中，通过一个 Map 来缓存已经创建过的享元对象**，来达到复用的目的。

## 享元模式在文本编辑器中的应用
你可以把这里提到的文本编辑器想象成 Office 的 Word。不过，为了简化需求背景，我们**假设这个文本编辑器只实现了文字编辑功能**，不包含图片、表格等复杂的编辑功能。对于简化之后的文本编辑器，我们要在内存中表示一个文本文件，只需要记录文字和格式两部分信息就可以了，其中，格式又包括文字的字体、大小、颜色等信息。

尽管在实际的文档编写中，我们一般都是按照文本类型来设置文字的格式，标题是一种格式，正文是另一种格式等等。但是，从理论上讲，我们可以给文本文件中的每个文字都设置不同的格式。为了实现如此灵活的格式设置，并且代码实现又不过于太复杂，我们把每个文字都当作一个独立的对象来看待，并且在其中包含它的格式信息：
```java
public class Character 
{
    // 文字
    private char c;

    private Font font;
    private int size;
    private int colorRGB;

    public Character(char c, Font font, int size, int colorRGB) 
    {
        this.c = c;
        this.font = font;
        this.size = size;
        this.colorRGB = colorRGB;
    }
}

public class Editor 
{
    private List<Character> chars = new ArrayList<>();

    public void appendCharacter(char c, Font font, int size, int colorRGB) 
    {
        Character character = new Character(c, font, size, colorRGB);
        chars.add(character);
    }
}
```

在文本编辑器中，我们每敲一个文字，都会调用 Editor 类中的 appendCharacter() 方法，创建一个新的 Character 对象，保存到 chars 数组中。如果一个文本文件中，有上万、十几万、几十万的文字，那我们就要在内存中存储这么多 Character 对象。

实际上，在一个文本文件中，用到的字体格式不会太多，毕竟不大可能有人把每个文字都设置成不同的格式。所以，**对于字体格式，我们可以将它设计成享元**，让不同的文字共享使用。按照这个设计思路，我们对上面的代码进行重构：
```java
public class CharacterStyle 
{
    private Font font;
    private int size;
    private int colorRGB;

    public CharacterStyle(Font font, int size, int colorRGB) 
    {
        this.font = font;
        this.size = size;
        this.colorRGB = colorRGB;
    }

    @Override
    public boolean equals(Object o) 
    {
        CharacterStyle otherStyle = (CharacterStyle) o;
        return font.equals(otherStyle.font) && size == otherStyle.size && colorRGB == otherStyle.colorRGB;
    }
}

public class CharacterStyleFactory
{
    private static final List<CharacterStyle> styles = new ArrayList<>();

    public static CharacterStyle getStyle(Font font, int size, int colorRGB) 
    {
        CharacterStyle newStyle = new CharacterStyle(font, size, colorRGB);
        for (CharacterStyle style : styles) 
        {
            if (style.equals(newStyle)) 
            {
                return style;
            }
        }
        styles.add(newStyle);
        return newStyle;
    }
}

public class Character 
{
    private char c;
    private CharacterStyle style;

    public Character(char c, CharacterStyle style) 
    {
        this.c = c;
        this.style = style;
    }
}

public class Editor 
{
    private List<Character> chars = new ArrayList<>();

    public void appendCharacter(char c, Font font, int size, int colorRGB) 
    {
        Character character = new Character(c, CharacterStyleFactory.getStyle(font, size, colorRGB));
        chars.add(character);
    }
}
```

## 享元模式 vs. 单例、缓存、对象池
在上面的讲解中，我们多次提到“共享”、“缓存”、“复用”这些字眼，那它跟单例、缓存、对象池这些概念有什么区别呢？

### 享元 vs. 单例
在单例模式中，一个类只能创建一个对象，而在享元模式中，一个类可以创建多个对象，每个对象被多处代码引用共享。实际上，享元模式有点类似于之前讲到的单例的变体：`多例`。

我们前面也多次提到，区别两种设计模式，**不能光看代码实现，而是要看设计意图，也就是要解决的问题**。尽管从代码实现上来看，享元模式和多例有很多相似之处，但从设计意图上来看，它们是完全不同的。应用享元模式是为了对象复用，节省内存，而**应用多例模式是为了限制对象的个数**。

### 享元 vs. 缓存
在享元模式的实现中，我们通过工厂类来“缓存”已经创建好的对象。这里的“缓存”实际上是“存储”的意思，跟我们平时所说的“数据库缓存”、“CPU 缓存”、“MemCache 缓存”是两回事。我们平时所讲的**缓存，主要是为了提高访问效率，而非复用**。

### 享元 vs. 对象池
像 C++ 这样的编程语言，内存的管理是由程序员负责的。为了避免频繁地进行对象创建和释放导致内存碎片，我们可以**预先申请一片连续的内存空间，也就是这里说的对象池**。每次创建对象时，我们从对象池中直接取出一个空闲对象来使用，对象使用完成之后，再放回到对象池中以供后续复用，而非直接释放掉。

**池化技术中的“复用”可以理解为“重复使用”，主要目的是节省时间**。在任意时刻，每一个对象、连接、线程，并不会被多处使用，而是被一个使用者独占，当使用完成之后，放回到池中，再由其他使用者重复利用。**享元模式中的“复用”可以理解为“共享使用”，在整个生命周期中，都是被所有使用者共享的，主要目的是节省空间**。

## 享元模式在 Java Integer 中的应用
我们先来看下面这样一段代码。你可以先思考下，这段代码会输出什么样的结果：
```java
Integer i1 = 56;
Integer i2 = 56;
Integer i3 = 129;
Integer i4 = 129;
System.out.println(i1 == i2);
System.out.println(i3 == i4);
```

如果不熟悉 Java 语言，你可能会觉得，i1 和 i2 值都是 56，i3 和 i4 值都是 129，i1 跟 i2 值相等，i3 跟 i4 值相等，所以输出结果应该是两个 true。这样的分析是不对的，主要还是因为你对 Java 语法不熟悉。要正确地分析上面的代码，我们需要弄清楚下面两个问题：
- 如何判定两个 Java 对象是否相等；
- 什么是`自动装箱`（Autoboxing）和`自动拆箱`（Unboxing）；

Java 为基本数据类型提供了对应的包装器类型。具体如下所示：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/GoF/16.png)

所谓的自动装箱，就是自动将基本数据类型转换为**包装器类型**。所谓的自动拆箱，也就是自动将包装器类型转化为基本数据类型。具体的代码示例如下所示：
```java
Integer i = 56; // 自动装箱
int j = i; // 自动拆箱
```

数值 56 是基本数据类型 int，当赋值给包装器类型（Integer）变量的时候，触发自动装箱操作，创建一个 Integer 类型的对象，并且赋值给变量 i。其底层相当于执行了下面这条语句：
```java
Integer i = 56；// 底层执行了：Integer i = Integer.valueOf(56);
```

反过来，当把包装器类型的变量 i，赋值给基本数据类型变量 j 的时候，触发自动拆箱操作，将 i 中的数据取出，赋值给 j。其底层相当于执行了下面这条语句：
```java
int j = i; // 底层执行了：int j = i.intValue();
```

弄清楚了自动装箱和自动拆箱，我们再来看，如何判定两个对象是否相等？不过，在此之前，我们先要搞清楚，**Java 对象在内存中是如何存储的**：
```java
User a = new User(123, 23); // id=123, age=23
```

针对这条语句，我画了一张内存存储结构图。a 存储的值是 User 对象的内存地址，在图中就表现为 a 指向 User 对象。当我们通过“==”来判定两个对象是否相等的时候，实际上是在判断两个局部变量存储的地址是否相同，换句话说，是在**判断两个局部变量是否指向相同的对象**：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/GoF/17.png)

Integer 用到了享元模式来复用对象。当我们通过自动装箱，也就是调用 valueOf() 来创建 Integer 对象的时候，如果要创建的 Integer 对象的值在 -128 到 127 之间，会从 IntegerCache 类中直接返回，否则才调用 new 方法创建。看代码更加清晰一些，Integer 类的 valueOf() 函数的具体代码如下所示：
```java
public static Integer valueOf(int i) 
{
    if (i >= IntegerCache.low && i <= IntegerCache.high)
    {
        return IntegerCache.cache[i + (-IntegerCache.low)];
    }
    return new Integer(i);
}
```

实际上，这里的 **IntegerCache 相当于生成享元对象的工厂类**，只不过名字不叫 xxxFactory 而已。我们来看它的具体代码实现：
```java
/**
 * Cache to support the object identity semantics of autoboxing for values between
 * -128 and 127 (inclusive) as required by JLS.
 *
 * The cache is initialized on first usage.  The size of the cache
 * may be controlled by the {@code -XX:AutoBoxCacheMax=<size>} option.
 * During VM initialization, java.lang.Integer.IntegerCache.high property
 * may be set and saved in the private system properties in the
 * sun.misc.VM class.
 */
private static class IntegerCache 
{
    static final int low = -128;
    static final int high;
    static final Integer cache[];

    static 
    {
        // high value may be configured by property
        int h = 127;
        String integerCacheHighPropValue = sun.misc.VM.getSavedProperty("java.lang.Integer.IntegerCache.high");
        if (integerCacheHighPropValue != null) 
        {
            try 
            {
                int i = parseInt(integerCacheHighPropValue);
                i = Math.max(i, 127);
                // Maximum array size is Integer.MAX_VALUE
                h = Math.min(i, Integer.MAX_VALUE - (-low) -1);
            } 
            catch ( NumberFormatException nfe) 
            {
                // If the property cannot be parsed into an int, ignore it.
            }
        }
        high = h;

        cache = new Integer[(high - low) + 1];
        int j = low;
        for(int k = 0; k < cache.length; k++)
        {
            cache[k] = new Integer(j++);
        }

        // range [-128, 127] must be interned (JLS7 5.1.7)
        assert IntegerCache.high >= 127;
    }

    private IntegerCache() {}
}
```

在 IntegerCache 的代码实现中，当这个类被加载的时候，缓存的享元对象会被集中一次性创建好（-128~127）。实际上，**JDK 也提供了方法来让我们可以自定义缓存的最大值**，如果你通过分析应用的 JVM 内存占用情况，发现 -128 到 255 之间的数据占用的内存比较多，你就可以用如下方式，将缓存的最大值从 127 调整到 255：
```java
// 方法一：
-Djava.lang.Integer.IntegerCache.high=255
// 方法二：
-XX:AutoBoxCacheMax=255
```

因为 56 处于 -128 和 127 之间，i1 和 i2 会指向相同的享元对象，所以 i1==i2 返回 true。而 129 大于 127，并不会被缓存，每次都会创建一个全新的对象，也就是说，i3 和 i4 指向不同的 Integer 对象，所以 i3==i4 返回 false。

在我们平时的开发中，对于下面这样三种创建整型对象的方式，我们优先使用后两种：
```java
Integer a = new Integer(123);
Integer a = 123;
Integer a = Integer.valueOf(123);
```

第一种创建方式并不会使用到 IntegerCache，而后面两种创建方法可以利用 IntegerCache 缓存，返回共享的对象，以**达到节省内存的目的**。举一个极端一点的例子，假设程序需要创建 1 万个 -128 到 127 之间的 Integer 对象。使用第一种创建方式，我们需要分配 1 万个 Integer 对象的内存空间；使用后两种创建方式，我们最多只需要分配 256 个 Integer 对象的内存空间。

## 享元模式在 Java String 中的应用
同样，我们还是先来看一段代码，你觉得这段代码输出的结果是什么呢：
```java
String s1 = "小争哥";
String s2 = "小争哥";
String s3 = new String("小争哥");

System.out.println(s1 == s2);
System.out.println(s1 == s3);
```

上面代码的运行结果是：一个 true，一个 false。跟 Integer 类的设计思路相似，String 类利用享元模式来复用相同的字符串常量（也就是代码中的“小争哥”）。JVM 会专门开辟一块存储区来存储字符串常量，这块存储区叫作`字符串常量池`。上面代码对应的内存存储结构如下所示：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/GoF/18.png)

不过，String 类的享元模式的设计，跟 Integer 类稍微有些不同。Integer 类中要共享的对象，是**在类加载的时候，就集中一次性创建好**的。但是，对于字符串来说，我们没法事先知道要共享哪些字符串常量，所以没办法事先创建好，只能**在某个字符串常量第一次被用到的时候，存储到常量池中**，当之后再用到的时候，直接引用常量池中已经存在的即可，就不需要再重新创建了。

实际上，**享元模式对 JVM 的垃圾回收并不友好**。因为享元工厂类一直保存了对享元对象的引用，这就导致享元对象在没有任何代码使用的情况下，也并不会被 JVM 垃圾回收机制自动回收掉。因此，在某些情况下，如果对象的生命周期很短，也不会被密集使用，利用享元模式反倒可能会浪费更多的内存。所以，**除非经过线上验证，利用享元模式真的可以大大节省内存，否则，就不要过度使用这个模式**，为了一点点内存的节省而引入一个复杂的设计模式，得不偿失。
