#!/usr/bin/env bash
#在其他节点安装,需要ssh互信
#所有节点的主机名

node1=nginx
#node2=
#node3=


#下载zookeeper包

wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz

#解压zookeeper到指定的目录,例如/usr/local/

tar -zxvf   zookeeper-3.4.10.tar.gz /usr/local/

ZOOKEEPER_HOME=/usr/local/zookeeper-3.4.10

#配置环境变量

cat >> /etc/profile << EOF
#zookeeper
export ZOOKEEPER_HOME=$ZOOKEEPER_HOME
export PATH=$PATH:$ZOOKEEPER_HOME/bin
EOF

#生效环境变量

source /etc/profile

#在zookeeper的根目录下创建data目录

mkdir -p $ZOOKEEPER_HOME/data

#重命名/usr/local/zookeeper/conf这个目录下的zoo_sample.cfg为zoo.cfg

mv $ZOOKEEPER_HOME/conf/zoo_sample.cfg  $ZOOKEEPER_HOME/conf/zoo.cfg

#配置zoo.cfg文件,具体配置,修改dateDir这一行

sed -i 's/dataDir=\/tmp\/zookeeper/dataDir=\$ZOOKEEPER_HOME\/data/g'  $ZOOKEEPER_HOME/conf/zoo.cfg

#末尾增加如下配置[node1,2,3是所有的节点主机名]

cat >> $ZOOKEEPER_HOME/conf/zoo.cfg << EOF
server.1=$node1:2888:3888
#server.2=$node2:2888:3888
#server.3=$node2:2888:3888
EOF

#在/usr/local/zookeeper/Data目录下创建一个myid的文件

cat >> $ZOOKEEPER_HOME/myid << EOF
 1
EOF

#拷贝配置好的zookeeper到其他节点

#cp -r $ZOOKEEPER_HOME/ root@$node2:/usr/local/
#cp -r $ZOOKEEPER_HOME/ root@$node3:/usr/local/


#并分别修改node2，node2中myid文件中内容为2、3

#ssh $node2  echo "2" > $ZOOKEEPER_HOME/myid
#ssh $node3  echo "3" > $ZOOKEEPER_HOME/myid

#三个节点分别启动集群: bin/zkServer.sh start

$ZOOKEEPER_HOME/bin/zkServer.sh start
#ssh $node2 $ZOOKEEPER_HOME/bin/zkServer.sh start
#ssh $node3 $ZOOKEEPER_HOME/bin/zkServer.sh start

#三个节点分别查看集群状态: bin/zkServer.sh status

#$ZOOKEEPER_HOME/bin/zkServer.sh status
#ssh $node2 $ZOOKEEPER_HOME/bin/zkServer.sh status
#ssh $node3 $ZOOKEEPER_HOME/bin/zkServer.sh status

#停止集群: bin/zkServer.sh stop

#$ZOOKEEPER_HOME/bin/zkServer.sh stop
#ssh $node2 $ZOOKEEPER_HOME/bin/zkServer.sh stop
#ssh $node3 $ZOOKEEPER_HOME/bin/zkServer.sh stop

#zkCli.sh  客户端操作

