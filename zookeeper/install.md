* 确保JDK已经安装成功,并下载zookeeper的tar包

* 解压zookeeper到指定的目录,例如/usr/local/

* 在zookeeper的根目录下创建data目录

* 重命名/usr/local/zookeeper/conf这个目录下的zoo_sample.cfg为zoo.cfg

* 配置zoo.cfg文件,具体配置,修改dateDir这一行

dataDir=/usr/local/zookeeper/Data
* 末尾增加如下配置[node1,2,3是所有的节点主机名]

server.1=node1:2888:3888
server.2=node2:2888:3888
server.3=node2:2888:3888

* 在/usr/local/zookeeper/Data目录下创建一个myid的文件

`cat >> myid << EOF
 1 
 EOF`
 
* 拷贝配置好的zookeeper到其他节点

cp -r zookeeper/ root@node1:/usr/local/

cp -r zookeeper/ root@node2:/usr/local/

* 并分别修改node2，node2中myid文件中内容为2、3

* 三个节点分别启动集群: bin/zkServer.sh start

* 三个节点分别查看集群状态: bin/zkServer.sh status

* 停止集群: bin/zkServer.sh stop

* 配置环境变量

vi /etc/profile 

`export ZOOKEEPER_HOME=/usr/local/zookeeper/ 
export PATH=$PATH:$ZOOKEEPER_HOME/bin`

source /etc/profile 

* zkCli.sh  客户端操作