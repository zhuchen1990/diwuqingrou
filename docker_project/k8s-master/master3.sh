#!/usr/bin/env bash
#配置第三个master节点
#如下操作在lab3节点操作
####################################
#主机ip
master1=192.168.145.151
master2=192.168.145.152
master3=192.168.145.153
#虚拟ip
vip=192.168.145.154
#主机名
lab1=`ssh $master1 hostname`
lab2=`ssh $master2 hostname`
lab3=`ssh $master3 hostname`
#网卡
interface=ens33
###################################

# 生成配置文件
CP0_IP="$master1"
CP0_HOSTNAME="$lab1"
CP1_IP="$master2"
CP1_HOSTNAME="$lab2"
CP2_IP="$master3"
CP2_HOSTNAME="$lab3"

cat >kubeadm-master.config<<EOF
apiVersion: kubeadm.k8s.io/v1alpha2
kind: MasterConfiguration
kubernetesVersion: v1.12.0
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers

apiServerCertSANs:
- "$lab1"
- "$lab2"
- "$lab3"
- "$master1"
- "$master2"
- "$master3"
- "$vip"
- "127.0.0.1"

api:
  advertiseAddress: $CP2_IP
  controlPlaneEndpoint: $vip:8443

etcd:
  local:
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379,https://$CP2_IP:2379"
      advertise-client-urls: "https://$CP2_IP:2379"
      listen-peer-urls: "https://$CP2_IP:2380"
      initial-advertise-peer-urls: "https://$CP2_IP:2380"
      initial-cluster: "$CP0_HOSTNAME=https://$CP0_IP:2380,$CP1_HOSTNAME=https://$CP1_IP:2380,$CP2_HOSTNAME=https://$CP2_IP:2380"
      initial-cluster-state: existing
    serverCertSANs:
      - $CP2_HOSTNAME
      - $CP2_IP
    peerCertSANs:
      - $CP2_HOSTNAME
      - $CP2_IP

controllerManagerExtraArgs:
  node-monitor-grace-period: 10s
  pod-eviction-timeout: 10s

networking:
  podSubnet: 10.244.0.0/16

kubeProxy:
  config:
    # mode: ipvs
    mode: iptables
EOF

# 配置kubelet
kubeadm alpha phase certs all --config kubeadm-master.config
kubeadm alpha phase kubelet config write-to-disk --config kubeadm-master.config
kubeadm alpha phase kubelet write-env-file --config kubeadm-master.config
kubeadm alpha phase kubeconfig kubelet --config kubeadm-master.config
systemctl restart kubelet

# 添加etcd到集群中
CP0_IP="$master1"
CP0_HOSTNAME="$lab1"
CP2_IP="$master3"
CP2_HOSTNAME="$lab3"
KUBECONFIG=/etc/kubernetes/admin.conf kubectl exec -n kube-system etcd-${CP0_HOSTNAME} -- etcdctl --ca-file /etc/kubernetes/pki/etcd/ca.crt --cert-file /etc/kubernetes/pki/etcd/peer.crt --key-file /etc/kubernetes/pki/etcd/peer.key --endpoints=https://${CP0_IP}:2379 member add ${CP2_HOSTNAME} https://${CP2_IP}:2380
kubeadm alpha phase etcd local --config kubeadm-master.config

# 提前拉取镜像
# 如果执行失败 可以多次执行
kubeadm config images pull --config kubeadm-master.config

#部署
kubeadm alpha phase kubeconfig all --config kubeadm-master.config
kubeadm alpha phase controlplane all --config kubeadm-master.config
kubeadm alpha phase mark-master --config kubeadm-master.config
