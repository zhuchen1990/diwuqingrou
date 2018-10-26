#!/usr/bin/env bash
#部署oracle
docker run -dit -p 8081:8080 -p 1521:1521 -v /oracle/data:/u01/app/oracle \
-e processes=1000 \
-e sessions=1105 \
-e transactions=1215 \
--restart=always \
--name=oracle \
sath89/oracle-xe-11g
#部署mongodb
docker run -dit  -p 27017:27017 --name mongodb --restart=always  mongo
#部署zookeeper
docker run -dit -p 2181:2181 --name zookeeper --restart always  zookeeper