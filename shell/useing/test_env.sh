#!/usr/bin/env bash
unzip provider.zip  && tar -zcvf provider.tar.gz provider/
mv  provider.tar.gz /home/neo/project/pro/
mv StarTrek.war /home/neo/project/his/
mv StarTrekEMR.war /home/neo/project/emr/
docker stop pro emr his
docker rm  pro emr his
docker rmi chngenesis/pro:1.0
docker rmi chngenesis/his:1.0
docker rmi chngenesis/emr:1.0
docker build -t chngenesis/pro:1.0 /home/neo/project/pro/
docker build -t chngenesis/his:1.0 /home/neo/project/his/
docker build -t chngenesis/emr:1.0 /home/neo/project/emr/

docker run -dit --name pro --restart=always --link=zookeeper  --link=oracle --link=mongodb chngenesis/pro:1.0
docker run -dit -p 8080:8080 --name his --restart=always --link=zookeeper chngenesis/his:1.0
docker run -dit -p 8082:8080 --name emr --restart=always --link=zookeeper chngenesis/emr:1.0