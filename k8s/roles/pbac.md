```
创建一个只能访问某个 namespace 的用户


# openssl genrsa -out tgops.key 2048

openssl req -new -key tgops.key -out tgops.csr

# openssl x509 -req -in tgops.csr -CA /etc/kubernetes/pki/ca.crt -CAkey /etc/kubernetes/pki/ca.key -CAcreateserial -out tgops.crt -days 500
Signature ok
subject=/C=CN/ST=GD/L=NS/O=TG/OU=OPS/CN=tgops/emailAddress=tgops@tgops.cc
Getting CA Private Key


第1步：创建用户凭证

使用刚刚创建的证书文件和私钥文件在集群中创建新的凭证和上下文(Context):

# kubectl config set-credentials tgops --client-certificate=tgops.crt --client-key=tgops.key
User "tgops" set.

kubectl config view

- name: tgops
  user:
    client-certificate: /root/hyy-monitor/k8s/roles/tgops.crt
    client-key: /root/hyy-monitor/k8s/roles/tgops.key


然后为这个用户设置新的 Context:


# kubectl config set-context tgops-context --cluster=kubernetes --namespace=kube-system --user=tgops
Context "tgops-context" created.

- context:
    cluster: kubernetes
    namespace: kube-system
    user: tgops
  name: tgops-context

我们使用当前的这个配置文件来操作kubectl命令的时候，应该会出现错误，因为我们还没有为该用户定义任何操作的权限呢：

# kubectl get pods --context=tgops-context
Error from server (Forbidden): pods is forbidden: User "tgops" cannot list resource "pods" in API group "" in the namespace "kube-system"

第2步：创建角色

用户创建完成后，接下来就需要给该用户添加操作权限，我们来定义一个YAML文件，创建一个允许用户操作 Deployment、Pod、ReplicaSets 的角色

cat tgops-role.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tgops-role
  namespace: kube-system
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["deployments", "replicasets", "pods"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# kubectl create -f tgops-role.yaml
role.rbac.authorization.k8s.io/tgops-role created

[root@tg-ops-sz001 roles]# kubectl get role tgops-role -n kube-system -o yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  creationTimestamp: "2019-07-12T03:26:55Z"
  name: tgops-role
  namespace: kube-system
  resourceVersion: "1989751"
  selfLink: /apis/rbac.authorization.k8s.io/v1/namespaces/kube-system/roles/tgops-role
  uid: 36ed5822-b003-41af-b8f1-e730e5073321
rules:
- apiGroups:
  - ""
  - extensions
  - apps
  resources:
  - deployments
  - replicasets
  - pods
  verbs:
  - get
  - list
  - watch
  - create
  - update
  - patch
  - delete

  第3步：创建角色权限绑定

  Role 创建完成了，但是很明显现在我们这个 Role 和我们的用户 tgops 还没有任何关系，这里我就需要创建一个RoleBinding对象，在 kube-system 这个命名空间下面将上面的 tgops-role 角色和用户 tgops 进行绑定

  cat tgops-rolebinding.yaml

  apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tgops-rolebinding
  namespace: kube-system
subjects:
- kind: User
  name: tgops
  apiGroup: ""
roleRef:
  kind: Role
  name: tgops-role
  apiGroup: ""

 # kubectl create -f tgops-rolebinding.yaml
rolebinding.rbac.authorization.k8s.io/tgops-rolebinding created

第4步. 测试

上面报错地方，现在验证正常了。

# kubectl get pods --context=tgops-context
NAME                                             READY   STATUS    RESTARTS   AGE
coredns-5c98db65d4-2kf9q                         1/1     Running   0          15d
coredns-5c98db65d4-zjvv6                         1/1     Running   0          15d
etcd-tg-ops-sz001.tgops.com                      1/1     Running   0          15d


可以看到我们使用kubectl的使用并没有指定 namespace 了，这是因为我们已经为该用户分配了权限了，


# kubectl get pods --context=tgops-context -n development    # 如果使用-n 指定 namespace，报错，因为该用户没有development namespace 权限
Error from server (Forbidden): pods is forbidden: User "tgops" cannot list resource "pods" in API group "" in the namespace "development"

创建一个只能访问某个 namespace 的ServiceAccount

创建一个集群内部的用户只能操作 kube-system 这个命名空间下面的 pods 和 deployments

# kubectl create sa tgops-sa -n kube-system
serviceaccount/tgops-sa created

sa:  ServiceAccount

# kubectl get sa tgops-sa -n kube-system
NAME       SECRETS   AGE
tgops-sa   1         58s


然后新建一个 Role 对象：

这里定义的角色没有创建、删除、更新 Pod 的权限

cat tgops-sa-role.yaml

apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: tgops-sa-role
  namespace: kube-system
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "watch", "list"]
- apiGroups: ["apps"]
  resources: ["deployments"]
  verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]

# kubectl create -f tgops-sa-role.yaml
role.rbac.authorization.k8s.io/tgops-sa-role created

然后创建一个 RoleBinding 对象，将上面的 tgops-sa 和角色 tgops-sa-role 进行绑定：

cat tgops-sa-rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: tgops-sa-rolebinding
  namespace: kube-system
subjects:
- kind: ServiceAccount
  name: tgops-sa
  namespace: kube-system
roleRef:
  kind: Role
  name: tgops-sa-role
  apiGroup: rbac.authorization.k8s.io

# kubectl create -f tgops-sa-rolebinding.yaml
rolebinding.rbac.authorization.k8s.io/tgops-sa-rolebinding created

验证ServiceAccount

前面的课程中是不是提到过一个 ServiceAccount 会生成一个 Secret 对象和它进行映射，这个 Secret 里面包含一个 token，我们可以利用这个 token 去登录 Dashboard，然后我们就可以在 Dashboard 中来验证我们的功能是否符合预期了：


# kubectl get secret tgops-sa-token-dn7nm -n kube-system
NAME                   TYPE                                  DATA   AGE
tgops-sa-token-dn7nm   kubernetes.io/service-account-token   3      9m17s
[root@tg-ops-sz001 roles]# kubectl describe secret tgops-sa-token-dn7nm -n kube-system
Name:         tgops-sa-token-dn7nm
Namespace:    kube-system
Labels:       <none>
Annotations:  kubernetes.io/service-account.name: tgops-sa
              kubernetes.io/service-account.uid: c5f3d28e-ba73-41f1-a840-1b58b7804694

Type:  kubernetes.io/service-account-token

Data
====
namespace:  11 bytes
token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlLXN5c3RlbSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJ0Z29wcy1zYS10b2tlbi1kbjdubSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJ0Z29wcy1zYSIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImM1ZjNkMjhlLWJhNzMtNDFmMS1hODQwLTFiNThiNzgwNDY5NCIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlLXN5c3RlbTp0Z29wcy1zYSJ9.Bk6gLxKXYsUDSSo5hu1fFKVW_Ykv0T7daBAhLtrjYBJpZ5_3kppkq47cBkkPpBrLuIp4OMdv37CFOFDRyq5g_kt9KFMCyeNjmKNelC36-7lVQXfUCCy7yLDFgUCRkxiaK6RhGmSTDOwRvVpoNG1r8pPuNi81puUIgALdl1___icbYmjBvxFABTjqi51hj2hd4F_ZLdJZummyjcbJARh_6alXrSg3E3iZBLIXg5aYpzkbRo4CQ9GwmsEknuY4wY1x2K0TabHxxiadgXLx1ErQyPmdQ_KuSXiFFdgtW_CkhYvBgn0Di8dnOcJKpCaok97TopMA2x6W5jdHXys_QcboSA

创建一个可以访问所有 namespace 的ServiceAccount


cat tgops-sa-all.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tgops-sa-all
  namespace: kube-system

kubectl create -f tgops-sa-all.yaml
serviceaccount/tgops-sa-all created

创建一个 ClusterRoleBinding 对象

cat tgops-clusterrolebinding.yaml
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1beta1
metadata:
  name: tgops-sa-all-clusterrolebinding
subjects:
- kind: ServiceAccount
  name: tgops-sa-all
  namespace: kube-system
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io

 kubectl create -f tgops-clusterrolebinding.yaml
clusterrolebinding.rbac.authorization.k8s.io/tgops-sa-all-clusterrolebinding created
```
