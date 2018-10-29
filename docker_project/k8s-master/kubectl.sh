#!/usr/bin/env bash

rm -rf $HOME/.kube
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config

# 查看node节点
kubectl get nodes

#配置所有节点能够分配资源
kubectl taint nodes --all node-role.kubernetes.io/master-