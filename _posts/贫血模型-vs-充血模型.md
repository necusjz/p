---
title: 贫血模型 vs. 充血模型
date: 2020-09-13 20:52:04
tags:
  - GoF
---
据我了解，大部分工程师都是做业务开发的，所以，今天我们讲的这个实战项目也是一个典型的业务系统开发案例。我们都知道，很多业务系统都是基于 MVC 三层架构来开发的。实际上，更确切点讲，这是一种基于`贫血模型`的 MVC 三层架构开发模式。

虽然这种开发模式已经成为标准的 Web 项目的开发模式，但它却违反了面向对象编程风格，是一种彻彻底底的面向过程的编程风格，因此而被有些人称为`反模式`（anti-pattern）。特别是`领域驱动设计`（Domain Driven Design，简称 DDD）盛行之后，这种基于贫血模型的传统的开发模式就更加被人诟病。而基于`充血模型`的 DDD 开发模式越来越被人提倡。

## 基于贫血模型的传统开发模式
MVC 三层架构中的 **M 表示 Model，V 表示 View，C 表示 Controller**。它将整个项目分为三层：展示层、逻辑层、数据层。MVC 三层开发架构是一个比较笼统的分层方式，落实到具体的开发层面，很多项目也并不会 100% 遵从 MVC 固定的分层方式，而是会根据具体的项目需求，做适当的调整。

比如，现在很多 Web 或者 App 项目都是前后端分离的，后端负责暴露接口给前端调用。这种情况下，我们一般就**将后端项目分为 Repository 层、Service 层、Controller 层**。其中，Repository 层负责数据访问，Service 层负责业务逻辑，Controller 层负责暴露接口。当然，这只是其中一种分层和命名方式。不同的项目、不同的团队，可能会对此有所调整。不过，万变不离其宗，只要是依赖数据库开发的 Web 项目，基本的分层思路都大差不差。

实际上，**你可能一直都在用贫血模型做开发，只是自己不知道而已**。不夸张地讲，据我了解，目前几乎所有的业务后端系统，都是基于贫血模型的。我举一个简单的例子来给你解释一下：
<!--more-->
```
////////// Controller+VO(View Object) //////////
public class UserController 
{
    private UserService userService; // 通过构造函数或者IOC框架注入
    
    public UserVo getUserById(Long userId) 
    {
        UserBo userBo = userService.getUserById(userId);
        UserVo userVo = [...convert userBo to userVo...];
        return userVo;
    }
}

public class UserVo 
{
    // 省略其他属性、get/set/construct方法
    private Long id;
    private String name;
    private String cellphone;
}

////////// Service+BO(Business Object) //////////
public class UserService 
{
    private UserRepository userRepository; // 通过构造函数或者IOC框架注入
    
    public UserBo getUserById(Long userId) 
    {
        UserEntity userEntity = userRepository.getUserById(userId);
        UserBo userBo = [...convert userEntity to userBo...];
        return userBo;
    }
}

public class UserBo 
{
    // 省略其他属性、get/set/construct方法
    private Long id;
    private String name;
    private String cellphone;
}

////////// Repository+Entity //////////
public class UserRepository 
{
    public UserEntity getUserById(Long userId) 
    { 
        //... 
    }
}

public class UserEntity 
{
    // 省略其他属性、get/set/construct方法
    private Long id;
    private String name;
    private String cellphone;
}
```

从代码中，我们可以发现，UserBo 是一个纯粹的数据结构，只包含数据，不包含任何业务逻辑。业务逻辑集中在 UserService 中。我们通过 UserService 来操作 UserBo。换句话说，Service 层的数据和业务逻辑，被分割为 BO 和 Service 两个类中。像 UserBo 这样，**只包含数据，不包含业务逻辑的类，就叫作贫血模型（Anemic Domain Model）**。同理，UserEntity、UserVo 都是基于贫血模型设计的。这种**贫血模型将数据与操作分离，破坏了面向对象的封装特性，是一种典型的面向过程的编程风格**。

## 基于充血模型的 DDD 开发模式
在贫血模型中，数据和业务逻辑被分割到不同的类中。**充血模型（Rich Domain Model）正好相反，数据和对应的业务逻辑被封装到同一个类中**。因此，这种充血模型满足面向对象的封装特性，是典型的面向对象编程风格。

领域驱动设计，即 DDD，主要是**用来指导如何解耦业务系统，划分业务模块，定义业务领域模型及其交互**。领域驱动设计这个概念并不新颖，早在 2004 年就被提出了，到现在已经有十几年的历史了。不过，它被大众熟知，还是基于另一个概念的兴起，那就是`微服务`。

实际上，基于充血模型的 DDD 开发模式实现的代码，也是按照 MVC 三层架构分层的。Controller 层还是负责暴露接口，Repository 层还是负责数据存取，Service 层负责核心业务逻辑。它**跟基于贫血模型的传统开发模式的区别主要在 Service 层**。

在基于贫血模型的传统开发模式中，Service 层包含 Service 类和 BO 类两部分，BO 是贫血模型，只包含数据，不包含具体的业务逻辑。业务逻辑集中在 Service 类中。在基于充血模型的 DDD 开发模式中，Service 层包含 Service 类和 Domain 类两部分。Domain 就相当于贫血模型中的 BO。不过，Domain 与 BO 的区别在于它是基于充血模型开发的，既包含数据，也包含业务逻辑。而 Service 类变得非常单薄。总结一下的话就是，**基于贫血模型的传统的开发模式，重 Service 轻 BO；基于充血模型的 DDD 开发模式，轻 Service 重 Domain**。

## 贫血模型流行的原因
现在几乎所有的 Web 项目，都是基于这种贫血模型的开发模式，甚至连 Java Spring 框架的官方 demo，都是按照这种开发模式来编写的。
1. **大部分情况下，我们开发的系统业务可能都比较简单**，简单到就是基于 SQL 的 CRUD 操作，所以，我们根本不需要动脑子精心设计充血模型，贫血模型就足以应付这种简单业务的开发工作。除此之外，因为业务比较简单，即便我们使用充血模型，那模型本身包含的业务逻辑也并不会很多，设计出来的领域模型也会比较单薄，跟贫血模型差不多，没有太大意义；
2. **充血模型的设计要比贫血模型更加有难度**。因为充血模型是一种面向对象的编程风格。我们从一开始就要设计好针对数据要暴露哪些操作，定义哪些业务逻辑。而不是像贫血模型那样，我们只需要定义数据，之后有什么功能开发需求，我们就在 Service 层定义什么操作，不需要事先做太多设计；
3. **思维已固化，转型有成本**。基于贫血模型的传统开发模式经历了这么多年，已经深得人心、习以为常。你随便问一个旁边的大龄同事，基本上他过往参与的所有 Web 项目应该都是基于这个开发模式的，而且也没有出过啥大问题。如果转向用充血模型、领域驱动设计，那势必有一定的学习成本、转型成本。很多人在没有遇到开发痛点的情况下，是不愿意做这件事情的；

## 什么时候使用充血模型
基于贫血模型的传统的开发模式，比较适合业务比较简单的系统开发。相对应地，**基于充血模型的 DDD 开发模式，更适合业务复杂的系统开发**。比如，包含各种利息计算模型、还款模型等复杂业务的金融系统。

实际上，除了我们能看到的代码层面的区别之外（一个业务逻辑放到 Service 层，一个放到领域模型中），还有一个非常重要的区别，那就是**两种不同的开发模式会导致不同的开发流程**。

不夸张地讲，**我们平时的开发，大部分都是 SQL 驱动（SQL-Driven）的开发模式**。我们接到一个后端接口的开发需求的时候，就去看接口需要的数据对应到数据库中，需要哪张表或者哪几张表，然后思考如何编写 SQL 语句来获取数据。之后就是定义 Entity、BO、VO，然后模板式地往对应的 Repository、Service、Controller 类中添加代码。

业务逻辑包裹在一个大的 SQL 语句中，而 Service 层可以做的事情很少。SQL 都是针对特定的业务功能编写的，复用性差。当我要开发另一个业务功能的时候，只能重新写个满足新需求的 SQL 语句，这就可能导致**各种长得差不多、区别很小的 SQL 语句满天飞**。

如果我们在项目中，应用基于充血模型的 DDD 的开发模式，那对应的开发流程就完全不一样了。在这种开发模式下，**我们需要事先理清楚所有的业务，定义领域模型所包含的属性和方法**。领域模型相当于可复用的业务中间层。新功能需求的开发，都基于之前定义好的这些领域模型来完成。

我们知道，越复杂的系统，对代码的复用性、易维护性要求就越高，我们就越应该花更多的时间和精力在前期设计上。而基于充血模型的 DDD 开发模式，正好**需要我们前期做大量的业务调研、领域模型设计，所以它更加适合这种复杂系统的开发**。
