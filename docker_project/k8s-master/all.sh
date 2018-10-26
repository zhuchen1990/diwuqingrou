#!/usr/bin/env bash
####################################
#主机ip
master1=192.168.145.154
master2=192.168.145.155
master3=192.168.145.156
#虚拟ip
vip=192.168.145.200
#主机名
lab1=master1
lab2=master2
lab3=master3
#网卡
interface=ens32
###################################


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

#配置haproxy代理和keepalived
#如下操作在节点lab1,lab2,lab3操作

# 拉取haproxy镜像

sleep 3
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
sleep 3
# 查看日志
#docker logs my-haproxy

# 浏览器查看状态
#http://$master1:1080/haproxy-status
#http://$master2:1080/haproxy-status

# 拉取keepalived镜像

sleep 3
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

# 查看日志
# 会看到两个成为backup 一个成为master
#docker logs k8s-keepalived

# 此时会配置 $vip 到其中一台机器
# ping测试
#ping -c4 $vip
# 如果失败后清理后，重新实验
#docker rm -f k8s-keepalived
#ip a del $vip/32 dev eth1

# 配置kubelet使用国内pause镜像
# 配置kubelet的cgroups
# 获取docker的cgroups
DOCKER_CGROUPS=$(docker info | grep 'Cgroup' | cut -d' ' -f3)
echo $DOCKER_CGROUPS
cat >/etc/sysconfig/kubelet<<EOF
KUBELET_EXTRA_ARGS="--cgroup-driver=$DOCKER_CGROUPS --pod-infra-container-image=registry.cn-hangzhou.aliyuncs.com/google_containers/pause-amd64:3.1"
EOF

# 启动
systemctl daemon-reload
systemctl enable kubelet && systemctl restart kubelet
