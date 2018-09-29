#!/usr/bin/env bash

sudo yum install -y yum-utils \
  device-mapper-persistent-data \
  lvm2

sudo yum-config-manager \
    --add-repo \
    https://download.docker.com/linux/centos/docker-ce.repo

yum install  docker-ce-selinux-17.03.1.ce-1.el7.centos -y
