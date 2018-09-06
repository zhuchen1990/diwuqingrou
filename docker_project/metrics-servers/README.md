# metrics-servers

使用metric-server收集数据给k8s集群内使用，如kubectl,hpa,scheduler等


kubectl create -f .

# 查看状态

kubectl get pods -n kube-system

测试获取数据

由于采集数据间隔为1分钟

等待数分钟后查看数据

NODE=$(kubectl get nodes | grep 'Ready' | head -1 | awk '{print $1}')

METRIC_SERVER_POD=$(kubectl get pods -n kube-system | grep 'metrics-server' | awk '{print $1}')

kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes

kubectl get --raw /apis/metrics.k8s.io/v1beta1/pods

kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes/$NODE


kubectl top node $NODE

kubectl top pod $METRIC_SERVER_POD -n kube-system

参考文档:https://www.kubernetes.org.cn/4438.html
