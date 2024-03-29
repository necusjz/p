---
title: AOAPC 读书笔记 Ⅱ
tags:
  - C++
abbrlink: 2841794997
date: 2017-05-03 17:18:43
---
> 函数和递归

## 自定义函数和结构体
**函数可以定义成：**
```
返回类型 函数名(参数列表) 
{
    函数体
}
```
函数体的最后一条语句，应该是“return 表达式”；
参数和返回值最好是“一等公民”；
执行过程中，碰到了 **return 语句**，将直接退出这个函数，不去执行后面的语句；
始终没有 return 语句，则会返回一个不确定的值。
**定义结构体的方法为：**
```
struct 结构体名称 
{
    域定义
};
```
<!--more-->
为了让结构体用起来和 int、double 这样的原生类型更接近，往往用：
```
typedef struct 
{
    域定义
} 类型名;
```
即使最终答案在数据范围之内，中间结果仍然可能溢出；
对复杂的表达式**进行化简**，不仅能减少计算量，还能减少甚至避免中间结果溢出；
建议把**谓词**（用来判断某事物是否具有某种特性的函数）命名为“is_xxx”的形式。
通过四舍五入避免浮点误差：
```
int m = floor(sqrt(n) + 0.5);
```
## 函数调用与参数传递
### 形参与实参
函数的**调用过程：**计算实参的值，赋值给对应的形参，然后把“当前代码行”转移到函数的首部。
* 函数的形参和在函数内声明的变量都是该函数的`局部变量`（local variable）。局部变量的存储空间是临时分配的，执行完毕时释放；
* 在函数外声明的变量是`全局变量`（global variable），可以被任何函数使用。操作全局变量有风险，应谨慎使用。

### 调用栈
**调用栈**（Call Stack）描述的是函数之间的调用关系，由多个栈帧（Stack Frame）组成。
每个栈帧对应着一个未运行完的函数，保存了该函数的返回地址和局部变量：
* 能在执行完毕后找到正确的返回地址；
* 保证了不同函数间的局部变量互不相干。

### 用指针作参数
每个变量都占有一定数目的字节，第一个字节的地址称为变量的地址。
* 用 int *a 声明的变量 a 是指向 int 型变量的指针；
* 赋值 a = &b 的含义是把变量 b 的地址存放在指针 a 中；
* 表达式 *a 代表 a 指向的变量。

> 千万不要滥用指针。

### 数组作为参数和返回值
把数组作为参数传递给函数时，只有数组的首地址作为指针传递给了函数。在函数定义中的 **int a[] 等价于 int *a**。
需要另加一个参数表示元素个数：
```
int sum(int *a, int n)
{
    int ans = 0;
    for(int i = 0; i < n; i++)
        ans += a[i];
    return ans;
}
```
计算左闭右开区间内的元素和：
* 算出从 begin 到 end（不含end）的元素个数 n；
* 用一个新指针 p 作为循环变量。

### 把函数作为函数的参数
排序使用 C++ 中的 sort 函数，“将一个函数作为参数传递给另外一个函数”是很有用的。
## 递归
### 递归定义
递归就是“自己使用自己”的意思，可以是直接的，也可以是间接的。
> 递归定义的优点：简洁而严密。

### 递归函数
注意为递归函数编写**终止条件**，否则将产生无限递归。
### C 语言对递归的支持
由于使用了调用栈，在 C 语言中，调用自己和调用其他函数并没有本质不同；
尽管同一时刻可以有多个栈帧，但“当前代码行”只有一个。设计递归程序的重点在于给下级安排工作。
### 段错误与栈溢出
每次递归调用都需要往调用栈里增加一个栈帧，久而久之就越界了，这种情况叫做**栈溢出**（Stack Overflow）；
在运行时，程序会动态创建一个堆栈段，里面存放着调用栈。
* 在 Linux 中，栈大小并没有储存在可执行程序中，只能用 ulimit 命令修改；
* 在 Windows 中，栈大小存储在可执行程序中。

把较大的数组放在 main 函数外；
局部变量也是放在堆栈段的，栈溢出也可能是局部变量太大。
## 题目选讲
不用函数和递归也可以写出所有程序。
编写代码的顺序：
* **自顶向下**：先写主程序，包括对函数的调用，再实现函数本身；
* **自底向上**：先写函数，再写主程序。

在测试时，先测试工具函数的方式非常常用；
count、min、max 等都是 STL 已经使用的名字，程序中最好避开它们；
> 根据函数编写的需要定义数据结构，而不是一开始就设计好数据结构。

## 小结
在编写实用软件时，往往需要编写自己的头文件。但在大部分算法竞赛中，只编写单个程序文件；
C 语言的函数可以有`副作用`，而不像数学函数那样“纯”。时刻警惕并最小化副作用；
**函数不能返回指针：**
局部变量在栈中，函数执行完毕后，局部变量就失效了。指针里保存的地址仍然存在，但不再属于那个局部变量了。
**推荐写法：**
* 可以把这个指针作为参数，然后在函数里修改它；
* 可以使用 malloc 函数进行动态内存分配。

缓解浮点误差的权宜之计：
加上一个 `EPS` 以后再输出，通常取一个比最低精度还要小几个数量级的小实数。
