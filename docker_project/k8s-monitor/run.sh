#!/usr/bin/env bash
#定义报警的webhook
url=http://192.168.145.1:8080/WebHookTest/

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
  - url: '$url'
EOF

kubectl create  secret generic alertmanager-main --from-file=alerting_config.yaml

#将压缩过后的配置文件写入到alertmanager.yaml

baseCode=`cat alerting_config.yaml | base64`

cat >> alertmanager.yaml << EOF
apiVersion: v1
kind: ServiceAccount
metadata:
  name: alertmanager-main
  namespace: monitoring

---
apiVersion: v1
data:
  alertmanager.yaml: $baseCode
kind: Secret
metadata:
  name: alertmanager-main
  namespace: monitoring
type: Opaque

---
apiVersion: monitoring.coreos.com/v1
kind: Alertmanager
metadata:
  labels:
    alertmanager: main
  name: main
  namespace: monitoring
spec:
  baseImage: quay.io/prometheus/alertmanager
  nodeSelector:
    beta.kubernetes.io/os: linux
  replicas: 3
  serviceAccountName: alertmanager-main
  version: v0.15.0

---
apiVersion: v1
kind: Service
metadata:
  labels:
    alertmanager: main
  name: alertmanager-main
  namespace: monitoring
spec:
  type: NodePort
  ports:
  - name: web
    port: 9093
    targetPort: web
  selector:
    alertmanager: main
    app: alertmanager

---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  labels:
    k8s-app: alertmanager
  name: alertmanager
  namespace: monitoring
spec:
  endpoints:
  - interval: 30s
    port: web
  selector:
    matchLabels:
      alertmanager: main
EOF
kubectl apply -f alertmanager.yaml

# 查看
kubectl get pods -n monitoring
kubectl get svc -n monitoring

# 查看 node port

kubectl get svc -n monitoring | grep alertmanager-main

