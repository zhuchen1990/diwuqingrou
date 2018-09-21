# k8s-monitor

本文章主要介绍如何全面监控k8s

使用metric-server收集数据给k8s集群内使用，如kubectl,hpa,scheduler等

使用prometheus-operator部署prometheus，存储监控数据

使用kube-state-metrics收集k8s集群内资源对象数据

使用node_exporter收集集群中各节点的数据

使用prometheus收集apiserver，scheduler，controller-manager，kubelet组件数据

使用alertmanager实现监控报警

使用grafana实现数据可视化

kubectl apply -f monitoring-namespace.yaml

kubectl apply -f prometheus-operator.yaml

kubectl apply -f node_exporter.yaml

kubectl apply -f kube-state-metrics.yaml

kubectl apply -f prometheus.yaml

kubectl apply -f kube-servicemonitor.yaml

kubectl apply -f alertmanager.yaml

kubectl apply -f grafana.yaml

注:alertmanager.yaml中的data是报警配置,需要重新创建secret
创建保密字典

kubectl create  secret generic alertmanager-main --from-file=alerting_config.yaml

替换alertmanager.yaml中的data,也就是保密字典中经过加密后的数据 

参考文档:https://www.kubernetes.org.cn/4438.html


