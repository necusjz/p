---
title: KISS vs. YAGNI
date: 2020-11-03 22:05:30
tags:
  - GoF
---
## 如何理解 KISS 原则
KISS 原则的英文描述：
> Keep It Simple and Stupid.

翻译成中文就是：**尽量保持简单**。KISS 原则算是一个万金油类型的设计原则，可以应用在很多场景中。它不仅经常用来指导软件开发，还经常用来指导更加广泛的系统设计、产品设计等，比如，冰箱、建筑、iPhone 手机的设计等等。

代码的`可读性`和`可维护性`是衡量代码质量非常重要的两个标准。而 KISS 原则就是保持代码可读和可维护的重要手段。**代码足够简单，也就意味着很容易读懂，bug 比较难隐藏**。即便出现 bug，修复起来也比较简单。

## 代码行数越少就越“简单”吗？
下面这三段代码可以实现同样一个功能：检查输入的字符串 ipAddress 是否是合法的 IP 地址。
<!--more-->
```java
// 第一种实现方式: 使用正则表达式
public boolean isValidIpAddressV1(String ipAddress) 
{
    if (StringUtils.isBlank(ipAddress)) 
    {
        return false;
    }
    String regex = "^(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|[1-9])\\." 
        + "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."
        + "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)\\."
        + "(1\\d{2}|2[0-4]\\d|25[0-5]|[1-9]\\d|\\d)$";
    return ipAddress.matches(regex);
}

// 第二种实现方式: 使用现成的工具类
public boolean isValidIpAddressV2(String ipAddress) 
{
    if (StringUtils.isBlank(ipAddress)) 
    {
        return false;
    }
    String[] ipUnits = StringUtils.split(ipAddress, '.');
    if (ipUnits.length != 4) 
    {
        return false;
    }
    for (int i = 0; i < 4; ++i) 
    {
        int ipUnitIntValue;
        try 
        {
            ipUnitIntValue = Integer.parseInt(ipUnits[i]);
        } 
        catch (NumberFormatException e) 
        {
            return false;
        }
        if (ipUnitIntValue < 0 || ipUnitIntValue > 255) 
        {
            return false;
        }
        if (i == 0 && ipUnitIntValue == 0) 
        {
            return false;
        }
    }
    return true;
}

// 第三种实现方式: 不使用任何工具类
public boolean isValidIpAddressV3(String ipAddress) 
{
    char[] ipChars = ipAddress.toCharArray();
    int length = ipChars.length;
    int ipUnitIntValue = -1;
    boolean isFirstUnit = true;
    int unitsCount = 0;
    for (int i = 0; i < length; ++i) 
    {
        char c = ipChars[i];
        if (c == '.') 
        {
            if (ipUnitIntValue < 0 || ipUnitIntValue > 255) 
            {
                return false;
            }
            if (isFirstUnit && ipUnitIntValue == 0) 
            {
                return false;
            }
            if (isFirstUnit) 
            {
                isFirstUnit = false;
            }
            ipUnitIntValue = -1;
            unitsCount++;
            continue;
        }
        if (c < '0' || c > '9') 
        {
            return false;
        }
        if (ipUnitIntValue == -1) 
        {
            ipUnitIntValue = 0;
        }
        ipUnitIntValue = ipUnitIntValue * 10 + (c - '0');
    }
    if (ipUnitIntValue < 0 || ipUnitIntValue > 255) 
    {
        return false;
    }
    if (unitsCount != 3) 
    {
        return false;
    }
    return true;
}
```

第一种实现方式利用的是正则表达式，只用四行代码就把这个问题搞定了。它的代码行数最少，那是不是就最符合 KISS 原则呢？答案是否定的。虽然代码行数最少，**看似最简单，实际上却很复杂**。这正是因为它使用了正则表达式。

第二种实现方式使用了 StringUtils 类、Integer 类提供的一些现成的工具函数，来处理 IP 地址字符串。第三种实现方式，不使用任何工具函数，而是通过逐一处理 IP 地址中的字符，来判断是否合法。从代码行数上来说，这两种方式差不多。但是，**第三种要比第二种更加有难度，更容易写出 bug**。从可读性上来说，**第二种实现方式的代码逻辑更清晰、更好理解**。所以，在这两种实现方式中，第二种实现方式更加“简单”，更加符合 KISS 原则。

一般来说，工具类的功能都比较通用和全面，所以，在代码实现上，需要**考虑和处理更多的细节，执行效率就会有所影响**。而第三种实现方式，完全是自己操作底层字符，只针对 IP 地址这一种格式的数据输入来做处理，没有太多多余的函数调用和其他不必要的处理逻辑，所以，在执行效率上，这种类似**定制化的处理代码方式肯定比通用的工具类要高些**。

不过，尽管第三种实现方式性能更高些，但我还是更倾向于选择第二种实现方法。那是因为第三种实现方式**实际上是一种过度优化**。**除非 isValidIpAddress() 函数是影响系统性能的瓶颈代码**，否则，这样优化的投入产出比并不高，增加了代码实现的难度、牺牲了代码的可读性，性能上的提升却并不明显。

## 代码逻辑复杂就违背 KISS 原则吗？
在回答这个问题之前，我们先来看下面这段代码：
```java
// KMP algorithm: a, b 分别是主串和模式串；n, m 分别是主串和模式串的长度
public static int kmp(char[] a, int n, char[] b, int m) 
{
    int[] next = getNext(b, m);
    int j = 0;
    for (int i = 0; i < n; ++i) 
    {
        while (j > 0 && a[i] != b[j]) 
        { 
            // 一直找到 a[i] 和 b[j]
            j = next[j - 1] + 1;
        }
        if (a[i] == b[j]) 
        {
            ++j;
        }
        if (j == m) 
        { 
            // 找到匹配模式串的了
            return i - m + 1;
        }
    }
    return -1;
}

// b 表示模式串，m 表示模式串的长度
private static int[] getNext(char[] b, int m) 
{
    int[] next = new int[m];
    next[0] = -1;
    int k = -1;
    for (int i = 1; i < m; ++i) 
    {
        while (k != -1 && b[k + 1] != b[i]) 
        {
            k = next[k];
        }
        if (b[k + 1] == b[i]) 
        {
            ++k;
        }
        next[i] = k;
    }
    return next;
}
```

KMP 算法以快速高效著称。当我们需要处理长文本字符串匹配问题（几百 MB 大小文本内容的匹配），或者**字符串匹配是某个产品的核心功能**（比如 Vim、Word 等文本编辑器），又或者字符串匹配算法是系统性能瓶颈的时候，我们就应该选择尽可能高效的 KMP 算法。而 KMP 算法本身具有逻辑复杂、实现难度大、可读性差的特点。**本身就复杂的问题，用复杂的方法解决，并不违背 KISS 原则**。

不过，平时的项目开发中涉及的字符串匹配问题，大部分都是针对比较小的文本。在这种情况下，直接调用编程语言提供的现成的字符串匹配函数就足够了。如果非得用 KMP 算法、BM 算法来实现字符串匹配，那就真的违背 KISS 原则了。也就是说，**同样的代码，在某个业务场景下满足 KISS 原则，换一个应用场景可能就不满足了**。

## 如何写出满足 KISS 原则的代码？
实际上，我们前面已经讲到了一些方法。这里我稍微总结一下：
- **不要使用同事可能不懂的技术来实现代码**。比如前面例子中的正则表达式，还有一些编程语言中过于高级的语法等；
- **不要重复造轮子**，要善于使用已经有的工具类库。经验证明，自己去实现这些类库，出 bug 的概率会更高，维护的成本也比较高；
- **不要过度优化**。不要过度使用一些奇技淫巧（比如，位运算代替算术运算、复杂的条件语句代替 if-else、使用一些过于底层的函数等）来优化代码，牺牲代码的可读性；

这里我还想多说两句，我们在做开发的时候，一定不要过度设计，不要觉得简单的东西就没有技术含量。实际上，**越是能用简单的方法解决复杂的问题，越能体现一个人的能力**。

## YAGNI 跟 KISS 说的是一回事吗？
YAGNI 原则的英文全称是：
> You Ain’t Gonna Need It.

直译就是：你不会需要它。这条原则也算是万金油了。当用在软件开发中的时候，它的意思是：不要去设计当前用不到的功能；不要去编写当前用不到的代码。实际上，这条原则的核心思想就是：**不要做过度设计**。

比如，我们的系统暂时只用 Redis 存储配置信息，以后可能会用到 ZooKeeper。根据 YAGNI 原则，在未用到 ZooKeeper 之前，我们没必要提前编写这部分代码。当然，这并不是说我们就不需要考虑代码的扩展性。我们**还是要预留好扩展点**，等到需要的时候，再去实现 ZooKeeper 存储配置信息这部分代码。

从刚刚的分析我们可以看出，YAGNI 原则跟 KISS 原则并非一回事儿。**KISS 原则讲的是“如何做”的问题**（尽量保持简单），而 **YAGNI 原则说的是“要不要做”的问题**（当前不需要的就不要做）。
