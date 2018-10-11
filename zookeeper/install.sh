#!/usr/bin/env bash
$node1=master1
$node2=master2
$node3=master3

#下载zookeeper包
mkdir -p /root/zookeeper
wget https://mirrors.tuna.tsinghua.edu.cn/apache/zookeeper/zookeeper-3.4.10/zookeeper-3.4.10.tar.gz
#解压zookeeper到指定的目录,例如/usr/local/
tar -zxvf -C  zookeeper-3.4.10.tar.gz /usr/local/

#在zookeeper的根目录下创建data目录
mkdir -p /data
#重命名/usr/local/zookeeper/conf这个目录下的zoo_sample.cfg为zoo.cfg
mv $ZOOKEEPER_HOME/conf/zoo_sample.cfg  $ZOOKEEPER_HOME/conf/zoo.cfg
#配置zoo.cfg文件,具体配置,修改dateDir这一行
sed -i 's/dataDir=\/tmp\/zookeeper/dataDir=\$ZOOKEEPER_HOME\/Data/g'  $ZOOKEEPER_HOME/conf/zoo.cfg
#末尾增加如下配置[node1,2,3是所有的节点主机名]
cat >> $ZOOKEEPER_HOME/conf/zoo.cfg << EOF
server.1=$node1:2888:3888
server.2=$node2:2888:3888
server.3=$node2:2888:3888
EOF
#在/usr/local/zookeeper/Data目录下创建一个myid的文件

cat >> myid << EOF
 1 
EOF
 
#拷贝配置好的zookeeper到其他节点
cp -r $ZOOKEEPER_HOME/ root@$node2:/usr/local/
cp -r $ZOOKEEPER_HOME/ root@$node3:/usr/local/

#并分别修改node2，node2中myid文件中内容为2、3

#三个节点分别启动集群: bin/zkServer.sh start

#三个节点分别查看集群状态: bin/zkServer.sh status

#停止集群: bin/zkServer.sh stop

#zkCli.sh  客户端操作