#!/usr/bin/env bash
#sudo docker search mongo
#下载官方centos镜像：
sudo  docker pull docker.io/mongo


#下载完后可检查镜像：

sudo docker images


#主机上建立目录和日志文件：

mkdir -p /data/mongo
touch /data/mongo/mongodb.log
chmod 777 /data/mongo/mongodb.log
#因权限问题，给日志特意加上了所有权限



#主机上建立配置文件：

touch /data/mongo/mongodb.conf
vi  /data/mongo/mongodb.conf
#内容如下：
storage:
  dbPath: /data/db
  journal:
    enabled: true

systemLog:
  destination: file
  logAppend: true
  path: /data/mongodb.log

net:
  port: 27017
  bindIp: 127.0.0.1

processManagement:
  timeZoneInfo: /usr/share/zoneinfo



#启动容器：

sudo docker run -p 27017:27017 -v /data/mongo:/data -v /data/mongo/db:/data/db --name mongo -d docker.io/mongo --config /data/mongodb.conf
#因权限问题，我们特意把 -v /data/mongo/db:/data/db也加上



#检查启动情况：

sudo docker logs 容器id