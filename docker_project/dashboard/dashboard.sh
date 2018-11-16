#!/usr/bin/env bash
#应用dashboard文件
kubectl apply -f http://mirror.faasx.com/kubernetes/dashboard/master/src/deploy/recommended/kubernetes-dashboard.yaml

#首先创建一个叫admin-user的服务账号，并放在kube-system名称空间下
#默认情况下，kubeadm创建集群时已经创建了admin角色，我们直接绑定角色即可

cat >> admin-user.yaml <<EOF
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kube-system
EOF
#应用
kubectl create -f admin-user.yaml

#对于API Server来说，它是使用证书进行认证的，我们需要先创建一个证书

#首先找到kubectl命令的配置文件,默认情况下为/etc/kubernetes/admin.conf,我们已经复制到了$HOME/.kube/config中

# 生成client-certificate-data

grep 'client-certificate-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.crt

# 生成client-key-data

grep 'client-key-data' ~/.kube/config | head -n 1 | awk '{print $2}' | base64 -d >> kubecfg.key

# 生成p12

openssl pkcs12 -export -clcerts -inkey kubecfg.key -in kubecfg.crt -out kubecfg.p12 -name "kubernetes-client"

#接下来在浏览器中导入p12文件,登录即可,登录的时候需要token

echo "需要的token如下:"
#现在我们需要找到新创建的用户的Token，以便用来登录dashboard:
kubectl -n kube-system describe secret $(kubectl -n kube-system get secret | grep admin-user | awk '{print $1}')

echo "登录地址:"
echo "https://<ip>:6443/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/#!/login"




