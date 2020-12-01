---
title: 面向对象 vs. 面向过程
date: 2020-08-23 18:29:36
tags:
  - GoF
---
那是因为在过往的工作中，我发现很多人搞不清楚面向对象和面向过程的区别，总以为使用面向对象编程语言来做开发，就是在进行面向对象编程了。而实际上，他们只是在用面向对象编程语言，编写面向过程风格的代码而已，并没有发挥面向对象编程的优势。这就相当于手握一把屠龙刀，却只是把它当作一把普通的刀剑来用，相当可惜。

## 面向过程编程与面向过程编程语言
- 面向过程编程也是一种编程范式或编程风格。它**以过程（可以理解为方法、函数、操作）作为组织代码的基本单元，以数据（可以理解为成员变量、属性）与方法相分离为最主要的特点**。面向过程风格是一种流程化的编程风格，通过拼接一组顺序执行的方法来操作数据完成一项功能；
- 面向过程编程语言首先是一种编程语言。它最大的特点是**不支持类和对象两个语法概念**，不支持丰富的面向对象编程特性（比如继承、多态、封装），仅支持面向过程编程；

定义不是很严格，也比较抽象，所以，我再用一个例子进一步解释一下。假设我们有一个记录了用户信息的文本文件 users.txt，每行文本的格式是 name&age&gender（比如，小王 &28& 男）。我们希望写一个程序，从 users.txt 文件中逐行读取用户信息，然后格式化成 name\tage\tgender（其中，\t 是分隔符）这种文本格式，并且按照 age 从小到大排序之后，重新写入到另一个文本文件 formatted_users.txt 中。

首先，我们先来看，用面向过程这种编程风格写出来的代码是什么样子的。注意，下面的代码是用 C 语言这种面向过程的编程语言来编写的：
<!--more-->
```cpp
struct User 
{
    char name[64];
    int age;
    char gender[16];
};

struct User parse_to_user(char* text) 
{
    // 将 text(“小王&28&男”) 解析成结构体 struct User
}

char* format_to_text(struct User user) 
{
    // 将结构体 struct User 格式化成文本 ("小王\t28\t男"）
}

void sort_users_by_age(struct User users[]) 
{
    // 按照年龄从小到大排序 users
}

void format_user_file(char* origin_file_path, char* new_file_path) 
{
    // open files...
    struct User users[1024]; // 假设最大 1024 个用户
    int count = 0;
    while(1) 
    {   // read until the file is empty
        struct User user = parse_to_user(line);
        users[count++] = user;
    }
    
    sort_users_by_age(users);
    
    for (int i = 0; i < count; ++i) 
    {
        char* formatted_user_text = format_to_text(users[i]);
        // write to new file...
    }
    // close files...
}

int main(char** args, int argv) 
{
  format_user_file("/home/zheng/user.txt", "/home/zheng/formatted_users.txt");
}
```

然后，我们再来看，用面向对象这种编程风格写出来的代码是什么样子的。注意，下面的代码是用 Java 这种面向对象的编程语言来编写的：
```java
 public class User 
 {
    private String name;
    private int age;
    private String gender;
    
    public User(String name, int age, String gender) 
    {
        this.name = name;
        this.age = age;
        this.gender = gender;
    }
    
    public static User praseFrom(String userInfoText) 
    {
        // 将text(“小王&28&男”)解析成类User
    }
    
    public String formatToText() 
    {
        // 将类User格式化成文本（"小王\t28\t男"）
    }
}

public class UserFileFormatter 
{
    public void format(String userFile, String formattedUserFile) 
    {
        // Open files...
        List users = new ArrayList<>();
        while (1) 
        { 
            // read until file is empty 
            // read from file into userText...
            User user = User.parseFrom(userText);
            users.add(user);
        }
        // sort users by age...
        for (int i = 0; i < users.size(); ++i) 
        {
            String formattedUserText = user.formatToText();
            // write to new file...
        }
        // close files...
    }
}

public class MainApplication 
{
    public static void main(String[] args) 
    {
        UserFileFormatter userFileFormatter = new UserFileFormatter();
        userFileFormatter.format("/home/zheng/users.txt", "/home/zheng/formatted_users.txt");
    }
}
```

从上面的代码中，我们可以看出，面向过程和面向对象最基本的区别就是，**代码的组织方式不同**。面向过程风格的代码被组织成了一组方法集合及其数据结构（struct User），方法和数据结构的定义是分开的。面向对象风格的代码被组织成一组类，方法和数据结构被绑定一起，定义在类中。

## 面向对象的优势
接下来，我们再来看一下，为什么面向对象编程晚于面向过程编程出现，却能取而代之，成为现在主流的编程范式？

### OOP 更加能够应对大规模复杂程序的开发
但对于大规模复杂程序的开发来说，整个程序的处理流程错综复杂，并非只有一条主线。如果把整个程序的处理流程画出来的话，会是一个网状结构。如果我们再用面向过程编程这种流程化、线性的思维方式，去翻译这个网状结构，去思考如何把程序拆解为一组顺序执行的方法，就会比较吃力。这个时候，面向对象的编程风格的优势就比较明显了。

**面向对象编程是以类为思考对象**。在进行面向对象编程的时候，我们并不是一上来就去思考，如何将复杂的流程拆解为一个一个方法，而是采用曲线救国的策略，先去思考如何给业务建模，如何将需求翻译为类，如何给类之间建立交互关系，而完成这些工作完全不需要考虑错综复杂的处理流程。当我们有了类的设计之后，然后再像搭积木一样，按照处理流程，将类组装起来形成整个程序。这种开发模式、思考问题的方式，能让我们在应对复杂程序开发的时候，思路更加清晰。

你可能会说，像 C 语言这种面向过程的编程语言，我们也可以按照功能的不同，把函数和数据结构放到不同的文件里，以达到给函数和数据结构分类的目的，照样可以实现代码的模块化。你说得没错。只不过**面向对象编程本身提供了类的概念，强制你做这件事情，而面向过程编程并不强求**。这也算是面向对象编程相对于面向过程编程的一个微创新吧。

### OOP 风格的代码更易复用、易扩展、易维护
我们来看下继承特性。**继承特性是面向对象编程相比于面向过程编程所特有的两个特性之一（另一个是多态）**。如果两个类有一些相同的属性和方法，我们就可以将这些相同的代码，抽取到父类中，让两个子类继承父类。这样两个子类也就可以重用父类中的代码，**避免了代码重复写多遍，提高了代码的复用性**。

我们来看下多态特性。基于这个特性，我们在需要修改一个功能实现的时候，可以通过实现一个新的子类的方式，在子类中重写原来的功能逻辑，用子类替换父类。在实际的代码运行过程中，调用子类新的功能逻辑，而不是在原有代码上做修改。这就**遵从了“对修改关闭、对扩展开放”的设计原则，提高代码的扩展性**。除此之外，利用多态特性，不同的类对象可以传递给相同的方法，执行不同的代码逻辑，提高了代码的复用性。

### OOP 语言更加人性化、更加高级、更加智能
跟二进制指令、汇编语言、面向过程编程语言相比，面向对象编程语言的编程套路、思考问题的方式，是完全不一样的。前三者是一种计算机思维方式，而面向对象是一种人类的思维方式。我们在用前面三种语言编程的时候，我们是在思考，如何设计一组指令，告诉机器去执行这组指令，操作某些数据，帮我们完成某个任务。而在进行面向对象编程时候，我们是在思考，如何给业务建模，如何将真实的世界映射为类或者对象，这让我们更加能聚焦到业务本身，而不是思考如何跟机器打交道。可以这么说，**越高级的编程语言离机器越“远”，离我们人类越“近”，越“智能”**。
