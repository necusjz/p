---
title: Mediator Design Pattern
date: 2020-12-24 18:29:49
tags:
  - GoF
---
## 中介模式的原理和实现
`中介模式`的英文翻译是 Mediator Design Pattern。它是这样定义的：
> Mediator pattern defines a separate (mediator) object that encapsulates the interaction between a set of objects and the objects delegate their interaction to a mediator object instead of interacting with each other directly.

翻译成中文就是：中介模式定义了一个单独的（中介）对象，来封装一组对象之间的交互。**将这组对象之间的交互委派给与中介对象交互，来避免对象之间的直接交互**。实际上，中介模式的设计思想跟中间层很像，通过引入中介这个中间层，将一组对象之间的交互关系（或者说依赖关系）从多对多（网状关系）转换为一对多（星状关系）。原来一个对象要跟 n 个对象交互，现在只需要跟一个中介对象交互，从而**最小化对象之间的交互关系，降低了代码的复杂度，提高了代码的可读性和可维护性**。

这里我画了一张对象交互关系的对比图。其中，右边的交互图是利用中介模式对左边交互关系优化之后的结果，从图中我们可以很直观地看出，右边的交互关系更加清晰、简洁：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/GoF/30.png)
<!--more-->

假设我们有一个比较复杂的对话框，对话框中有很多控件，比如按钮、文本框、下拉框等。当我们对某个控件进行操作的时候，其他控件会做出相应的反应，比如，我们在下拉框中选择“注册”，注册相关的控件就会显示在对话框中。如果我们在下拉框中选择“登陆”，登陆相关的控件就会显示在对话框中。按照通常我们习惯的 UI 界面的开发方式，我们将刚刚的需求用代码实现出来。在这种实现方式中，**控件和控件之间互相操作、互相依赖**：
```java
public class UIControl 
{
    private static final String LOGIN_BTN_ID = "login_btn";
    private static final String REG_BTN_ID = "reg_btn";
    private static final String USERNAME_INPUT_ID = "username_input";
    private static final String PASSWORD_INPUT_ID = "pswd_input";
    private static final String REPEATED_PASSWORD_INPUT_ID = "repeated_pswd_input";
    private static final String HINT_TEXT_ID = "hint_text";
    private static final String SELECTION_ID = "selection";

    public static void main(String[] args) 
    {
        Button loginButton = (Button)findViewById(LOGIN_BTN_ID);
        Button regButton = (Button)findViewById(REG_BTN_ID);
        Input usernameInput = (Input)findViewById(USERNAME_INPUT_ID);
        Input passwordInput = (Input)findViewById(PASSWORD_INPUT_ID);
        Input repeatedPswdInput = (Input)findViewById(REPEATED_PASSWORD_INPUT_ID);
        Text hintText = (Text)findViewById(HINT_TEXT_ID);
        Selection selection = (Selection)findViewById(SELECTION_ID);

        loginButton.setOnClickListener(new OnClickListener() 
        {
            @Override
            public void onClick(View v) 
            {
                String username = usernameInput.text();
                String password = passwordInput.text();
                // 校验数据...
                // 做业务处理...
            }
        });

        regButton.setOnClickListener(new OnClickListener() 
        {
            @Override
            public void onClick(View v) 
            {
            // 获取 usernameInput、passwordInput、repeatedPswdInput 数据...
            // 校验数据...
            // 做业务处理...
            }
        });

        //...省略 selection 下拉选择框相关代码...
    }
}
```

我们再按照中介模式，将上面的代码重新实现一下。在新的代码实现中，**各个控件只跟中介对象交互，中介对象负责所有业务逻辑的处理**：
```java
public interface Mediator 
{
    void handleEvent(Component component, String event);
}

public class LandingPageDialog implements Mediator 
{
    private Button loginButton;
    private Button regButton;
    private Selection selection;
    private Input usernameInput;
    private Input passwordInput;
    private Input repeatedPswdInput;
    private Text hintText;

    @Override
    public void handleEvent(Component component, String event) 
    {
        if (component.equals(loginButton)) 
        {
            String username = usernameInput.text();
            String password = passwordInput.text();
            // 校验数据...
            // 做业务处理...
        } 
        else if (component.equals(regButton)) 
        {
            // 获取 usernameInput、passwordInput、repeatedPswdInput 数据...
            // 校验数据...
            // 做业务处理...
        } 
        else if (component.equals(selection)) 
        {
            String selectedItem = selection.select();
            if (selectedItem.equals("login")) 
            {
                usernameInput.show();
                passwordInput.show();
                repeatedPswdInput.hide();
                hintText.hide();
                //...省略其他代码
            } 
            else if (selectedItem.equals("register")) 
            {
                //...
            }
        }
    }
}

public class UIControl 
{
    private static final String LOGIN_BTN_ID = "login_btn";
    private static final String REG_BTN_ID = "reg_btn";
    private static final String USERNAME_INPUT_ID = "username_input";
    private static final String PASSWORD_INPUT_ID = "pswd_input";
    private static final String REPEATED_PASSWORD_INPUT_ID = "repeated_pswd_input";
    private static final String HINT_TEXT_ID = "hint_text";
    private static final String SELECTION_ID = "selection";

    public static void main(String[] args) 
    {
        Button loginButton = (Button)findViewById(LOGIN_BTN_ID);
        Button regButton = (Button)findViewById(REG_BTN_ID);
        Input usernameInput = (Input)findViewById(USERNAME_INPUT_ID);
        Input passwordInput = (Input)findViewById(PASSWORD_INPUT_ID);
        Input repeatedPswdInput = (Input)findViewById(REPEATED_PASSWORD_INPUT_ID);
        Text hintText = (Text)findViewById(HINT_TEXT_ID);
        Selection selection = (Selection)findViewById(SELECTION_ID);

        Mediator dialog = new LandingPageDialog();
        dialog.setLoginButton(loginButton);
        dialog.setRegButton(regButton);
        dialog.setUsernameInput(usernameInput);
        dialog.setPasswordInput(passwordInput);
        dialog.setRepeatedPswdInput(repeatedPswdInput);
        dialog.setHintText(hintText);
        dialog.setSelection(selection);

        loginButton.setOnClickListener(new OnClickListener() 
        {
            @Override
            public void onClick(View v) 
            {
                dialog.handleEvent(loginButton, "click");
            }
        });

        regButton.setOnClickListener(new OnClickListener() 
        {
            @Override
            public void onClick(View v) 
            {
                dialog.handleEvent(regButton, "click");
            }
        });

        //...
    }
}
```

从代码中我们可以看出，原本业务逻辑会分散在各个控件中，现在都集中到了中介类中。实际上，这样做既有好处，也有坏处。**好处是简化了控件之间的交互，坏处是中介类有可能会变成大而复杂的 God Class**。所以，在使用中介模式的时候，我们要根据实际的情况，平衡对象之间交互的复杂度和中介类本身的复杂度。

## 中介模式 vs. 观察者模式
在观察者模式中，尽管一个参与者既可以是观察者，同时也可以是被观察者，但是，大部分情况下，**交互关系往往都是单向的，一个参与者要么是观察者，要么是被观察者**，不会兼具两种身份。也就是说，在观察者模式的应用场景中，参与者之间的交互关系比较有条理。

而中介模式正好相反。**只有当参与者之间的交互关系错综复杂，维护成本很高的时候，我们才考虑使用中介模式**。毕竟，中介模式的应用会带来一定的副作用，前面也讲到，它有可能会产生大而复杂的上帝类。除此之外，如果一个参与者状态的改变，其他参与者执行的操作有一定先后顺序的要求，这个时候，中介模式就可以利用中介类，通过先后调用不同参与者的方法，来实现顺序的控制，而**观察者模式是无法实现这样的顺序要求的**。
