#!/usr/bin/env bash
CP0_IP="192.168.145.154"
CP0_HOSTNAME="master1"
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
  advertiseAddress: $CP0_IP
  controlPlaneEndpoint: 192.168.145.200:8443

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
kubeadm config images pull --config kubeadm-master.config
kubeadm init --config kubeadm-master.config

cd /etc/kubernetes && tar cvzf k8s-key.tgz admin.conf pki/ca.* pki/sa.* pki/front-proxy-ca.* pki/etcd/ca.*
scp k8s-key.tgz 192.168.145.155:~/
scp k8s-key.tgz 192.168.145.156:~/
# ssh 192.168.145.155 'tar xf k8s-key.tgz -C /etc/kubernetes/'
# ssh 192.168.145.156 'tar xf k8s-key.tgz -C /etc/kubernetes/'
