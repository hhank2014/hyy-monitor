# Kubernetes 运维指南

## Kubernetes 集群管理指南

### Node的管理

Node 的隔离与恢复

在硬件升级、硬件维护等情况下，我们需要将某些 Node 进行隔离，脱离 Kubemetes 集群的调度范围。

通过yaml文件来完成

创建配置文件 unschedule_node.yaml

执行命令来实现

command: kubectl patch "true of false"

# kubectl patch node tg-ops-sz003.tgops.com -p '{"spec": {"unschedulable": true}}'
node/tg-ops-sz003.tgops.com patched
[root@tg-ops-sz001 opsmanager]# kubectl get nodes
NAME                     STATUS                     ROLES    AGE   VERSION
tg-ops-sz001.tgops.com   Ready                      master   9d    v1.15.0
tg-ops-sz002.tgops.com   Ready                      <none>   9d    v1.15.0
tg-ops-sz003.tgops.com   Ready,SchedulingDisabled   <none>   9d    v1.15.0

# kubectl patch node tg-ops-sz003.tgops.com -p '{"spec": {"unschedulable": false}}'
node/tg-ops-sz003.tgops.com patched
[root@tg-ops-sz001 opsmanager]# kubectl get nodes
NAME                     STATUS   ROLES    AGE   VERSION
tg-ops-sz001.tgops.com   Ready    master   9d    v1.15.0
tg-ops-sz002.tgops.com   Ready    <none>   9d    v1.15.0
tg-ops-sz003.tgops.com   Ready    <none>   9d    v1.15.0

需要注意的是 ，将某个 Node 脱离调度范围时，在其上运行的 Pod 并不会自动停止， 管理
员需要手动停止在该 Node 上运行 的 Pod。
同样，如果需要将某个 Node重新纳入集群调度范围，则将 unschedulable设置为 false，再
次执行 kubectl replace或 kubectlpatch命令就能恢复系统对该 Node 的调度。

 当前的版本中， kubectl 的子命令 cordon 和 uncordon 也用 于实现将 Node 进行
隔离和恢复调度的操作。

[root@tg-ops-sz001 opsmanager]# kubectl get nodes
NAME                     STATUS   ROLES    AGE   VERSION
tg-ops-sz001.tgops.com   Ready    master   9d    v1.15.0
tg-ops-sz002.tgops.com   Ready    <none>   9d    v1.15.0
tg-ops-sz003.tgops.com   Ready    <none>   9d    v1.15.0
[root@tg-ops-sz001 opsmanager]# kubectl cordon tg-ops-sz003.tgops.com
node/tg-ops-sz003.tgops.com cordoned
[root@tg-ops-sz001 opsmanager]# kubectl get nodes
NAME                     STATUS                     ROLES    AGE   VERSION
tg-ops-sz001.tgops.com   Ready                      master   9d    v1.15.0
tg-ops-sz002.tgops.com   Ready                      <none>   9d    v1.15.0
tg-ops-sz003.tgops.com   Ready,SchedulingDisabled   <none>   9d    v1.15.0

更新资源对象的 Label

kubectl get node --show-labels

新增：

# kubectl label pod pod-demo name=pod-demo
pod/pod-demo labeled
# kubectl get pods --show-labels
NAME                            READY   STATUS    RESTARTS   AGE     LABELS
pod-demo                        2/2     Running   190        7d22h   app=myapp,name=pod-demo,tier=frontend

删除：

kubectl label pod pod-demo name-  #删除一个 Label 时，只需在命令行最后指定 Label 的 key名并与一个减号相连即可

# kubectl get pods --show-labels
ME                            READY   STATUS    RESTARTS   AGE     LABELS
pod-demo                        2/2     Running   190        7d22h   app=myapp,tier=frontend

修改

# kubectl label pod pod-demo app=myapp01 --overwrite
pod/pod-demo labeled
# kubectl get pod pod-demo --show-labels
NAME       READY   STATUS    RESTARTS   AGE     LABELS
pod-demo   2/2     Running   190        7d22h   app=myapp01,tier=frontend


Namespace :集群环境共享与隔离

在一个组织内部， 不同的工作组可以在同一个 Kubemetes 集群中工作， Kubemetes 通过命 名空间和 Context 的设置来对不同的工作组进行区分，使得它们既可以共享同一个 Kubemetes 集群的服务，也能够互不干扰 

ot@tg-ops-sz001 opsmanager]# cat namespace-dev.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
[root@tg-ops-sz001 opsmanager]# cat namespace-prod.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: production

# kubectl create -f namespace-dev.yaml
namespace/development created
# kubectl create -f namespace-prod.yaml
namespace/production created

# kubectl get namespace
NAME              STATUS   AGE
default           Active   9d
development       Active   10s
production        Active   7s

ontext (运行环境)

接下来 ， 需要为这两个工作组分别定义一个 Context，即运行环境。这个运行环境将属于某个特定 的命名空间。

# kubectl config set-context ctx-dev --namespace=development --cluster=kubernetes-cluster --user=dev
Context "ctx-dev" modified.

# kubectl config set-context ctx-prod --namespace=production --cluster=kubernetes-cluster --user=pord
Context "ctx-prod" modified.

# kubectl config view
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: DATA+OMITTED
    server: https://172.31.217.45:6443
  name: kubernetes
contexts:
- context:
    cluster: kubernetes-cluster
    namespace: development
    user: dev
  name: ctx-dev
- context:
    cluster: kubernetes-cluster
    namespace: production
    user: pord
  name: ctx-prod

cat /root/.kube/config   配置文件也生成到该目录文件

设置工何组在特定 Context环境申工悻


