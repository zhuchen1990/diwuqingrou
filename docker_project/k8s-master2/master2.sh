#!/usr/bin/env bash
# 生成配置文件
CP0_IP="192.168.145.154"
CP0_HOSTNAME="master1"
CP1_IP="192.168.145.155"
CP1_HOSTNAME="master2"
cat >kubeadm-master.config<<EOF
apiVersion: kubeadm.k8s.io/v1alpha2
kind: MasterConfiguration
kubernetesVersion: v1.12.0
imageRepository: registry.cn-hangzhou.aliyuncs.com/google_containers

apiServerCertSANs:
- "master1"
- "master2"
- "master3"
- "192.168.145.154" 
- "192.168.145.155"
- "192.168.145.156"
- "192.168.145.200"
- "127.0.0.1"

api:
  advertiseAddress: $CP1_IP
  controlPlaneEndpoint: 192.168.145.200:8443

etcd:
  local:
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379,https://$CP1_IP:2379"
      advertise-client-urls: "https://$CP1_IP:2379"
      listen-peer-urls: "https://$CP1_IP:2380"
      initial-advertise-peer-urls: "https://$CP1_IP:2380"
      initial-cluster: "$CP0_HOSTNAME=https://$CP0_IP:2380,$CP1_HOSTNAME=https://$CP1_IP:2380"
      initial-cluster-state: existing
    serverCertSANs:
      - $CP1_HOSTNAME
      - $CP1_IP
    peerCertSANs:
      - $CP1_HOSTNAME
      - $CP1_IP

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

KUBECONFIG=/etc/kubernetes/admin.conf kubectl exec -n kube-system etcd-${CP0_HOSTNAME} -- etcdctl --ca-file /etc/kubernetes/pki/etcd/ca.crt --cert-file /etc/kubernetes/pki/etcd/peer.crt --key-file /etc/kubernetes/pki/etcd/peer.key --endpoints=https://${CP0_IP}:2379 member add ${CP1_HOSTNAME} https://${CP1_IP}:2380
kubeadm alpha phase etcd local --config kubeadm-master.config

# 提前拉取镜像
# 如果执行失败 可以多次执行
kubeadm config images pull --config kubeadm-master.config

# 部署
kubeadm alpha phase kubeconfig all --config kubeadm-master.config
kubeadm alpha phase controlplane all --config kubeadm-master.config
kubeadm alpha phase mark-master --config kubeadm-master.config