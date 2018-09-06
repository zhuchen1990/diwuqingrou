# efk
目标：在现有Kubernetes集群中搭建EFK日志框架，实现集群日志的存储与展示

环境：Kubernetes集群(kubeadm方式部署)

步骤：Kubernetes日志架构概述->Fluentd日志收集容器部署->Elasticsearch日志存储容器部署->Kibana日志展示容器部署

该方案采用Node Logging Agent的方式，通过在集群每个节点上部署一个Agent代理Pod服务，收集该Node上的日志并push到后端。Agent应具备进入该节点上所有服务容器日志目录的权限。

具体在EFK方案中，logging-agent使用Fluentd，logging backend使用Elasticsearch，另为方便展示，使用kibana获取并展示es数据库数据。

Fluentd日志收集容器以DaemonSet的形式运行在Kubernetes集群中，保证集群中每个Node都会启动一个Fluentd。

在Master节点创建fluentd服务，最终会在所有Node节点上运行。

1.配置文件:fluentd-es-configmap.yaml

kubectl create -f fluentd-es-configmap.yaml

2.部署及服务:fluentd-es-ds.yaml

kubectl create -f fluentd-es-ds.yaml

此处fluentd未能成功启动，因为node节点未打上标签beta.kubernetes.io/fluentd-ds-ready=true

为所有节点打上标签：kubectl label node nodeid beta.kubernetes.io/fluentd-ds-ready=true

注:此处的node id 是每台主机的主机名

重新运行fluentd

kubectl apply -f fluentd-es-ds.yaml

3.Elasticsearch日志存储容器部署

Elasticsearch的主要作用是将日志信息进行分割，建立索引。

cat /etc/sysctl.conf 

vm.max_map_count=655360

将max_map_count值设置为655360，防止该值低于es运行所需，导致es无法正常运行，所有的主机都需要修改

sysctl -p 

es部署文件与服务文件:es-statefulset.yaml,es-service.yaml

kubectl create -f es-statefulset.yaml

kubectl create -f es-service.yaml

4.Kibana日志展示容器部署

Kibana是一个开源的分析与可视化平台，与elasticsearch配合使用，可以使用kibana搜索、查看存储在es中的数据

kibana部署和服务文件:kibana-deployment.yaml,kibana-service.yaml

kubectl create -f kibana-deployment.yaml

kubectl create -f kibana-service.yaml

查看kibana对应的服务地址:

kubectl cluster-info

使用实例:

Management-index pattern-设置index-pattern为logstash-*

discover:即可发现日志

参考文档:https://blog.csdn.net/xingyuzhe/article/details/81059696