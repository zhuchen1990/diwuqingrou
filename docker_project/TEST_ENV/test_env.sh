#!/usr/bin/env bash
#实验环境7.0.0.187部署脚本
#使用脚本前需将provider.zip，StarTrek.war，StarTrekEMR.war放到服务器
#命令:sh -x test_env.sh
#root_dir=/home/neo/project
#使用前需要修改版本号
#项目目录
root_dir=/home/neo/project
version=4.0

unzip provider.zip  && tar -zcvf provider.tar.gz provider/
mv  provider.tar.gz $root_dir/pro/
mv StarTrek.war $root_dir/his/
mv StarTrekEMR.war $root_dir/emr/
docker stop pro emr his
docker rm  pro emr his

docker build -t chngenesis/pro:$version $root_dir/pro/
docker build -t chngenesis/his:$version $root_dir/his/
docker build -t chngenesis/emr:$version $root_dir/emr/
docker run -dit --name pro --restart=always --link=zookeeper  --link=oracle --link=mongodb chngenesis/pro:$version
sleep 120
docker run -dit -p 8080:8080 --name his --restart=always --link=zookeeper chngenesis/his:$version
docker run -dit -p 8082:8080 --name emr --restart=always --link=zookeeper chngenesis/emr:$version
rm -rf provider.zip  && rm -rf provider/