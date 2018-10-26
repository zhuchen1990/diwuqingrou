#!/usr/bin/env bash
#实验环境7.0.0.187部署脚本
#使用脚本前需将provider.zip，StarTrek.war，StarTrekEMR.war放到服务器
#命令:sh -x test_env.sh
root_dir=/home/neo/project   
unzip provider.zip  && tar -zcvf provider.tar.gz provider/
mv  provider.tar.gz $root_dir/pro/
mv StarTrek.war $root_dir/his/
mv StarTrekEMR.war $root_dir/emr/
docker stop pro emr his
docker rm  pro emr his
docker rmi chngenesis/pro:1.0
docker rmi chngenesis/his:1.0
docker rmi chngenesis/emr:1.0
docker build -t chngenesis/pro:1.0 $root_dir/pro/
docker build -t chngenesis/his:1.0 $root_dir/his/
docker build -t chngenesis/emr:1.0 $root_dir/emr/
docker run -dit --name pro --restart=always --link=zookeeper  --link=oracle --link=mongodb chngenesis/pro:1.0
docker run -dit -p 8080:8080 --name his --restart=always --link=zookeeper chngenesis/his:1.0
docker run -dit -p 8082:8080 --name emr --restart=always --link=zookeeper chngenesis/emr:1.0
rm -rf provider.zip  && rm -rf provider/