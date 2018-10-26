#!/usr/bin/env bash

#Turn off the firewall
systemctl stop firewalld && systemctl disable firewalld

######################
#install docker
#Install required packages. yum-utils provides the yum-config-manager utility,
#and device-mapper-persistent-data and lvm2 are required by the devicemapper storage driver.
sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2
#Use the following command to set up the stable repository. You always need the stable repository,
#even if you want to install builds from the edge or test repositories as well.
sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo
#To install a specific version of Docker CE, list the available versions in the repo, then select and install:
#a. List and sort the versions available in your repo. This example sorts results by version number, highest to lowest,
#and is truncated:
yum list docker-ce --showduplicates | sort -r
#Install the latest version of Docker CE, or go to the next step to install a specific version
yum install  docker-ce -y 

#启动docker
systemctl enable docker && systemctl restart docker 
systemctl status docker
sleep 3
#拉取镜像
docker pull osixia/keepalived:1.4.4
docker pull haproxy:1.7.8-alpine
#install kubeadm,kubelet,kubectl
# 配置源
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

# 安装
yum install -y kubelet kubeadm kubectl ipvsadm

sleep 3