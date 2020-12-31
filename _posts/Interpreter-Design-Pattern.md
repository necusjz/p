---
title: Interpreter Design Pattern
date: 2020-12-24 17:45:49
tags:
  - GoF
---
## 解释器模式的原理和实现
`解释器模式`的英文翻译是 Interpreter Design Pattern。它是这样定义的：
> Interpreter pattern is used to defines a grammatical representation for a language and provides an interpreter to deal with this grammar.

翻译成中文就是：解释器模式**为某个语言定义它的语法表示，并定义一个解释器用来处理这个语法**。要想了解“语言”表达的信息，我们就必须定义相应的语法规则。这样，书写者就可以根据语法规则来书写“表达式”，阅读者根据语法规则来阅读“表达式”，这样才能做到信息的正确传递。而我们要讲的解释器模式，其实就是用来实现根据语法规则解读“表达式”的解释器。假设我们定义了一个新的加减乘除计算“语言”，语法规则如下：
- 运算符只包含加、减、乘、除，并且没有优先级的概念；
- 表达式中，先书写数字，后书写运算符，空格隔开；
- 按照先后顺序，取出两个数字和一个运算符计算结果，结果重新放入数字的最头部位置，循环上述过程，直到只剩下一个数字，这个数字就是表达式最终的计算结果；

看懂了上面的语法规则，我们将它用代码实现出来。代码非常简单，**用户按照上面的规则书写表达式，传递给 interpret() 函数**，就可以得到最终的计算结果：
<!--more-->
```java
public class ExpressionInterpreter 
{
    private Deque<Long> numbers = new LinkedList<>();

    public long interpret(String expression) 
    {
        String[] elements = expression.split(" ");
        int length = elements.length;
        for (int i = 0; i < (length + 1) / 2; ++i) 
        {
            numbers.addLast(Long.parseLong(elements[i]));
        }

        for (int i = (length + 1) / 2; i < length; ++i) 
        {
            String operator = elements[i];
            boolean isValid = "+".equals(operator) || "-".equals(operator) || "*".equals(operator) || "/".equals(operator);
            if (!isValid) 
            {
                throw new RuntimeException("Expression is invalid: " + expression);
            }

            long number1 = numbers.pollFirst();
            long number2 = numbers.pollFirst();
            long result = 0;
            if (operator.equals("+")) 
            {
                result = number1 + number2;
            } 
            else if (operator.equals("-")) 
            {
                result = number1 - number2;
            } 
            else if (operator.equals("*")) 
            {
                result = number1 * number2;
            } 
            else if (operator.equals("/")) 
            {
                result = number1 / number2;
            }
            numbers.addFirst(result);
        }

        if (numbers.size() != 1) 
        {
            throw new RuntimeException("Expression is invalid: " + expression);
        }

        return numbers.pop();
    }
}
```

在上面的代码实现中，语法规则的解析逻辑（第 28、32、36、40 行）都集中在一个函数中，对于简单的语法规则的解析，这样的设计就足够了。但是，对于复杂的语法规则的解析，逻辑复杂，代码量多，所有的解析逻辑都耦合在一个函数中，这样显然是不合适的。这个时候，我们就要**考虑拆分代码，将解析逻辑拆分到独立的小类中**。

解释器模式的代码实现比较灵活，没有固定的模板。我们前面也说过，应用设计模式主要是应对代码的复杂性，实际上，解释器模式也不例外。它的代码实现的核心思想，就是**将语法解析的工作拆分到各个小类中，以此来避免大而全的解析类**。一般的做法是，将语法规则拆分成一些小的独立的单元，然后对每个单元进行解析，最终合并为对整个语法规则的解析。

前面定义的语法规则有两类表达式，一类是数字，一类是运算符，运算符又包括加减乘除。利用解释器模式，我们把解析的工作拆分到 NumberExpression、AdditionExpression、SubtractionExpression、MultiplicationExpression、DivisionExpression 这样五个解析类中。按照这个思路，我们对代码进行重构：
```java
public interface Expression 
{
    long interpret();
}

public class NumberExpression implements Expression 
{
    private long number;

    public NumberExpression(long number) 
    {
        this.number = number;
    }

    public NumberExpression(String number) 
    {
        this.number = Long.parseLong(number);
    }

    @Override
    public long interpret() 
    {
        return this.number;
    }
}

public class AdditionExpression implements Expression 
{
    private Expression exp1;
    private Expression exp2;

    public AdditionExpression(Expression exp1, Expression exp2) 
    {
        this.exp1 = exp1;
        this.exp2 = exp2;
    }

    @Override
    public long interpret() 
    {
        return exp1.interpret() + exp2.interpret();
    }
}

// SubtractionExpression/MultiplicationExpression/DivisionExpression 与 AdditionExpression 代码结构类似

public class ExpressionInterpreter 
{
    private Deque<Expression> numbers = new LinkedList<>();

    public long interpret(String expression) 
    {
        String[] elements = expression.split(" ");
        int length = elements.length;
        for (int i = 0; i < (length + 1) / 2; ++i) 
        {
            numbers.addLast(new NumberExpression(elements[i]));
        }

        for (int i = (length + 1) / 2; i < length; ++i) 
        {
            String operator = elements[i];
            boolean isValid = "+".equals(operator) || "-".equals(operator) || "*".equals(operator) || "/".equals(operator);
            if (!isValid) 
            {
                throw new RuntimeException("Expression is invalid: " + expression);
            }

            Expression exp1 = numbers.pollFirst();
            Expression exp2 = numbers.pollFirst();
            Expression combinedExp = null;
            if (operator.equals("+")) 
            {
                combinedExp = new AdditionExpression(exp1, exp2);
            } 
            else if (operator.equals("-")) 
            {
                combinedExp = new SubtractionExpression(exp1, exp2);
            } 
            else if (operator.equals("*")) 
            {
                combinedExp = new MultiplicationExpression(exp1, exp2);
            } 
            else if (operator.equals("/")) 
            {
                combinedExp = new DivisionExpression(exp1, exp2);
            }
            long result = combinedExp.interpret();
            numbers.addFirst(new NumberExpression(result));
        }

        if (numbers.size() != 1) 
        {
            throw new RuntimeException("Expression is invalid: " + expression);
        }

        return numbers.pop().interpret();
    }
}
```

## 解释器模式实战举例
在我们平时的项目开发中，监控系统非常重要，它可以时刻监控业务系统的运行情况，及时将异常报告给开发者。比如，如果每分钟接口出错数超过 100，监控系统就通过短信、微信、邮件等方式发送告警给开发者。一般来讲，**监控系统支持开发者自定义告警规则**，比如我们可以用下面这样一个表达式，来表示一个告警规则，它表达的意思是：每分钟 API 总出错数超过 100 或者每分钟 API 总调用数超过 10000 就触发告警：
```java
api_error_per_minute > 100 || api_count_per_minute > 10000
```

在监控系统中，**告警模块只负责根据统计数据和告警规则，判断是否触发告警**。至于每分钟 API 接口出错数、每分钟接口调用数等统计数据的计算，是由其他模块来负责的。其他模块将统计数据放到一个 Map 中，发送给告警模块。数据的格式如下所示：
```java
Map<String, Long> apiStat = new HashMap<>();
apiStat.put("api_error_per_minute", 103);
apiStat.put("api_count_per_minute", 987);
```

为了简化讲解和代码实现，我们假设自定义的告警规则只包含“||、&&、>、<、==”这五个运算符，其中，“>、<、==”运算符的优先级高于“||、&&”运算符，“&&”运算符优先级高于“||”。在表达式中，任意元素之间需要通过空格来分隔。除此之外，用户可以自定义要监控的 key，比如前面的 api_error_per_minute、api_count_per_minute。我写了一个骨架代码，如下所示：
```java
public class AlertRuleInterpreter 
{
    // key1 > 100 && key2 < 1000 || key3 == 200
    public AlertRuleInterpreter(String ruleExpression) 
    {
        // TODO: 由你来完善
    }

    // <String, Long> apiStat = new HashMap<>();
    // apiStat.put("key1", 103);
    // apiStat.put("key2", 987);
    public boolean interpret(Map<String, Long> stats) 
    {
        // TODO: 由你来完善
    }
}

public class DemoTest 
{
    public static void main(String[] args) 
    {
        String rule = "key1 > 100 && key2 < 30 || key3 < 100 || key4 == 88";
        AlertRuleInterpreter interpreter = new AlertRuleInterpreter(rule);
        Map<String, Long> stats = new HashMap<>();
        stats.put("key1", 101l);
        stats.put("key3", 121l);
        stats.put("key4", 88l);
        boolean alert = interpreter.interpret(stats);
        System.out.println(alert);
    }
}
```

实际上，我们可以把自定义的告警规则，看作一种特殊“语言”的语法规则。我们**实现一个解释器，能够根据规则，针对用户输入的数据，判断是否触发告警**。利用解释器模式，我们把解析表达式的逻辑拆分到各个小类中，避免大而复杂的大类的出现。按照这个实现思路，我把刚刚的代码补全：
```java
public interface Expression 
{
    boolean interpret(Map<String, Long> stats);
}

public class GreaterExpression implements Expression 
{
    private String key;
    private long value;

    public GreaterExpression(String strExpression) 
    {
        String[] elements = strExpression.trim().split("\\s+");
        if (elements.length != 3 || !elements[1].trim().equals(">")) 
        {
            throw new RuntimeException("Expression is invalid: " + strExpression);
        }
        this.key = elements[0].trim();
        this.value = Long.parseLong(elements[2].trim());
    }

    public GreaterExpression(String key, long value) 
    {
        this.key = key;
        this.value = value;
    }

    @Override
    public boolean interpret(Map<String, Long> stats) 
    {
        if (!stats.containsKey(key)) 
        {
            return false;
        }
        long statValue = stats.get(key);
        return statValue > value;
    }
}

// LessExpression/EqualExpression 跟 GreaterExpression 代码类似

public class AndExpression implements Expression 
{
    private List<Expression> expressions = new ArrayList<>();

    public AndExpression(String strAndExpression) 
    {
        String[] strExpressions = strAndExpression.split("&&");
        for (String strExpr : strExpressions) 
        {
            if (strExpr.contains(">")) 
            {
                expressions.add(new GreaterExpression(strExpr));
            } 
            else if (strExpr.contains("<")) 
            {
                expressions.add(new LessExpression(strExpr));
            } 
            else if (strExpr.contains("==")) 
            {
                expressions.add(new EqualExpression(strExpr));
            } 
            else 
            {
                throw new RuntimeException("Expression is invalid: " + strAndExpression);
            }
        }
    }

    public AndExpression(List<Expression> expressions) 
    {
        this.expressions.addAll(expressions);
    }

    @Override
    public boolean interpret(Map<String, Long> stats) 
    {
        for (Expression expr : expressions) 
        {
            if (!expr.interpret(stats)) 
            {
                return false;
            }
        }
        return true;
    }
}

public class OrExpression implements Expression 
{
    private List<Expression> expressions = new ArrayList<>();

    public OrExpression(String strOrExpression) 
    {
        String[] andExpressions = strOrExpression.split("\\|\\|");
        for (String andExpr : andExpressions) 
        {
            expressions.add(new AndExpression(andExpr));
        }
    }

    public OrExpression(List<Expression> expressions) 
    {
        this.expressions.addAll(expressions);
    }

    @Override
    public boolean interpret(Map<String, Long> stats) 
    {
        for (Expression expr : expressions) 
        {
            if (expr.interpret(stats)) 
            {
                return true;
            }
        }
        return false;
    }
}

public class AlertRuleInterpreter 
{
    private Expression expression;

    public AlertRuleInterpreter(String ruleExpression) 
    {
        this.expression = new OrExpression(ruleExpression);
    }

    public boolean interpret(Map<String, Long> stats) 
    {
        return expression.interpret(stats);
    }
} 
```
