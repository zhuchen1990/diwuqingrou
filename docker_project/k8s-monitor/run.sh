#!/usr/bin/env bash
#step 1 创建 namespace
kubectl apply -f monitoring-namespace.yaml
#step 2 部署 prometheus-operator
kubectl apply -f prometheus-operator.yaml
# 查看
kubectl get pods -n monitoring
kubectl get svc -n monitoring
kubectl get crd

#step 3 部署 k8s组件服务
kubectl apply -f node_exporter.yaml
# 查看
kubectl get pods -n monitoring
kubectl get svc -n monitoring

#step 4
kubectl apply -f kube-state-metrics.yaml
# 查看
kubectl get pods -n monitoring
kubectl get svc -n monitoring

#step 5 部署prometheus
kubectl apply -f prometheus.yaml
kubectl get pods -n monitoring
kubectl get svc -n monitoring

#step 6 配置数据收集
kubectl apply -f kube-servicemonitor.yaml
# 查看
kubectl get servicemonitors -n monitoring

# 查看 node port
kubectl get svc -n monitoring | grep prometheus-k8s

#step 7部署grafana
kubectl apply -f grafana.yaml

# 查看
kubectl get pods -n monitoring
kubectl get svc -n monitoring

# 查看 node port
kubectl get svc -n monitoring | grep grafana

#step 8 部署 alertmanager
#创建保密字典
cat > alerting_config.yaml << EOF
global:
  resolve_timeout: 5m
route:
  group_by: ['job']
  group_wait: 30s
  group_interval: 5m
  repeat_interval: 5m
  receiver: 'webhook'
receivers:
- name: 'webhook'
  webhook_configs:
  - url: 'http://192.168.145.1:8080/WebHookTest/'
EOF

kubectl create  secret generic alertmanager-main --from-file=alerting_config.yaml

cat alertmanager.yaml | base64

# 将加密后的数据添加到alertmanager.yaml
alert=$(cat alertmanager.yaml | base64)

sed  "s/alertmanager.yaml: /& `alert`/" alertmanager.yaml

kubectl apply -f alertmanager.yaml

# 查看
kubectl get pods -n monitoring
kubectl get svc -n monitoring

# 查看 node port

kubectl get svc -n monitoring | grep alertmanager-main

