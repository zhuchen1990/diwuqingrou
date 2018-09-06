# k8s-monitor

本文章主要介绍如何全面监控k8s

部署prometheus-operator

创建 namespace

kubectl apply -f monitoring-namespace.yaml

kubectl apply -f prometheus-operator.yaml

部署k8s组件服务

kubectl apply -f node_exporter.yaml

部署kube-state-metrics

kubectl apply -f kube-state-metrics.yaml

部署prometheus

kubectl apply -f prometheus.yaml

配置数据收集

kubectl apply -f kube-servicemonitor.yaml

部署grafana

kubectl apply -f grafana.yaml

部署alertmanager

kubectl apply -f alertmanager.yaml

参考文档:https://www.kubernetes.org.cn/4438.html


