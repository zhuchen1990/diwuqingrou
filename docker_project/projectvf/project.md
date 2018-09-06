**项目环境:**

OS:CentOS Linux release 7.5.1804 (Core)

Docker Version: Client and Server:17.03.1-ce

kubernates: Client:v1.11.2 Server:v1.11.0

----
**java环境:**

jdk:jdk-8u151-linux-x64.tar.gz

**tomcat容器环境:**

tomcat:apache-tomcat-8.5.23.tar.gz

**centos基础镜像环境**

centos:centos-7-docker.tar.xz

**zookeeper服务集群环境**

zookeeper-cluster:zookeeper-cluster.yaml

zookeeper的服务名为diwuqingrou-n1,diwuqingrou-n2,diwuqingrou-n3

需要注意修改war包中配置文件的zookeeper服务地址为上述服务地址

**提供者环境:**

provider:pro-deploy.yaml,Dockerfile_pro,provider.tar.gz

**his环境**

his:his-deploy.yaml,Dockerfile_his,StarTrek.war

**emr环境**

emr:emr-deploy.yaml,Dockerfile_emr,StarTrekEMR.war

创建Dockerfile镜像,并上传到私有仓库,修改yaml中image地址为私有仓库中的镜像地址,同时需要注意环境变量的修改

k8s监控:metrics-server

k8s全栈监控:k8s-monitor


**参考教程及文档:**

Dashboard:https://www.cnblogs.com/RainingNight/p/deploying-k8s-dashboard-ui.html

k8s-monitor:https://www.kubernetes.org.cn/4438.html

k8s多master:https://www.kubernetes.org.cn/4256.html,https://jicki.me/kubernetes/2018/08/10/kubernetes-1.11.2.html

docker私有仓库:https://www.cnblogs.com/Tempted/p/7768694.html

