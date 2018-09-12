# 小明的成绩从去年的72分提升到了今年的85分，请计算小明成绩提升的百分点，并用字符串格式化显示出'xx.x%'，只保留小数点后1位：
from functools import reduce

s1 = 72
s2 = 85
r = s2 / s1
print('%.1f%%' % r)
# 占位符的练习
print('%10d-%02d' % (3, 1))
print('%.2f' % 3.1415926)
# 中文
print('\u4e2d\u6587')
#
'hi %s you have %d massage' % ('diwuqingrou', 10)
#
sum = 0
a = []
for x in [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]:
    sum = sum + x

    a.append(x)
    print(x)
print(sum)
print(a)
#
sum = 0
n = 99
while n > 0:
    sum = sum + n
    n = n - 2
print(sum)


#
def redc(mod):
    if mod > 0:
        return mod
    else:
        return abs(mod)


print(redc(-10))


def person(name, age, **kw):
    print('name:', name, 'age:', age, 'other:', kw)


person('Michael', 30)


def f1(a, b, c=0, *args, **kw):
    print('a =', a, 'b =', b, 'c =', c, 'args =', args, 'kw =', kw)


def f2(a, b, c=0, *, d, **kw):
    print('a =', a, 'b =', b, 'c =', c, 'd =', d, 'kw =', kw)


# *args是可变参数，args接收的是一个tuple；

# **kw是关键字参数，kw接收的是一个dict。

# 递归

def fact(n):
    if n == 1:
        return 1
    return n * fact(n - 1)


# 递归优化

def fact(n):
    return fact_iter(n, 1)


def fact_iter(num, product):
    if num == 1:
        return product
    return fact_iter(num - 1, num * product)


# stdout 1,3,5,7,9,11....
L = []
n = 1
while n <= 99:
    L.append(n)
    n = n + 2


# map
def f(x):
    return x * x


r = map(f, [1, 2, 3, 4, 5, 6, 7, 8, 9])
print(list(r))


#
def add(x, y):
    return x + y


print(reduce(add, [1, 3, 5, 7, 9]))

#
"""
map计算:
reduce:计算
1x10+3=13
13x10+5=135
135x10+7=1357
1357x10+9=13579
"""


#
def fn(x, y):
    return x * 10 + y


def char2num(s):
    digits = {'0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9}
    return digits[s]


print(reduce(fn, map(char2num, '13579')))
# 优化
DIGITS = {'0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9}


def str2int(s):
    def fn(x, y):
        return x * 10 + y

    def char2num(s):
        return DIGITS[s]

    return reduce(fn, map(char2num, s))


# 优化
DIGITS = {'0': 0, '1': 1, '2': 2, '3': 3, '4': 4, '5': 5, '6': 6, '7': 7, '8': 8, '9': 9}


def char2num(s):
    return DIGITS[s]


def str2int(s):
    return reduce(lambda x, y: x * 10 + y, map(char2num, s))


print(str2int('32767'))


# fiter
def is_odd(n):
    return n % 2 == 1


list(filter(is_odd, [1, 2, 4, 5, 6, 9, 10, 15]))


class Student(object):
    def __init__(self, name, password):
        self.__name = name
        self.__password = password


hq = Student("diwuqingrou", "291394199@qq.com")


class Animal(object):
    def run(self):
        print('Animal is running')


class Dog(Animal):
    def run(self):
        print('Dog is running')


class Cat(Animal):
    def run(self):
        print('Dog is running')


dog = Dog()
dog.run()
cat = Cat()
cat.run()
