---
title: DRY 原则
date: 2020-11-03 23:29:22
tags:
  - GoF
---
DRY 原则的英文描述为：
> Don’t Repeat Yourself.

中文直译为：不要重复自己。今天，我们主要讲**三种典型的代码重复情况**，它们分别是：实现逻辑重复、功能语义重复和代码执行重复。这三种代码重复，有的看似违反 DRY，实际上并不违反；有的看似不违反，实际上却违反了。

## 实现逻辑重复
我们先来看下面这样一段代码是否违反了 DRY 原则：
<!--more-->
```java
public class UserAuthenticator 
{
    public void authenticate(String username, String password) 
    {
        if (!isValidUsername(username)) 
        {
            //...throw InvalidUsernameException...
        }
        if (!isValidPassword(password)) 
        {
            //...throw InvalidPasswordException...
        }
        //...省略其他代码...
    }

    private boolean isValidUsername(String username) 
    {
        // check not null, not empty
        if (StringUtils.isBlank(username)) 
        {
            return false;
        }
        // check length: 4~64
        int length = username.length();
        if (length < 4 || length > 64) 
        {
            return false;
        }
        // contains only lowercase characters
        if (!StringUtils.isAllLowerCase(username)) 
        {
            return false;
        }
        // contains only a~z, 0~9, dot
        for (int i = 0; i < length; ++i) 
        {
            char c = username.charAt(i);
            if (!(c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '.') 
            {
                return false;
            }
        }
        return true;
    }

    private boolean isValidPassword(String password) 
    {
        // check not null, not empty
        if (StringUtils.isBlank(password)) 
        {
            return false;
        }
        // check length: 4~64
        int length = password.length();
        if (length < 4 || length > 64) 
        {
            return false;
        }
        // contains only lowercase characters
        if (!StringUtils.isAllLowerCase(password)) 
        {
            return false;
        }
        // contains only a~z, 0~9, dot
        for (int i = 0; i < length; ++i) 
        {
            char c = password.charAt(i);
            if (!(c >= 'a' && c <= 'z') || (c >= '0' && c <= '9') || c == '.') 
            {
                return false;
            }
        }
        return true;
    }
}
```

在代码中，有两处非常明显的重复的代码片段：isValidUserName() 函数和 isValidPassword() 函数。**重复的代码被敲了两遍，或者简单 copy-paste 了一下，看起来明显违反 DRY 原则**。为了移除重复的代码，我们对上面的代码做下重构，将 isValidUserName() 函数和 isValidPassword() 函数，合并为一个更通用的函数 isValidUserNameOrPassword()。重构后的代码如下所示：
```java
public class UserAuthenticatorV2 
{
    public void authenticate(String userName, String password) 
    {
        if (!isValidUsernameOrPassword(userName)) 
        {
            //...throw InvalidUsernameException...
        }

        if (!isValidUsernameOrPassword(password)) 
        {
            //...throw InvalidPasswordException...
        }
    }

    private boolean isValidUsernameOrPassword(String usernameOrPassword) 
    {
        //省略实现逻辑
        //跟原来的 isValidUsername() 或 isValidPassword() 的实现逻辑一样...
        return true;
    }
}
```

单从名字上看，我们就能发现，合并之后的 isValidUserNameOrPassword() 函数，负责两件事情：验证用户名和验证密码，违反了`单一职责原则`和`接口隔离原则`。

因为 isValidUserName() 和 isValidPassword() 两个函数，虽然**从代码实现逻辑上看起来是重复的，但是从语义上并不重复**。所谓“语义不重复”指的是：从功能上来看，这两个函数干的是完全不重复的两件事情，一个是校验用户名，另一个是校验密码。尽管在目前的设计中，两个校验逻辑是完全一样的，但如果按照第二种写法，**将两个函数的合并，那就会存在潜在的问题**。在未来的某一天，如果我们修改了密码的校验逻辑，比如，允许密码包含大写字符，允许密码的长度为 8 到 64 个字符，那这个时候，isValidUserName() 和 isValidPassword() 的实现逻辑就会不相同。我们就要把合并后的函数，重新拆成合并前的那两个函数。

**尽管代码的实现逻辑是相同的，但语义不同，我们判定它并不违反 DRY 原则**。对于包含重复代码的问题，我们可以**通过抽象成更细粒度函数的方式来解决**。比如将校验只包含 a~z、0~9、dot 的逻辑封装成 boolean onlyContains(String str, String list) 函数。

## 功能语义重复
现在我们再来看另外一个例子。在同一个项目代码中有下面两个函数：isValidIp() 和 checkIfIpValid()。尽管两个函数的命名不同，实现逻辑不同，但功能是相同的，都是用来判定 IP 地址是否合法的：
```java
public boolean isValidIp(String ipAddress) 
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

public boolean checkIfIpValid(String ipAddress) 
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
```

在这个例子中，尽管两段代码的实现逻辑不重复，但**语义重复，也就是功能重复，我们认为它违反了 DRY 原则**。我们应该在项目中，统一一种实现思路，所有用到判断 IP 地址是否合法的地方，都统一调用同一个函数。

假设我们不统一实现思路，那有些地方调用了 isValidIp() 函数，有些地方又调用了 checkIfIpValid() 函数，这就会导致代码看起来很奇怪，相当于给代码**埋坑**。

## 代码执行重复
我们再来看第三个例子。其中，UserService 中 login() 函数用来校验用户登录是否成功。如果失败，就返回异常；如果成功，就返回用户信息。具体代码如下所示：
```java
public class UserService 
{
    private UserRepo userRepo; // 通过依赖注入或者IOC框架注入

    public User login(String email, String password) 
    {
        boolean existed = userRepo.checkIfUserExisted(email, password);
        if (!existed) 
        {
            //...throw AuthenticationFailureException...
        }
        User user = userRepo.getUserByEmail(email);
        return user;
  }
}

public class UserRepo 
{
    public boolean checkIfUserExisted(String email, String password) 
    {
        if (!EmailValidation.validate(email)) 
        {
            //...throw InvalidEmailException...
        }

        if (!PasswordValidation.validate(password)) 
        {
            //...throw InvalidPasswordException...
        }

        //...query db to check if email&password exists...
    }

    public User getUserByEmail(String email) 
    {
        if (!EmailValidation.validate(email)) 
        {
            //...throw InvalidEmailException...
        }
        //...query db to get user by email...
    }
}
```

上面这段代码，既没有逻辑重复，也没有语义重复，但仍然违反了 DRY 原则。这是因为**代码中存在执行重复**。

重复执行最明显的一个地方，就是**在 login() 函数中，email 的校验逻辑被执行了两次**。一次是在调用 checkIfUserExisted() 函数的时候，另一次是调用 getUserByEmail() 函数的时候。这个问题解决起来比较简单，我们只需要将校验逻辑从 UserRepo 中移除，统一放到 UserService 中就可以了。

实际上，**login() 函数并不需要调用 checkIfUserExisted() 函数**，只需要调用一次 getUserByEmail() 函数，从数据库中获取到用户的 email、password 等信息，然后跟用户输入的 email、password 信息做对比，依次判断是否登录成功。

这样的优化是很有必要的。因为 checkIfUserExisted() 函数和 getUserByEmail() 函数都需要查询数据库，而数据库这类的 I/O 操作是比较耗时的。**我们在写代码的时候，应当尽量减少这类 I/O 操作**。

按照刚刚的修改思路，**我们把代码重构一下，移除重复执行的代码**，只校验一次 email 和 password，并且只查询一次数据库。重构之后的代码如下所示：
```java
public class UserService 
{
    private UserRepo userRepo; // 通过依赖注入或者IOC框架注入

    public User login(String email, String password) 
    {
        if (!EmailValidation.validate(email)) 
        {
            //...throw InvalidEmailException...
        }
        if (!PasswordValidation.validate(password)) 
        {
            //...throw InvalidPasswordException...
        }
        User user = userRepo.getUserByEmail(email);
        if (user == null || !password.equals(user.getPassword()) 
        {
            //...throw AuthenticationFailureException...
        }
        return user;
    }
}

public class UserRepo 
{
    public User getUserByEmail(String email) 
    {
        //...query db to get user by email...
    }
}
```

## 代码复用性（Code Reusability）
代码的复用性是评判代码质量的一个非常重要的标准。

### 什么是代码的复用性
我们首先来区分三个概念：`代码复用性`（Code Reusability）、`代码复用`（Code Reuse）和 `DRY 原则`：
- 代码复用表示一种**行为**：我们在开发新功能的时候，尽量复用已经存在的代码；
- 代码的可复用性表示一段代码可被复用的**特性或能力**：我们在编写代码的时候，让代码尽量可复用；
- DRY 原则是一条原则：不要写重复的代码；

#### “不重复”并不代表“可复用”
在一个项目代码中，可能不存在任何重复的代码，但也并不表示里面有可复用的代码，**不重复和可复用完全是两个概念**。所以，从这个角度来说，DRY 原则跟代码的可复用性讲的是两回事。

#### “复用”和“可复用性”关注角度不同
代码“可复用性”是从代码**开发者**的角度来讲的，“复用”是从代码**使用者**的角度来讲的。比如，A 同事编写了一个 UrlUtils 类，代码的“可复用性”很好。B 同事在开发新功能的时候，直接“复用”A 同事编写的 UrlUtils 类。

尽管复用、可复用性、DRY 原则这三者从理解上有所区别，但实际上要达到的目的都是类似的，**都是为了减少代码量，提高代码的可读性、可维护性**。除此之外，复用已经经过测试的老代码，bug 会比从零重新开发要少。

“复用”这个概念不仅可以指导细粒度的模块、类、函数的设计开发，实际上，一些**框架、类库、组件等的产生也都是为了达到复用的目的**。比如，Spring 框架、Google Guava 类库、UI 组件等等。

### 怎么提高代码复用性？
实际上，我们前面已经讲到过很多提高代码可复用性的手段，今天算是集中总结一下，我总结了 7 条，具体如下：
- **减少代码耦合**：对于高度耦合的代码，当我们希望复用其中的一个功能，想把这个功能的代码抽取出来成为一个独立的模块、类或者函数的时候，往往会发现牵一发而动全身。移动一点代码，就要牵连到很多其他相关的代码。所以，**高度耦合的代码会影响到代码的复用性**，我们要尽量减少代码耦合；
- **满足单一职责原则**：如果职责不够单一，模块、类设计得大而全，那依赖它的代码或者它依赖的代码就会比较多，进而增加了代码的耦合。根据上一点，也就会影响到代码的复用性。相反，**越细粒度的代码，代码的通用性会越好**，越容易被复用；
- **模块化**：这里的“模块”，不单单指一组类构成的模块，还可以理解为单个类、函数。我们要善于将功能独立的代码，封装成模块。**独立的模块就像一块一块的积木，更加容易复用**，可以直接拿来搭建更加复杂的系统；
- **业务与非业务逻辑分离**：越是跟业务无关的代码越是容易复用，越是针对特定业务的代码越难复用。所以，**为了复用跟业务无关的代码，我们将业务和非业务逻辑代码分离**，抽取成一些通用的框架、类库、组件等；
- **通用代码下沉**：从分层的角度来看，越底层的代码越通用、会被越多的模块调用，越应该设计得足够可复用。一般情况下，在代码分层之后，为了避免交叉调用导致调用关系混乱，我们**只允许上层代码调用下层代码及同层代码之间的调用，杜绝下层代码调用上层代码**。所以，通用的代码我们尽量下沉到更下层；
- **继承、多态、抽象、封装**：在讲面向对象特性的时候，我们讲到，利用继承，可以**将公共的代码抽取到父类**，子类复用父类的属性和方法。利用多态，我们可以**动态地替换一段代码的部分逻辑**，让这段代码可复用。除此之外，抽象和封装，从更加广义的层面、而非狭义的面向对象特性的层面来理解的话，**越抽象、越不依赖具体的实现**，越容易复用。代码封装成模块，**隐藏可变的细节、暴露不变的接口**，就越容易复用；
- **应用模板等设计模式**：一些设计模式，也能提高代码的复用性。比如，模板模式利用了多态来实现，可以灵活地替换其中的部分代码，整个流程模板代码可复用；

一些跟编程语言相关的特性，也能提高代码的复用性，比如`泛型编程`等。实际上，除了上面讲到的这些方法之外，**复用意识也非常重要**。在写代码的时候，我们要多去思考一下，这个部分代码是否可以抽取出来，作为一个独立的模块、类或者函数供多处使用。**在设计每个模块、类、函数的时候，要像设计一个外部 API 那样，去思考它的复用性**。

### 辩证思考和灵活应用
如果我们在编写代码的时候，已经有复用的需求场景，那根据复用的需求去开发可复用的代码，可能还不算难。但是，如果当下并没有复用的需求，我们只是希望现在编写的代码具有可复用的特点，能在未来某个同事开发某个新功能的时候复用得上。在这种**没有具体复用需求的情况下，我们就需要去预测将来代码会如何复用，这就比较有挑战了**。

实际上，**除非有非常明确的复用需求，否则，为了暂时用不到的复用需求**，花费太多的时间、精力，投入太多的开发成本，并不是一个值得推荐的做法。这也违反我们之前讲到的 YAGNI 原则。

> `Rule of Three`：第一次编写代码的时候，我们不考虑复用性；第二次遇到复用场景的时候，再进行重构使其复用。
