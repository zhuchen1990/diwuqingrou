#!/usr/bin/env bash
cat >>/etc/hosts<<EOF
192.168.145.154  master1
192.168.145.155  master2
192.168.145.156  master3
EOF
systemctl stop firewalld && systemctl disable firewalld
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
yum install  docker-ce -y 
systemctl enable docker && systemctl restart docker 
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF
yum install -y kubelet kubeadm kubectl ipvsadm
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0
swapoff -a
sed -i 's/\/dev\/mapper\/centos-swap/\#\/dev\/mapper\/centos-swap/' /etc/fstab
iptables -P FORWARD ACCEPT
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF
sysctl --system
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack_ipv4
lsmod | grep ip_vs
docker pull haproxy:1.7.8-alpine
mkdir /etc/haproxy
cat >/etc/haproxy/haproxy.cfg<<EOF
global
  log 127.0.0.1 local0 err
  maxconn 50000
  uid 99
  gid 99
  #daemon
  nbproc 1
  pidfile haproxy.pid

defaults
  mode http
  log 127.0.0.1 local0 err
  maxconn 50000
  retries 3
  timeout connect 5s
  timeout client 30s
  timeout server 30s
  timeout check 2s

listen admin_stats
  mode http
  bind 0.0.0.0:1080
  log 127.0.0.1 local0 err
  stats refresh 30s
  stats uri     /haproxy-status
  stats realm   Haproxy\ Statistics
  stats auth    will:will
  stats hide-version
  stats admin if TRUE

frontend k8s-https
  bind 0.0.0.0:8443
  mode tcp
  #maxconn 50000
  default_backend k8s-https

backend k8s-https
  mode tcp
  balance roundrobin
  server master1 192.168.145.154:6443 weight 1 maxconn 1000 check inter 2000 rise 2 fall 3
  server master2 192.168.145.155:6443 weight 1 maxconn 1000 check inter 2000 rise 2 fall 3
  server master3 192.168.145.156:6443 weight 1 maxconn 1000 check inter 2000 rise 2 fall 3
EOF
docker run -d --name my-haproxy \
-v /etc/haproxy:/usr/local/etc/haproxy:ro \
-p 8443:8443 \
-p 1080:1080 \
--restart always \
haproxy:1.7.8-alpine
docker pull osixia/keepalived:1.4.4
lsmod | grep ip_vs
modprobe ip_vs
docker run --net=host --cap-add=NET_ADMIN \
-e KEEPALIVED_INTERFACE=ens32 \
-e KEEPALIVED_VIRTUAL_IPS="#PYTHON2BASH:['192.168.145.200']" \
-e KEEPALIVED_UNICAST_PEERS="#PYTHON2BASH:['192.168.145.154','192.168.145.155','192.168.145.156']" \
-e KEEPALIVED_PASSWORD=hello \
--name k8s-keepalived \
--restart always \
-d osixia/keepalived:1.4.4
DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f3)
echo $DOCKER_CGROUPS
cat >/etc/sysconfig/kubelet<<EOF
KUBELET_EXTRA_ARGS="--cgroup-driver=$DOCKER_CGROUPS --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.1"
EOF
systemctl daemon-reload
systemctl enable kubelet && systemctl restart kubelet
