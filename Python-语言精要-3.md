---
title: Python 语言精要-3
date: 2017-12-31 23:24:52
tags:
  - Python
---
## 列表、集合以及字典的推导式
**列表推导式**是最受欢迎的 Python 的语言特性之一，只需一条简洁的表达式，即可对一组元素进行过滤，并对得到的元素进行转换变形。基本形式：
```
[expr for value in collection if condition]
```
这相当于下面这段 for 循环：
```
result = []
for val in collection:
    if condition:
        result.append(expr)
```
过滤条件可以省略。滤除长度小于等于 2 的字符串，并将剩下的字符串转换成大写字母形式：
```
strings = ['a', 'as', 'bat', 'car', 'dove', 'python']
[x.upper() for x in strings if len(x) > 2]

['BAT', 'CAR', 'DOVE', 'PYTHON']
```
<!--more-->
**字典推导式**的基本形式，产生的是字典：
```
dict_comp = {key_expr:value_expr for value in collection if condition}
```
**集合推导式**的基本形式，跟列表推导式的唯一区别就是花括号：
```
set_comp = {expr for value in collection if condition}
```
推导式都只是**语法糖**而已，使代码变得更容易读写。
构造一个集合，其内容为列表字符串的各种长度：
```
unique_lengths = {len(x) for x in strings}
unique_lengths

set([1, 2, 3, 4, 6])
```
为这些字符串创建一个指向其列表位置的映射关系：
```
loc_mapping = {val:index for index, val in enumerate(strings)}
loc_mapping

{'a':0, 'as':1, 'bat':2, 'car':3, 'dove':4, 'python':5}
```
### 嵌套列表推导式
嵌套 for 循环中各个 for 的顺序是怎样的，嵌套推导式中各个 for 表达式的顺序就是怎样的。将一个由整数元组构成的列表**扁平化**为一个简单的整数列表：
```
some_tuples = [(1, 2, 3), (4, 5, 6), (7, 8, 9)]
flattened = [x for tup in some_tuples for x in tup]
flattened

[1, 2, 3, 4, 5, 6, 7, 8, 9]
```
如果嵌套超过两三层，就需要思考一下**数据结构**的设计问题了。注意与“列表推导式中的列表推导式”之间的区别：
```
[[x for x in tup] for tup in some_tuples]
```
## 函数
函数是用 def 关键字声明的，并使用 return 关键字返回。可以有一些**位置参数**（positional）和一些**关键字参数**（keyword）：
```
def my_function(x, y, z=1.5):
    if z > 1:
        return z * (x + y)
    else:
        return z / (x + y)
```
> 关键字参数必须位于位置参数之后，你可以任何顺序指定关键字参数。

### 命名空间、作用域，以及局部函数
函数可以访问两种不同作用域中的变量：**全局**（global）和**局部**（local）。局部命名空间（namespace）是在函数被调用时创建的，执行完毕之后就会被销毁。
在函数中对全局变量进行赋值操作，必须用 **global** 关键字声明成全局的：
```
a = None
def bind_a_variable():
    global a
    a = []
```
> 不要频繁使用 global 关键字，因为全局变量一般是用于存放系统的某些状态的。如果用了很多，说明需要面向对象编程（使用类）。

严格意义上来说，所有函数都是某个作用域的局部函数。
### 返回多个值
许多函数都可能会有多个输出（在该函数内部计算出的数据结构或其他辅助数据），其实只返回了一个对象，也就是**一个元组**。
返回字典：
```
def f():
    a = 5
    b = 6
    c = 7
    return {'a':a, 'b':b, 'c':c}
```
### 函数亦为对象
假设我们有下面这样一个字符串数组，希望对其进行一些数据清理工作并执行一堆转换：
```
states = ['Alabama ', 'Georgia!', 'Georgia', 'georgia', 'FlOrIda', 'south   carolina##', 'West virginia?']
```
将需要在一组给定字符串上执行的所有运算做成一个列表：
```
import re

#移除标点符号
def remove_punctuation(value):
    return re.sub('[!#?]', '', value)
clean_ops = [str.strip, remove_punctuation, str.title]

def clean_strings(strings, ops):
    result = []
    for value in strings:
        for function in ops:
            value = function(value)
        result.append(value)
    return result
```
然后我们就有了：
```
clean_strings(states, clean_ops)

['Alabama', 'Georgia', 'Georgia', 'Georgia', 'Florida', 'South   Carolina', 'West Virginia']
```
这种多函数模式，能在很高的层次上，轻松修改字符串的转换方式。此时的 clean_strings 也更具**可复用性**。
还可以将函数用作其他函数的参数。**map 函数**用于在一组数据上应用一个函数：
```
map(remove_punctuation, states)

['Alabama ', 'Georgia', 'Georgia', 'georgia', 'FlOrIda', 'south   carolina', 'West virginia']
```
### 匿名（lambda）函数
仅由**单条语句**组成，该语句的结果就是返回值。
通过 **lambda** 关键字定义的，没有别的含义，仅仅是说“我们正在声明的是一个匿名函数”。
很多数据转换函数都以函数作为参数，直接传入 lambda 函数比编写完整的函数声明要少输入很多字，也更清晰：
```
def apply_to_list(some_list, f):
    return [f(x) for x in some_list]
ints = [4, 0, 1, 5, 6]

apply_to_list(ints, lambda x: x * 2)
```
根据各字符串不同字母的数量对其进行排序：
```
strings = ['foo', 'card', 'bar', 'aaaa', 'abab']
strings.sort(key=lambda x: len(set(list(x))))
strings

['aaaa', 'foo', 'abab', 'bar', 'card']
```
> lambda 函数之所以会被称为匿名函数，原因之一就是这种函数对象，本身是没有提供名称属性的。

### 闭包：返回函数的函数
闭包就是由其他函数动态生成，并返回的函数。
**关键性质：**被返回的函数可以访问，其创建者局部命名空间中的变量。
虽然可以修改任何内部状态对象（比如向字典添加键值对），但不能绑定外层函数作用域中的变量。解决办法是，修改字典或列表，而不是绑定变量：
```
def make_counter():
    count = [0]
    def counter():
        count[0] += 1
        return count[0]
    return counter

cnt = make_counter()
```
可以编写带有大量选项的非常一般化的函数，然后再组装出更简单、更专门化的函数：
```
def format_and_pad(template, space):
    def formatter(x):
        return (template % x).rjust(space)
    return formatter

#创建一个始终返回15位字符串的浮点数格式化器
fmt = format_and_pad('%.4f', 15)
fmt(1.756)

’         1.7560‘
```
> 通过面向对象编程，这种模式也能用类来实现。

### 扩展调用语法和 *args、**kwargs
在 Python 中，函数参数的工作方式其实很简单，位置和关键字参数分别被打包成元组和字典。
这一切都是在幕后悄悄发生的，函数实际接收到的是一个**元组 args** 和一个**字典 kwargs**。
### 柯里化：部分参数应用
柯里化（currying）指的是：通过**部分参数应用**（partial argument application）从现有函数派生出新函数的技术。
其实只是定义了一个可以调用现有函数的新函数而已：
```
def add_numbers(x, y):
    return x + y
add_five = lambda y: add_numbers(5, y)
```
add_numbers 的第二个参数称为“柯里化的”。内置的 functools 模块可以用 **partial 函数**将此过程简化：
```
from functools import partial
add_five = partial(add_numbers, 5)
```
### 生成器
能以一种一致的方式对序列进行迭代，是 Python 的一个重要特点。这是通过一种叫做迭代器协议（iterator protocol）的方式实现的：
```
some_dict = {'a':1, 'b':2, 'c':3}
for key in some_dict:
    print key,    #注意逗号

a c b
```
**迭代器**是一种特殊对象，当你编写 for key in some\_dict 时，Python 解释器首先会尝试从 some\_dict 创建一个迭代器：
```
dict_iterator = iter(some_dict)
dict_iterator

<dictionary-keyiterator at 0x10a0a1578>
```
**生成器**（generator）是构造可迭代对象的一种简单方式。生成器以**延迟**的方式返回一个值序列，即每返回一个值之后暂停，直到下一个值被请求时再继续。
要创建一个生成器，只需要将函数中的 return 替换为 **yeild** 即可：
```
def squares(n=10):
    print 'Generating squares from 1 to %d' % (n ** 2)
    for i in xrange(1, n+1):
        yield i ** 2
```
调用该生成器时，没有任何代码会被立即执行：
```
gen = squares()
gen

<generator object squares at 0x34c8280>
```
直到你从该生成器中请求元素时，它才会开始执行其代码：
```
for x in gen:
    print x,

Generating squares from 1 to 100
1 4 9 16 25 36 49 64 81 100
```
#### 生成器表达式
生成器表达式（generator expression）是构造生成器的最简单方式。类似于列表、字典、集合推导式，创建方式为，把列表推导式两端的方括号改成圆括号：
```
gen = (x ** 2 for x in xrange(100))

#与下面这个冗长的生成器，完全等价
def make_gen():
    for x in xrange(100):
        yield x ** 2
gen = make_gen()
```
生成器表达式可用于任何接受生成器的 Python 函数：
```
sum(x ** 2 for x in xrange(100))
328350

dict((i, i ** 2) for i in xrange(5))
{0:0, 1:1, 2:4, 3:9, 4:16}
```
#### itertools 模块
标准库 itertools 模块中有一组用于许多常见数据算法的生成器。例如，groupby 可以接受任何序列和一个函数，根据函数的返回值，对序列中的连续元素**进行分组：**
```
import itertools
first_letter = lambda x: x[0]
names = ['Alan', 'Adam', 'Wes', 'Will', 'Albert', 'Steven']
for letter, names in itertools.groupby(names, first_letter):
    print letter, list(names)    #names是一个生成器

A ['Alan', 'Adam']
W ['Wes', 'Will']
A ['Albert']
S ['Steven']
```
## 文件和操作系统
Python 在文本和文件处理方面很流行。
为了打开一个文件以便读写，可以使用内置的 **open 函数**以及一个相对或绝对的文件路径：
```
path = 'ch13/segismundo.txt'
f = open(path)
```
默认情况下，文件是以只读模式（'r'）打开的。然后，我们就可以处理这个文件**句柄** f 了：
```
for line in f:
    pass
```
Python 的文件模式：
![](https://raw.githubusercontent.com/was48i/mPOST/master/python/python_3.jpeg)
重要的 Python 文件方法或属性：
![](https://raw.githubusercontent.com/was48i/mPOST/master/python/python_4.jpeg)
