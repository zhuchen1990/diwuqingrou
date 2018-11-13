#!/usr/bin/env bash
####################################
#主机ip
master1=7.0.0.60
master2=7.0.0.61
master3=7.0.0.62
#虚拟ip
vip=7.0.0.63
#主机名
lab1=node1
lab2=node2
lab3=node3
#网卡
interface=ens32
################################
#Turn off the firewall
systemctl stop firewalld && systemctl disable firewalld

#install docker and start docker
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum install  docker-ce-18.06.0.ce  -y

systemctl enable docker && systemctl restart docker

# 配置源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=http://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=0
repo_gpgcheck=0
gpgkey=http://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
        http://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF


# 安装kubelet kubeadm kubectl ipvsadm[1.11.2,1.11.3]
yum install -y kubelet-1.12.0 kubeadm-1.12.0 kubectl-1.12.0 ipvsadm

#配置系统相关参数
# 临时禁用selinux
# 永久关闭 修改/etc/selinux/config文件设置
sed -i 's/SELINUX=enforcing/SELINUX=disabled/' /etc/selinux/config
setenforce 0

# 临时关闭swap
# 永久关闭 注释/etc/fstab文件里swap相关的行
swapoff -a
sed -i 's/\/dev\/mapper\/centos-swap/\#\/dev\/mapper\/centos-swap/' /etc/fstab

# 开启forward
# Docker从1.13版本开始调整了默认的防火墙规则
# 禁用了iptables filter表中FOWARD链
# 这样会引起Kubernetes集群中跨Node的Pod无法通信

iptables -P FORWARD ACCEPT

# 配置转发相关参数，否则可能会出错
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF
sysctl --system

# 加载ipvs相关内核模块
# 如果重新开机，需要重新加载
modprobe ip_vs
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack_ipv4
lsmod | grep ip_vs

#Configure host
cat >>/etc/hosts<<EOF
$master1  $lab1
$master2  $lab2
$master3  $lab3
EOF

# 拉取haproxy镜像
docker pull haproxy:1.7.8-alpine

sleep 1
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
  server $lab1 $master1:6443 weight 1 maxconn 1000 check inter 2000 rise 2 fall 3
  server $lab2 $master2:6443 weight 1 maxconn 1000 check inter 2000 rise 2 fall 3
  server $lab3 $master3:6443 weight 1 maxconn 1000 check inter 2000 rise 2 fall 3
EOF

# 启动haproxy
docker run -d --name my-haproxy \
-v /etc/haproxy:/usr/local/etc/haproxy:ro \
-p 8443:8443 \
-p 1080:1080 \
--restart always \
haproxy:1.7.8-alpine
sleep 1


# 拉取keepalived镜像
docker pull osixia/keepalived:1.4.4
sleep 1
# 启动
# 载入内核相关模块
lsmod | grep ip_vs
modprobe ip_vs

# 启动keepalived
# $interface为网段的所在网卡
docker run --net=host --cap-add=NET_ADMIN \
-e KEEPALIVED_INTERFACE=$interface \
-e KEEPALIVED_VIRTUAL_IPS="#PYTHON2BASH:['$vip']" \
-e KEEPALIVED_UNICAST_PEERS="#PYTHON2BASH:['$master1','$master2','$master3']" \
-e KEEPALIVED_PASSWORD=hello \
--name k8s-keepalived \
--restart always \
-d osixia/keepalived:1.4.4

DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f3)


cat >/etc/sysconfig/kubelet<<EOF
KUBELET_EXTRA_ARGS="--cgroup-driver=$DOCKER_CGROUPS --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.1"
EOF

# 启动
systemctl daemon-reload

systemctl enable kubelet && systemctl restart kubelet
