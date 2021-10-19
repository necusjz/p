---
title: Python 语言精要-1
date: 2017-04-27 16:14:38
tags:
  - Python
---
> 常常得先把那些乱七八糟的数据，处理成漂亮点的结构化形式。

## Python 解释器
一次执行一条语句。
“\>\>\>”是提示符，可以在那里输入表达式。
## 语言语义
重视可读性、简洁性、明确性，可执行的伪代码。
### 缩进，而不是大括号
通过空白符（4 个空格）来组织代码。
**冒号**表示一段缩进代码块的开始，其后必须缩进相同的量，直到代码块结束为止：
<!--more-->
```python
for x in array:
    if x < pivot:
        less.append(x)
    else:
        greater.append(x)
```
在一行上放置多条语句的做法是不推荐的：
```python
a = 5; b = 6; c = 7
```
### 万物皆对象
对象模型的一致性。
即使是函数也能被当做其他对象那样处理。
### 注释
任何前缀为“#”的文本都会被解释器忽略掉。
### 函数调用和对象方法调用
函数的调用需要用到圆括号以及 0 个或多个参数：
```python
result = f(x, y, z)
```
几乎所有的 Python 对象都有一些附属函数（方法），可以访问该对象的内部数据：
```python
obj.some_method(x, y, z)
```
函数既可以接受位置参数，也可以接受关键字参数：
```python
result = f(a, b, c, d=5, e='foo')
```
### 变量和按引用传递
在 Python 中对变量赋值时，其实是在创建等号右侧对象的一个**引用**。
只是传入了一个引用而已，不会发生任何复制：
![](https://raw.githubusercontent.com/umarellyh/mPOST/master/python/python_1.jpeg)
> 按引用传递，Python 函数可以修改其参数的内容。

```python
data = [1, 2, 3]
append_element(data, 4)
data

>>> [1, 2, 3, 4]
```
### 动态引用，强类型
Python 中的对象引用没有与之关联的类型信息，对象的类型信息是保存在它自己**内部**的。
Python 可以被认为是一种**强类型**语言，隐式转换只在很明显的情况下才会发生：
```python
# TypeError
'5' + 5
```
通过 isinstance 函数，可以检查一个对象是否是某个特定类型的实例。可以接受由类型组成的元组：
```python
a = 5
isinstance(a, (int, float))

>>> True
```
### 属性和方法
Python 中的对象通常都既有属性（attribute），又有方法（method）。它们都能通过 obj.attribute_name 这样的语法进行访问。
* 属性：存储在该对象内部的，其他 Python **对象**；
* 方法：与该对象有关的能够访问其内部数据的**函数**。

### “鸭子”类型
你可能不会关心对象的类型，只是想知道它到底有没有某些方法或行为。
**应用场景：**在编写可以接受任何序列（列表、元祖、ndarray）或迭代器的函数时，先检查对象是不是列表，如果不是，就将其转换成是：
```python
if not isinstance(x, list) and isiterable(x):
    x = list(x)
```
### 引入（import）
模块（module）：一个含有函数和变量定义以及从其他 .py 文件引入的此类东西的 **.py 文件**。
```python
# some_module.py
PI = 3.14159

def f(x):
    return x + 2

def g(a, b):
    return a + b
```
通过 **as 关键字**，可以引入不同的变量名（定义别名）：
```python
import some_module as sm
from some_module import PI as pi, g as gf

r1 = sm.f(pi)
r2 = gf(6, pi)
```
### 二元运算符和比较运算符
判断两个引用是否指向同一对象，可以使用 is 关键字。
```python
a = [1, 2, 3]
b = a
# list 函数始终会创建新列表
c = list(a)

a is b
>>> True

a is not c
>>> True
```
跟比较运算“==”，不是一回事。
is 和 is not 常常用于判断变量是否为 None，因为 None 的实例只有一个。
### 严格与懒惰
在 Python 中，只要这些语句被求值，相关计算就会立即（也就是严格）发生。
**延迟计算**（lazy evaluation）：具体值在被使用之前，不会被计算出来。
迭代器、生成器可以用于实现延迟计算，当执行一些负荷非常高的计算时，可以派上用场。
### 可变和不可变的对象
大部分 Python 对象是可变的（mutable），它们所包含的对象或值是可以被修改的；
字符串、元组是不可变的（immutable）。
建议尽量避免**副作用**（side effect），注重不变性。
## 标量类型
### 数值类型
Python 会自动将非常大的整数转换为 long：
```python
ival = 17239871
ival ** 6

>>> 26254519291092456596965462913230729701102721L
```
得到 C 风格的整数除法，使用 //：
```python
3 // 2

>>> 1
```
复数的虚部是用 j 表示的：
```python
cval = 1 + 2j
cval * (1 - 2j)

>>> 5 + 0j
```
### 字符串
编写字符串时，既可以用单引号（'）也可以用双引号（''）。
对于带有换行符的多行字符串，可以使用三重引号。 
Python 字符串是**不可变**的，要修改字符串就只能创建一个新的。
许多对象都可以用 str 函数转换为字符串：
```python
a = 5.6
s = str(a)
s

>>> '5.6'
```
字符串其实是一串**字符序列**，可以被当作某种序列类型进行处理：
```python
s = 'python'
list(s)
>>> ['p', 'y', 't', 'h', 'o', 'n']

s[:3]
>>> 'pyt'
```
用实参替换格式化形参：
```python
template = '%.2f %s are worth $%d'
template % (4.5560, 'Argentine Pesos', 1)

>>> '4.56 Argentine Pesos are worth $1'
```
### 布尔值
Python 中两个布尔值分别写作 True 和 False，可以用 and 和 or 关键字进行连接。
几乎所有内置的 Python 类型都能在 if 语句中被解释为 True 或 False：
```python
a = [1, 2, 3]
if a:
    print 'I found something!'

>>> I found something!
```
想知道某个对象究竟会被强制转换成哪个布尔值，使用 **bool 函数**即可：
```python
bool([]), bool([1, 2, 3])

>>> (False, True)
```
### 类型转换
str、bool、int、float 等类型，也可以作将值转换成该类型的函数：
```python
s = '3.14159'
fval = float(s)
type(fval)

>>> float
```
### None
None 是 Python 的空值类型。如果一个函数没有显式地返回值，则隐式返回 None。
None 是函数可选参数的一种常见默认值。
None 不是一个保留关键字，只是 NoneType 的一个**实例**而已。
### 日期和时间
Python 内置的 datetime 模块中，datetime 类型是用得最多的，它合并了保存在 date 和 time 中的信息：
```python
from datetime import datetime, data, time
dt = datetime(2011, 10, 29, 20, 30, 21)

dt.day
>>> 29

dt.minute
>>> 30
```
strftime 方法用于将 datetime 格式化为字符串（也可以反向解析）：
```python
dt.strftime('%m/%d/%Y %H:%M')

>>> '10/29/2011 20:30'
```
两个 datetime 对象的差会产生一个 datetime.timedelta 类型：
```python
dt2 = datetime(2011, 11, 15, 22, 30)
delta = dt2 - dt
delta

>>> datetime.timedelta(17, 7179)
```
## 控制流
### if、elif、else
一条 if 语句可以跟上一个或多个 **elif 块**以及一个滴水不漏的 **else 块**（如果所有条件都为 False）。
对于用 and 或 or 组成的复合条件，各条件是按从左到右的顺序求值的，而且是**短路型**的。
### for 循环
for 循环用于对集合或迭代器进行迭代，**标准语法：**
```python
for value in collection:
    # 对 value 做一些处理
```
### while 循环
while 循环定义了**一个条件**和**一个代码块**。只要条件不为 False，代码块将一直不断地执行下去。
### pass
Python 中的空操作语句，在开发一个新功能时，常常会将 pass 用作代码中的**占位符：**
```python
def f(x, y, z)
    # TODO: 实现这个函数
    pass
```
### 异常处理
优雅地处理 Python 错误或异常是构建健壮程序的重要环节。
把对函数的调用放在一个 **try/except 块**中，在 except 后面加上异常类型组成的元组，即可捕获多个异常：
```python
def attempt_float(x):
    try:
        return float(x)
    except (TypeError, ValueError):
        return x
```
希望有一段代码不管 try 块代码成功与否都能被执行，使用 **finally** 即可；让某些代码只在 try 块成功时执行，使用 **else** 即可：
```python
f = open(path, 'w')

try:
    write_to_file(f)
except:
    print 'Failed'
else:
    print 'Succeeded'
finally:
    f.close()
```
### range 和 xrange
range 函数用于产生一组间隔平均的整数，可以指定**起始值、结束值、步长**等信息：
```python
range(0, 20, 2)

>>> [0, 2, 4, 6, 8, 10, 12, 14, 16, 18]
```
range 所产生的蒸熟不包括末端值，常用于按索引对序列进行迭代：
```python
seq = [1, 2, 3, 4]
for i in range(len(seq)):
    val = seq[i]
```
对于非常长的范围，建议使用 xrange。不会预先产生所有的值，而是返回一个用于逐个产生整数的**迭代器**。
### 三元表达式
允许将产生一个值的 **if-else 块**写到一行或一个表达式中，语法：
```python
value = true_expr if condition else false_expr
```
如果条件以及 true 和 false 表达式非常复杂，可能会牺牲可读性：
```python
x = 5
'Non-negative' if x >= 0 else 'Negative'

>>> 'Non-negative'
```
