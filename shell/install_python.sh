#!/usr/bin/env bash

# 脚本用于在已有python2.75的centos上编译安装python3.6.6
#下载python3.6.6
echo "下载python3.6.6"
wget https://www.python.org/ftp/python/3.6.6/Python-3.6.6.tgz

#备份python
echo "备份python"
cd /usr/bin/
ll python*
mv python python.bak

#下载安装python需要的包
echo "下载安装python需要的包"
yum install zlib-devel bzip2-devel openssl-devel ncurses-devel sqlite-devel readline-devel tk-devel gcc make -y

#解压python
echo "解压python"
tar -zxvf Python-3.6.6.tgz
#编译前的配置
echo "编译前的配置"
cd Python-3.6.6
./configure prefix=/usr/local/python3
#编译
echo "编译"
make && make install
#生成python3的软连接
echo "生成python3的软连接"
ln -s /usr/local/python3/bin/python3 /usr/bin/python
#查看python版本
echo "查看python版本"
python -V
##查看python2版本
echo ""
python2 -V
#由于urlgrabber-ext-down和yum需要python2，所以将两个环境切换到python2
echo "由于urlgrabber-ext-down和yum需要python2，所以将两个环境切换到python2"
sed -i 's/\#\!\/usr\/bin\/python/\#\!\/usr\/bin\/python2/g'  /usr/libexec/urlgrabber-ext-down
sed -i 's/\#\!\/usr\/bin\/python/\#\!\/usr\/bin\/python2/g'  /usr/bin/yum
