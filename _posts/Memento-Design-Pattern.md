---
title: Memento Design Pattern
date: 2020-12-24 14:25:27
tags:
  - GoF
---
## 备忘录模式的原理与实现
`备忘录模式`，也叫快照（Snapshot）模式，英文翻译是 Memento Design Pattern。它是这么定义的：
> Captures and externalizes an object’s internal state so that it can be restored later, all without violating encapsulation.

翻译成中文就是：**在不违背封装原则的前提下，捕获一个对象的内部状态，并在该对象之外保存这个状态，以便之后恢复对象为先前的状态**。在我看来，这个模式的定义主要表达了两部分内容：一部分是，存储副本以便后期恢复；另一部分是，要在不违背封装原则的前提下，进行对象的备份和恢复。接下来，我就结合一个例子来解释一下，带你搞清楚这两个问题：
- 为什么存储和恢复副本会违背封装原则？
- 备忘录模式是如何做到不违背封装原则的？

假设有这样一道面试题，希望你编写一个小程序，可以接收命令行的输入。用户输入文本时，程序将其追加存储在内存文本中；用户输入“:list”，程序在命令行中输出内存文本的内容；用户输入“:undo”，程序会撤销上一次输入的文本，也就是从内存文本中将上次输入的文本删除掉。如下所示：
```bash
>hello
>:list
hello
>world
>:list
helloworld
>:undo
>:list
hello
```

整体上来讲，这个小程序实现起来并不复杂：
<!--more-->
```java
public class InputText 
{
    private StringBuilder text = new StringBuilder();

    public String getText() 
    {
        return text.toString();
    }

    public void append(String input) 
    {
        text.append(input);
    }

    public void setText(String text) 
    {
        this.text.replace(0, this.text.length(), text);
    }
}

public class SnapshotHolder 
{
    private Stack<InputText> snapshots = new Stack<>();

    public InputText popSnapshot() 
    {
        return snapshots.pop();
    }

    public void pushSnapshot(InputText inputText) 
    {
        InputText deepClonedInputText = new InputText();
        deepClonedInputText.setText(inputText.getText());
        snapshots.push(deepClonedInputText);
    }
}

public class ApplicationMain 
{
    public static void main(String[] args) 
    {
        InputText inputText = new InputText();
        SnapshotHolder snapshotsHolder = new SnapshotHolder();
        Scanner scanner = new Scanner(System.in);
        while (scanner.hasNext()) 
        {
            String input = scanner.next();
            if (input.equals(":list")) 
            {
                System.out.println(inputText.getText());
            } 
            else if (input.equals(":undo")) 
            {
                InputText snapshot = snapshotsHolder.popSnapshot();
                inputText.setText(snapshot.getText());
            } 
            else 
            {
                snapshotsHolder.pushSnapshot(inputText);
                inputText.append(input);
            }
        }
    }
}
```

实际上，备忘录模式的实现很灵活，也没有很固定的实现方式，在不同的业务需求、不同编程语言下，代码实现可能都不大一样。但是，如果我们深究一下的话，还有一些问题要解决，那就是前面定义中提到的第二点：**要在不违背封装原则的前提下，进行对象的备份和恢复**。而上面的代码并不满足这一点，主要体现在下面两方面：
1. 为了能用快照恢复 InputText 对象，我们在 InputText 类中定义了 setText() 函数，但这个函数有可能会被其他业务使用，所以，**暴露不应该暴露的函数违背了封装原则**；
2. 快照本身是不可变的，理论上讲，不应该包含任何 set() 等修改内部状态的函数，但在上面的代码实现中，“快照“这个业务模型复用了 InputText 类的定义，而 InputText 类本身有一系列修改内部状态的函数，所以，**用 InputText 类来表示快照违背了封装原则**；

针对以上问题，我们对代码做两点修改。其一，**定义一个独立的类（Snapshot 类）来表示快照，而不是复用 InputText 类**。这个类只暴露 get() 方法，没有 set() 等任何修改内部状态的方法。其二，在 InputText 类中，我们**把 setText() 方法重命名为 restoreSnapshot() 方法，用意更加明确**，只用来恢复对象：
```java
public class InputText 
{
    private StringBuilder text = new StringBuilder();

    public String getText() 
    {
        return text.toString();
    }

    public void append(String input) 
    {
        text.append(input);
    }

    public Snapshot createSnapshot() 
    {
        return new Snapshot(text.toString());
    }

    public void restoreSnapshot(Snapshot snapshot) 
    {
        this.text.replace(0, this.text.length(), snapshot.getText());
    }
}

public class Snapshot 
{
    private String text;

    public Snapshot(String text) 
    {
        this.text = text;
    }

    public String getText() 
    {
        return this.text;
    }
}

public class SnapshotHolder 
{
    private Stack<Snapshot> snapshots = new Stack<>();

    public Snapshot popSnapshot() 
    {
        return snapshots.pop();
    }

    public void pushSnapshot(Snapshot snapshot) 
    {
        snapshots.push(snapshot);
    }
}

public class ApplicationMain 
{
    public static void main(String[] args) 
    {
        InputText inputText = new InputText();
        SnapshotHolder snapshotsHolder = new SnapshotHolder();
        Scanner scanner = new Scanner(System.in);
        while (scanner.hasNext()) 
        {
            String input = scanner.next();
            if (input.equals(":list")) 
            {
                System.out.println(inputText.toString());
            } 
            else if (input.equals(":undo")) 
            {
                Snapshot snapshot = snapshotsHolder.popSnapshot();
                inputText.restoreSnapshot(snapshot);
            } 
            else 
            {
                snapshotsHolder.pushSnapshot(inputText.createSnapshot());
                inputText.append(input);
            }
        }
    }
}
```

除了备忘录模式，还有一个跟它很类似的概念：`备份`，它在我们平时的开发中更常听到。实际上，这两者的应用场景很类似，都应用在防丢失、恢复、撤销等场景中。它们的区别在于，**备忘录模式更侧重于代码的设计和实现，备份更侧重架构设计或产品设计**。

## 如何优化内存和时间消耗？
前面我们只是简单介绍了备忘录模式的原理和经典实现，现在我们再继续深挖一下。如果要备份的对象数据比较大，备份频率又比较高，那快照占用的内存会比较大，备份和恢复的耗时会比较长。这个问题该如何解决呢？

不同的应用场景下有不同的解决方法。比如，我们前面举的那个例子，应用场景是利用备忘录来实现撤销操作，而且仅支持顺序撤销，也就是说，**每次操作只能撤销上一次的输入，不能跳过上次输入撤销之前的输入**。在具有这样特点的应用场景下，为了节省内存，我们不需要在快照中存储完整的文本，只需要记录少许信息，比如在获取快照当下的文本长度，用这个值结合 InputText 类对象存储的文本来做撤销操作。

假设每当有数据改动，我们都需要生成一个备份，以备之后恢复。如果需要备份的数据很大，这样高频率的备份，不管是对存储（内存或者硬盘）的消耗，还是对时间的消耗，都可能是无法接受的。想要解决这个问题，我们一般会**采用低频率全量备份和高频率增量备份相结合的方法**。当我们需要恢复到某一时间点的备份的时候，如果这一时间点有做全量备份，我们直接拿来恢复就可以了。如果这一时间点没有对应的全量备份，我们就先找到最近的一次全量备份，然后用它来恢复，之后执行此次全量备份跟这一时间点之间的所有增量备份，也就是对应的操作或者数据变动。这样就能**减少全量备份的数量和频率，减少对时间、内存的消耗**。
