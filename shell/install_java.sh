#!/usr/bin/env bash

#解压java
tar -zxvf jdk-8u151-linux-x64.tar.gz -C /usr/local/

#设置环境变量
cat >> /etc/profile <<EOF
export JAVA_HOME=/usr/local/jdk1.8.0_151
export JRE_HOME=$JAVA_HOME/jre
export CLASSPATH=.:$JAVA_HOME/lib:$JRE_HOME/lib
export PATH=$JAVA_HOME/bin:$PATH
EOF

#使配置生效
source /etc/profile

#查看版本信息
java -version

