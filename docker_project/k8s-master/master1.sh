#!/usr/bin/env bash
#配置master
#配置第一个master节点
#如下操作在lab1节点操作
####################################
#主机ip
master1=192.168.145.145
master2=192.168.145.146
master3=192.168.145.147
#虚拟ip
vip=192.168.145.148
#主机名
lab1=`ssh $master1 hostname`
lab2=`ssh $master2 hostname`
lab3=`ssh $master3 hostname`
#网卡
interface=ens32
###################################
# 生成配置文件
CP0_IP="$master1"
CP0_HOSTNAME="$lab1"
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
- "$master1"
- "$master1"
- "$vip"
- "127.0.0.1"

api:
  advertiseAddress: $CP0_IP
  controlPlaneEndpoint: $vip:8443

etcd:
  local:
    extraArgs:
      listen-client-urls: "https://127.0.0.1:2379,https://$CP0_IP:2379"
      advertise-client-urls: "https://$CP0_IP:2379"
      listen-peer-urls: "https://$CP0_IP:2380"
      initial-advertise-peer-urls: "https://$CP0_IP:2380"
      initial-cluster: "$CP0_HOSTNAME=https://$CP0_IP:2380"
    serverCertSANs:
      - $CP0_HOSTNAME
      - $CP0_IP
    peerCertSANs:
      - $CP0_HOSTNAME
      - $CP0_IP

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

# 提前拉取镜像
# 如果执行失败 可以多次执行
kubeadm config images pull --config kubeadm-master.config

# 初始化
# 注意保存返回的 join 命令
kubeadm init --config kubeadm-master.config

# 打包ca相关文件上传至其他master节点
cd /etc/kubernetes && tar cvzf k8s-key.tgz admin.conf pki/ca.* pki/sa.* pki/front-proxy-ca.* pki/etcd/ca.*
scp k8s-key.tgz $lab2:~/
scp k8s-key.tgz $lab3:~/
ssh $lab2 'tar xf k8s-key.tgz -C /etc/kubernetes/'
ssh $lab3 'tar xf k8s-key.tgz -C /etc/kubernetes/'
