#!/usr/bin/env bash
root_dir=/root/project
#项目包版本
version=1.0
#zookeeper版本
zoo_version=1.0
#docker 仓库
repository=192.168.145.1:5000

#判断目录是否存在
if [ ! -d "$root_dir" ];then
mkdir /root/project
else
echo "工程根目录存在！"
fi
if [ ! -d "$root_dir/his" ];then
mkdir /root/project/his
else
echo "his根目录存在！"
fi
if [ ! -d "$root_dir/emr" ];then
mkdir /root/project/emr
else
echo "emr根目录存在！"
fi
if [ ! -d "$root_dir/pro" ];then
mkdir /root/project/pro
else
echo "pro根目录存在！"
fi
#复制包
cp centos-7-docker.tar.xz jdk-8u151-linux-x64.tar.gz provider.tar.gz  $root_dir/pro
cp centos-7-docker.tar.xz jdk-8u151-linux-x64.tar.gz apache-tomcat-8.5.23.tar.gz StarTrek.war $root_dir/his
cp centos-7-docker.tar.xz jdk-8u151-linux-x64.tar.gz apache-tomcat-8.5.23.tar.gz StarTrekEMR.war $root_dir/emr
#复制Dockerfile
cp Dockerfile_PRO /root/project/pro/Dockerfile
cp Dockerfile_EMR /root/project/emr/Dockerfile
cp Dockerfile_HIS /root/project/his/Dockerfile
sleep 1s
#构建镜像
docker build -t chngenesis/pro:$version /root/project/pro/
docker build -t chngenesis/his:$version /root/project/his/
docker build -t chngenesis/emr:$version /root/project/emr/

#运行在docker上,这里的zookeeper地址是zoo_$zoo_version
#docker run -dit --name pro --link=zoo_$zoo_version  chngenesis/pro:$version
#sleep 10s
#docker run -dit -p 8080:8080 --name his --link=zoo_$zoo_version chngenesis/his:$version
#docker run -dit -p 8082:8080 --name emr --link=zoo_$zoo_version chngenesis/emr:$version

#上传镜像到私有仓库
docker tag chngenesis/pro:$version $repository/chngenesis/pro:$version
docker tag chngenesis/his:$version $repository/chngenesis/his:$version
docker tag chngenesis/emr:$version $repository/chngenesis/emr:$version
#docker push $repository/chngenesis/pro:$version
#docker push $repository/chngenesis/his:$version
#docker push $repository/chngenesis/emr:$version

#运行在k8s上面,需要注意的是这里的zookeeper地址是集群,对照打包时的配置文件

#kubectl create -f  pro-deploy.yaml
#kubectl create -f  his-deploy.yaml
#kubectl create -f  emr-deploy.yaml

#升级



