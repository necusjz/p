---
title: Visitor Design Pattern
date: 2020-12-23 20:48:55
tags:
  - GoF
---
## 带你“发明”访问者模式
假设我们从网站上爬取了很多资源文件，它们的格式有三种：PDF、PPT、WORD。我们现在要开发一个工具来处理这批资源文件。这个工具的其中一个功能是，**把这些资源文件中的文本内容抽取出来放到 txt 文件中**。其中，ResourceFile 是一个抽象类，包含一个抽象函数 extract2txt()。PDFFile、PPTFile、WORDFile 都继承 ResourceFile 类，并且重写了 extract2txt() 函数。在 ToolApplication 中，我们可以利用`多态特性`，根据对象的实际类型，来决定执行哪个方法：
<!--more-->
```java
public abstract class ResourceFile 
{
    protected String filePath;

    public ResourceFile(String filePath) 
    {
        this.filePath = filePath;
    }

    public abstract void extract2txt();
}

public class PPTFile extends ResourceFile 
{
    public PPTFile(String filePath) 
    {
        super(filePath);
    }

    @Override
    public void extract2txt() 
    {
        //...省略一大坨从 PPT 中抽取文本的代码...
        //...将抽取出来的文本保存在跟 filePath 同名的 txt 文件中...
        System.out.println("Extract PPT.");
    }
}

public class PDFFile extends ResourceFile 
{
    public PDFFile(String filePath) 
    {
        super(filePath);
    }

    @Override
    public void extract2txt() 
    {
        //...
        System.out.println("Extract PDF.");
    }
}

public class WORDFile extends ResourceFile 
{
    public WORDFile(String filePath) 
    {
        super(filePath);
    }

    @Override
    public void extract2txt() 
    {
        //...
        System.out.println("Extract WORD.");
    }
}

// 运行结果是：
// Extract PDF.
// Extract WORD.
// Extract PPT.
public class ToolApplication 
{
    public static void main(String[] args) 
    {
        List<ResourceFile> resourceFiles = listAllResourceFiles(args[0]);
        for (ResourceFile resourceFile : resourceFiles) 
        {
            resourceFile.extract2txt();
        }
    }

    private static List<ResourceFile> listAllResourceFiles(String resourceDirectory) 
    {
        List<ResourceFile> resourceFiles = new ArrayList<>();
        //...根据后缀（pdf/ppt/word）由工厂方法创建不同的类对象（PDFFile/PPTFile/WORDFile）
        resourceFiles.add(new PDFFile("a.pdf"));
        resourceFiles.add(new WORDFile("b.word"));
        resourceFiles.add(new PPTFile("c.ppt"));
        return resourceFiles;
    }
}
```

**如果工具的功能不停地扩展，不仅要能抽取文本内容，还要支持压缩、提取文件元信息（文件名、大小、更新时间等等）构建索引等一系列的功能**，那如果我们继续按照上面的实现思路，就会存在这样几个问题：
- 违背开闭原则，添加一个新的功能，所有类的代码都要修改；
- 虽然功能增多，每个类的代码都不断膨胀，可读性和可维护性都变差了；
- 把所有比较上层的业务逻辑都耦合到 PDFFile、PPTFile、WORDFile 类中，导致这些类的职责不够单一，变成了大杂烩；

针对上面的问题，我们常用的解决方法就是拆分解耦，**把业务操作跟具体的数据结构解耦，设计成独立的类**。这里我们按照访问者模式的演进思路来对上面的代码进行重构：
```java
public abstract class ResourceFile 
{
    protected String filePath;
    public ResourceFile(String filePath) 
    {
        this.filePath = filePath;
    }
}

public class PDFFile extends ResourceFile 
{
    public PDFFile(String filePath) 
    {
        super(filePath);
    }
    //...
}
//...PPTFile、WORDFile 代码省略...
public class Extractor 
{
    public void extract2txt(PPTFile pptFile) 
    {
        //...
        System.out.println("Extract PPT.");
    }

    public void extract2txt(PDFFile pdfFile) 
    {
        //...
        System.out.println("Extract PDF.");
    }

    public void extract2txt(WORDFile wordFile) 
    {
        //...
        System.out.println("Extract WORD.");
    }
}

public class ToolApplication 
{
    public static void main(String[] args) 
    {
        Extractor extractor = new Extractor();
        List<ResourceFile> resourceFiles = listAllResourceFiles(args[0]);
        for (ResourceFile resourceFile : resourceFiles) 
        {
            extractor.extract2txt(resourceFile);
        }
    }

    private static List<ResourceFile> listAllResourceFiles(String resourceDirectory) 
    {
        List<ResourceFile> resourceFiles = new ArrayList<>();
        //...根据后缀（pdf/ppt/word）由工厂方法创建不同的类对象（PDFFile/PPTFile/WORDFile）
        resourceFiles.add(new PDFFile("a.pdf"));
        resourceFiles.add(new WORDFile("b.word"));
        resourceFiles.add(new PPTFile("c.ppt"));
        return resourceFiles;
    }
}
```

这其中最关键的一点设计是，我们**把抽取文本内容的操作，设计成了三个重载函数**。函数重载是 Java、C++ 这类面向对象编程语言中常见的语法机制。所谓重载函数是指，在同一类中函数名相同、参数不同的一组函数。不过，如果你足够细心，就会发现，上面的代码是编译通过不了的，第 48 行会报错。

我们知道，多态是一种动态绑定，可以在运行时获取对象的实际类型，来运行实际类型对应的方法。而**函数重载是一种静态绑定，在编译时并不能获取对象的实际类型，而是根据声明类型执行声明类型对应的方法**。在上面代码的第 45~49 行中，resourceFiles 包含的对象的声明类型都是 ResourceFile，而我们并没有在 Extractor 类中定义参数类型是 ResourceFile 的 extract2txt() 重载函数，所以在编译阶段就通过不了，更别说在运行时根据对象的实际类型执行不同的重载函数了。解决的办法稍微有点难理解：
```java
public abstract class ResourceFile 
{
    protected String filePath;
    public ResourceFile(String filePath) 
    {
        this.filePath = filePath;
    }
    abstract public void accept(Extractor extractor);
}

public class PDFFile extends ResourceFile 
{
    public PDFFile(String filePath) 
    {
        super(filePath);
    }

    @Override
    public void accept(Extractor extractor) 
    {
        extractor.extract2txt(this);
    }

    //...
}

//...PPTFile、WORDFile 跟 PDFFile 类似，这里就省略了...
//...Extractor 代码不变...

public class ToolApplication 
{
    public static void main(String[] args) 
    {
        Extractor extractor = new Extractor();
        List<ResourceFile> resourceFiles = listAllResourceFiles(args[0]);
        for (ResourceFile resourceFile : resourceFiles) 
        {
            resourceFile.accept(extractor);
        }
    }

    private static List<ResourceFile> listAllResourceFiles(String resourceDirectory) 
    {
        List<ResourceFile> resourceFiles = new ArrayList<>();
        //...根据后缀（pdf/ppt/word）由工厂方法创建不同的类对象（PDFFile/PPTFile/WORDFile）
        resourceFiles.add(new PDFFile("a.pdf"));
        resourceFiles.add(new WORDFile("b.word"));
        resourceFiles.add(new PPTFile("c.ppt"));
        return resourceFiles;
    }
}
```

在执行第 38 行的时候，**根据多态特性，程序会调用实际类型的 accept 函数**，比如 PDFFile 的 accept 函数，也就是第 21 行代码。而 **21 行代码中的 this 类型是 PDFFile 的，在编译的时候就确定了**，所以会调用 extractor 的 extract2txt(PDFFile pdfFile) 这个重载函数。

现在，如果要继续添加新的功能，比如前面提到的压缩功能，根据不同的文件类型，使用不同的压缩算法来压缩资源文件。我们需要实现一个类似 Extractor 类的新类 Compressor 类，在其中**定义三个重载函数，实现对不同类型资源文件的压缩**。除此之外，我们还要**在每个资源文件类中定义新的 accept 重载函数**：
```java
public abstract class ResourceFile 
{
    protected String filePath;
    public ResourceFile(String filePath) 
    {
        this.filePath = filePath;
    }
    abstract public void accept(Extractor extractor);
    abstract public void accept(Compressor compressor);
}

public class PDFFile extends ResourceFile 
{
    public PDFFile(String filePath) 
    {
        super(filePath);
    }

    @Override
    public void accept(Extractor extractor) 
    {
        extractor.extract2txt(this);
    }

    @Override
    public void accept(Compressor compressor) 
    {
        compressor.compress(this);
    }

    //...
}
}
//...PPTFile、WORDFile 跟 PDFFile 类似，这里就省略了...
//...Extractor 代码不变

public class ToolApplication 
{
    public static void main(String[] args) 
    {
        Extractor extractor = new Extractor();
        List<ResourceFile> resourceFiles = listAllResourceFiles(args[0]);
        for (ResourceFile resourceFile : resourceFiles) 
        {
            resourceFile.accept(extractor);
        }

        Compressor compressor = new Compressor();
        for(ResourceFile resourceFile : resourceFiles) 
        {
            resourceFile.accept(compressor);
        }
    }

    private static List<ResourceFile> listAllResourceFiles(String resourceDirectory) 
    {
        List<ResourceFile> resourceFiles = new ArrayList<>();
        //...根据后缀（pdf/ppt/word）由工厂方法创建不同的类对象（PDFFile/PPTFile/WORDFile）
        resourceFiles.add(new PDFFile("a.pdf"));
        resourceFiles.add(new WORDFile("b.word"));
        resourceFiles.add(new PPTFile("c.ppt"));
        return resourceFiles;
    }
}
```

上面代码还存在一些问题，添加一个新的业务，还是需要修改每个资源文件类，违反了开闭原则。针对这个问题，我们**抽象出来一个 Visitor 接口，包含是三个命名非常通用的 visit() 重载函数，分别处理三种不同类型的资源文件**。具体做什么业务处理，由实现这个 Visitor 接口的具体的类来决定，比如 Extractor 负责抽取文本内容，Compressor 负责压缩。**当我们新添加一个业务功能的时候，资源文件类不需要做任何修改，只需要修改 ToolApplication 的代码就可以了**：
```java
public abstract class ResourceFile 
{
    protected String filePath;
    public ResourceFile(String filePath) 
    {
        this.filePath = filePath;
    }
    abstract public void accept(Visitor visitor);
}

public class PDFFile extends ResourceFile 
{
    public PDFFile(String filePath) 
    {
        super(filePath);
    }

    @Override
    public void accept(Visitor visitor) 
    {
        visitor.visit(this);
    }

    //...
}
//...PPTFile、WORDFile 跟 PDFFile 类似，这里就省略了...

public interface Visitor 
{
    void visit(PDFFile pdfFile);
    void visit(PPTFile pdfFile);
    void visit(WORDFile pdfFile);
}

public class Extractor implements Visitor 
{
    @Override
    public void visit(PPTFile pptFile) 
    {
        //...
        System.out.println("Extract PPT.");
    }

    @Override
    public void visit(PDFFile pdfFile) 
    {
        //...
        System.out.println("Extract PDF.");
    }

    @Override
    public void visit(WORDFile wordFile) 
    {
        //...
        System.out.println("Extract WORD.");
    }
}

public class Compressor implements Visitor 
{
    @Override
    public void visit(PPTFile pptFile) 
    {
        //...
        System.out.println("Compress PPT.");
    }

    @Override
    public void visit(PDFFile pdfFile) 
    {
        //...
        System.out.println("Compress PDF.");
    }

    @Override
    public void visit(WORDFile wordFile) 
    {
        //...
        System.out.println("Compress WORD.");
    }
}

public class ToolApplication 
{
    public static void main(String[] args) 
    {
        Extractor extractor = new Extractor();
        List<ResourceFile> resourceFiles = listAllResourceFiles(args[0]);
        for (ResourceFile resourceFile : resourceFiles) 
        {
            resourceFile.accept(extractor);
        }

        Compressor compressor = new Compressor();
        for(ResourceFile resourceFile : resourceFiles) 
        {
            resourceFile.accept(compressor);
        }
    }

    private static List<ResourceFile> listAllResourceFiles(String resourceDirectory) 
    {
        List<ResourceFile> resourceFiles = new ArrayList<>();
        //...根据后缀（pdf/ppt/word）由工厂方法创建不同的类对象（PDFFile/PPTFile/WORDFile）
        resourceFiles.add(new PDFFile("a.pdf"));
        resourceFiles.add(new WORDFile("b.word"));
        resourceFiles.add(new PPTFile("c.ppt"));
        return resourceFiles;
    }
}
```

## 重新来看访问者模式
`访问者者模式`的英文翻译是 Visitor Design Pattern。它是这么定义的：
> Allows for one or more operation to be applied to a set of objects at runtime, decoupling the operations from the object structure.

翻译成中文就是：**允许一个或者多个操作应用到一组对象上，解耦操作和对象本身**。对于访问者模式的代码实现，实际上，在上面例子中，经过层层重构之后的最终代码，就是标准的访问者模式的实现代码。这里，我又总结了一张类图，贴在了下面：
![](https://raw.githubusercontent.com/snlndod/mPOST/master/GoF/29.png)

一般来说，访问者模式针对的是一组类型不同的对象（PDFFile、PPTFile、WORDFile）。不过，尽管这组对象的类型是不同的，但是，它们继承相同的父类（ResourceFile）或者实现相同的接口。在不同的应用场景下，我们需要对这组对象进行一系列不相关的业务操作（抽取文本、压缩等），但**为了避免不断添加功能导致类不断膨胀，职责越来越不单一，以及避免频繁地添加功能导致的频繁代码修改**，我们使用访问者模式，将对象与操作解耦，将这些业务操作抽离出来，定义在独立细分的访问者类（Extractor、Compressor）中。

## 为什么支持双分派的语言不需要访问者模式？
实际上，讲到访问者模式，大部分书籍或者资料都会讲到 `Double Dispatch`，中文翻译为双分派。既然有 Double Dispatch，对应的就有 `Single Dispatch`：
- Single Dispatch：执行哪个对象的方法，根据对象的运行时类型来决定；**执行对象的哪个方法，根据方法参数的编译时类型来决定**；
- Double Dispatch：执行哪个对象的方法，根据对象的运行时类型来决定；**执行对象的哪个方法，根据方法参数的运行时类型来决定**；

在面向对象编程语言中，我们可以把方法调用理解为一种消息传递，也就是“Dispatch”。**一个对象调用另一个对象的方法，就相当于给它发送一条消息。这条消息起码要包含对象名、方法名、方法参数**。“Single”、“Double”指的是执行哪个对象的哪个方法，跟几个因素的运行时类型有关。我们进一步解释一下，Single Dispatch 之所以称为“Single”，是因为执行哪个对象的哪个方法，**只跟“对象”的运行时类型有关**。Double Dispatch 之所以称为“Double”，是因为执行哪个对象的哪个方法，**跟“对象”和“方法参数”两者的运行时类型有关**。

具体到编程语言的语法机制，Single Dispatch 和 Double Dispatch 跟多态和函数重载直接相关。**当前主流的面向对象编程语言（比如，Java、C++、C#）都只支持 Single Dispatch，不支持 Double Dispatch**。我举个例子来具体说明一下，代码如下所示：
```java
public class ParentClass 
{
    public void f() 
    {
        System.out.println("I am ParentClass's f().");
    }
}

public class ChildClass extends ParentClass 
{
    public void f() 
    {
        System.out.println("I am ChildClass's f().");
    }
}

public class SingleDispatchClass 
{
    public void polymorphismFunction(ParentClass p) 
    {
        p.f();
    }

    public void overloadFunction(ParentClass p) 
    {
        System.out.println("I am overloadFunction(ParentClass p).");
    }

    public void overloadFunction(ChildClass c) 
    {
        System.out.println("I am overloadFunction(ChildClass c).");
    }
}

public class DemoMain 
{
    public static void main(String[] args) 
    {
        SingleDispatchClass demo = new SingleDispatchClass();
        ParentClass p = new ChildClass();
        demo.polymorphismFunction(p); // 执行哪个对象的方法，由对象的实际类型决定
        demo.overloadFunction(p); // 执行对象的哪个方法，由参数对象的声明类型决定
    }
}

// 代码执行结果:
"I am ChildClass's f()."
"I am overloadFunction(ParentClass p)."
```

在上面的代码中，第 41 行代码的 polymorphismFunction() 函数，**执行 p 的实际类型的 f() 函数**，也就是 ChildClass 的 f() 函数。第 42 行代码的 overloadFunction() 函数，匹配的是重载函数中的 overloadFunction(ParentClass p)，也就是**根据 p 的声明类型来决定匹配哪个重载函数**。

## 除了访问者模式，还有其他实现方案吗？
实际上，开发这个工具有很多种代码设计和实现思路。为了讲解访问者模式，上节课我们选择了用访问者模式来实现。实际上，我们还有其他的实现方法，比如，我们还可以**利用工厂模式来实现，定义一个包含 extract2txt() 接口函数的 Extractor 接口**。PDFExtractor、PPTExtractor、WORDExtractor 类实现 Extractor 接口，并且在各自的 extract2txt() 函数中，分别实现 PDF、PPT、WORD 格式文件的文本内容抽取。**ExtractorFactory 工厂类根据不同的文件类型，返回不同的 Extractor**：
```java
public abstract class ResourceFile 
{
    protected String filePath;
    public ResourceFile(String filePath) 
    {
        this.filePath = filePath;
    }
    public abstract ResourceFileType getType();
}

public class PDFFile extends ResourceFile 
{
    public PDFFile(String filePath) 
    {
        super(filePath);
    }

    @Override
    public ResourceFileType getType() 
    {
        return ResourceFileType.PDF;
    }

    //...
}

//...PPTFile/WORDFile 跟 PDFFile 代码结构类似，此处省略...

public interface Extractor 
{
    void extract2txt(ResourceFile resourceFile);
}

public class PDFExtractor implements Extractor 
{
    @Override
    public void extract2txt(ResourceFile resourceFile) 
    {
        //...
    }
}

//...PPTExtractor/WORDExtractor 跟 PDFExtractor 代码结构类似，此处省略...

public class ExtractorFactory 
{
    private static final Map<ResourceFileType, Extractor> extractors = new HashMap<>();
    static 
    {
        extractors.put(ResourceFileType.PDF, new PDFExtractor());
        extractors.put(ResourceFileType.PPT, new PPTExtractor());
        extractors.put(ResourceFileType.WORD, new WORDExtractor());
    }

    public static Extractor getExtractor(ResourceFileType type) 
    {
        return extractors.get(type);
    }
}

public class ToolApplication 
{
    public static void main(String[] args) 
    {
        List<ResourceFile> resourceFiles = listAllResourceFiles(args[0]);
        for (ResourceFile resourceFile : resourceFiles) 
        {
            Extractor extractor = ExtractorFactory.getExtractor(resourceFile.getType());
            extractor.extract2txt(resourceFile);
        }
    }

    private static List<ResourceFile> listAllResourceFiles(String resourceDirectory) 
    {
        List<ResourceFile> resourceFiles = new ArrayList<>();
        //...根据后缀（pdf/ppt/word）由工厂方法创建不同的类对象（PDFFile/PPTFile/WORDFile）
        resourceFiles.add(new PDFFile("a.pdf"));
        resourceFiles.add(new WORDFile("b.word"));
        resourceFiles.add(new PPTFile("c.ppt"));
        return resourceFiles;
    }
}
```

当需要添加新的功能的时候，比如压缩资源文件，类似抽取文本内容功能的代码实现，我们**只需要添加一个 Compressor 接口，PDFCompressor、PPTCompressor、WORDCompressor 三个实现类，以及创建它们的 CompressorFactory 工厂类即可**。唯一需要修改的只有最上层的 ToolApplication 类。基本上符合“对扩展开放、对修改关闭”的设计原则。

对于资源文件处理工具这个例子，**如果工具提供的功能并不是非常多，只有几个而已，那我更推荐使用工厂模式的实现方式**，毕竟代码更加清晰、易懂。相反，如果工具提供非常多的功能，比如有十几个，那我更推荐使用访问者模式，因为**访问者模式需要定义的类要比工厂模式的实现方式少很多，类太多也会影响到代码的可维护性**。
