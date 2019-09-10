```
Kubernetes 亲和性调度

亲和性有分成节点亲和性(nodeAffinity)和 Pod 亲和性(podAffinity),节点亲和性(nodeAffinity)

nodeSelector

用户可以非常灵活的利用 label 来管理集群中的资源，比如最常见的一个就是 service 通过匹配 label 去匹配 Pod 资源，而 Pod 的调度也可以根据节点的 label 来进行调度。

# kubectl get nodes --show-labels
NAME                     STATUS   ROLES    AGE   VERSION   LABELS
tg-ops-sz001.tgops.com   Ready    master   32d   v1.15.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=tg-ops-sz001.tgops.com,kubernetes.io/os=linux,node-role.kubernetes.io/master=
tg-ops-sz002.tgops.com   Ready    <none>   32d   v1.15.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=tg-ops-sz002.tgops.com,kubernetes.io/os=linux
tg-ops-sz003.tgops.com   Ready    <none>   32d   v1.15.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=tg-ops-sz003.tgops.com,kubernetes.io/os=linux

添加一个labels

# kubectl label nodes tg-ops-sz003.tgops.com hello=world
node/tg-ops-sz003.tgops.com labeled

# kubectl get nodes --show-labels
NAME                     STATUS   ROLES    AGE   VERSION   LABELS
tg-ops-sz001.tgops.com   Ready    master   32d   v1.15.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=tg-ops-sz001.tgops.com,kubernetes.io/os=linux,node-role.kubernetes.io/master=
tg-ops-sz002.tgops.com   Ready    <none>   32d   v1.15.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,kubernetes.io/arch=amd64,kubernetes.io/hostname=tg-ops-sz002.tgops.com,kubernetes.io/os=linux
tg-ops-sz003.tgops.com   Ready    <none>   32d   v1.15.0   beta.kubernetes.io/arch=amd64,beta.kubernetes.io/os=linux,hello=world,kubernetes.io/arch=amd64,kubernetes.io/hostname=tg-ops-sz003.tgops.com,kubernetes.io/os=linux

只需要在 Pod 的spec字段中添加nodeSelector字段，里面是我们需要被调度的节点的 label 即可

apiVersion: v1
kind: Pod
metadata:
  name: test-busybox-pod
spec:
  containers:
  - command:
    - sleep
    - "3600"
    image: busybox
    imagePullPolicy: Always
    name: test-busybox-pod
  nodeSelector:
    hello: world

# kubectl describe pod test-busybox-pod

Events:
  Type    Reason     Age   From                             Message
  ----    ------     ----  ----                             -------
  Normal  Scheduled  55s   default-scheduler                Successfully assigned default/test-busybox-pod to tg-ops-sz003.tgops.com


节点亲和性(nodeAffinity)

亲和性调度可以分成软策略和硬策略两种方式:

软策略就是如果你没有满足调度要求的节点的话，pod 就会忽略这条规则，继续完成调度过程，说白了就是满足条件最好了，没有的话也无所谓了的策略
硬策略就比较强硬了，如果没有满足条件的节点的话，就不断重试直到满足条件为止，简单说就是你必须满足我的要求，不然我就不干的策略。

对于亲和性和反亲和性都有这两种规则可以设置： preferredDuringSchedulingIgnoredDuringExecution和requiredDuringSchedulingIgnoredDuringExecution，前面的就是软策略，后面的就是硬策略。


kubectl explain deploy.spec.template.spec.affinity.nodeAffinity.requiredDuringSchedulingIgnoredDuringExecution.nodeSelectorTerms.matchExpressions.operator

kubectl explain deploy.spec.template.spec.affinity.nodeAffinity.preferredDuringSchedulingIgnoredDuringExecution

apiVersion: apps/v1beta1
kind: Deployment
metadata:
  name: affinity
  labels:
    app: affinity
spec:
  replicas: 3
  revisionHistoryLimit: 15
  template:
    metadata:
      labels:
        app: affinity
        role: test
    spec:
      containers:
      - name: nginx
        image: nginx:1.7.9
        ports:
        - containerPort: 80
          name: nginxweb
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:  # 硬策略
            nodeSelectorTerms:
            - matchExpressions:
              - key: kubernetes.io/hostname
                operator: NotIn
                values:
                - node03
          preferredDuringSchedulingIgnoredDuringExecution:  # 软策略
          - weight: 1
            preference:
              matchExpressions:
              - key: com
                operator: In
                values:
                - youdianzhishi

$ kubectl create -f node-affinity-demo.yaml
deployment.apps "affinity" created
$ kubectl get pods -l app=affinity -o wide
NAME                        READY     STATUS    RESTARTS   AGE       IP             NODE
affinity-7b4c946854-5gfln   1/1       Running   0          47s       10.244.4.214   node02
affinity-7b4c946854-l8b47   1/1       Running   0          47s       10.244.4.215   node02
affinity-7b4c946854-r86p5   1/1       Running   0          47s       10.244.4.213   node02



podAffinity

pod 亲和性主要解决 pod 可以和哪些 pod 部署在同一个拓扑域中的问题（其中拓扑域用主机标签实现，可以是单个主机，也可以是多个主机组成的 cluster、zone 等等），而 pod 反亲和性主要是解决 pod 不能和哪些 pod 部署在同一个拓扑域中的问题，它们都是处理的 pod 与 pod 之间的关系，比如一个 pod 在一个节点上了，那么我这个也得在这个节点，或者你这个 pod 在节点上了，那么我就不想和你待在同一个节点上。

# kubectl get pod test-busybox-pod --show-labels
NAME                             READY   STATUS             RESTARTS   AGE     LABELS
test-busybox-pod                 1/1     Running            0          27m     <none>

# kubectl label pods test-busybox-pod hello=world

# kubectl get pod test-busybox-pod --show-labels
NAME               READY   STATUS    RESTARTS   AGE   LABELS
test-busybox-pod   1/1     Running   0          27m   hello=world

# cat podaffinity.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: test-nginx-podaffinity
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: affinity
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: nginxweb
      affinity:
        podAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: hello
                operator: In
                values:
                - world
            topologyKey: kubernetes.io/hostname

# kubectl get pods --show-labels -o wide
NAME                                     READY   STATUS             RESTARTS   AGE     IP            NODE                     NOMINATED NODE   READINESS GATES   LABELS
jenkins-demo-844db54d58-hpwmz            0/1     ImagePullBackOff   0          9m43s   10.244.2.91   tg-ops-sz003.tgops.com   <none>           <none>            app=jenkins-demo,pod-template-hash=844db54d58
load-generator-7d549cd44-jsdv4           1/1     Running            0          7m57s   10.244.2.92   tg-ops-sz003.tgops.com   <none>           <none>            pod-template-hash=7d549cd44,run=load-generator
test-busybox-pod                         1/1     Running            0          54s     10.244.2.93   tg-ops-sz003.tgops.com   <none>           <none>            hello=world
test-nginx-podaffinity-7c8dd4897-6xcxj   1/1     Running            0          21s     10.244.2.95   tg-ops-sz003.tgops.com   <none>           <none>            app=affinity,pod-template-hash=7c8dd4897
test-nginx-podaffinity-7c8dd4897-b76cc   1/1     Running            0          21s     10.244.2.96   tg-ops-sz003.tgops.com   <none>           <none>            app=affinity,pod-template-hash=7c8dd4897
test-nginx-podaffinity-7c8dd4897-s5qjx   1/1     Running            0          21s     10.244.2.94   tg-ops-sz003.tgops.com   <none>           <none>            app=affinity,pod-template-hash=7c8dd4897

而 pod 反亲和性则是反着来的，比如一个节点上运行了某个 pod，那么我们的 pod 则希望被调度到其他节点上去，同样我们把上面的 podAffinity 直接改成 podAntiAffinity

# cat podAntiAffinity.yaml
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: test-nginx-podaffinity
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: affinity
    spec:
      containers:
      - name: nginx
        image: nginx
        ports:
        - containerPort: 80
          name: nginxweb
      affinity:
        podAntiAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
          - labelSelector:
              matchExpressions:
              - key: hello
                operator: In
                values:
                - world
            topologyKey: kubernetes.io/hostname

# kubectl get pods  -o wide --show-labels
NAME                                      READY   STATUS             RESTARTS   AGE   IP            NODE                     NOMINATED NODE   READINESS GATES   LABELS
jenkins-demo-844db54d58-hpwmz             0/1     ImagePullBackOff   0          19m   10.244.2.91   tg-ops-sz003.tgops.com   <none>           <none>            app=jenkins-demo,pod-template-hash=844db54d58
load-generator-7d549cd44-jsdv4            1/1     Running            0          17m   10.244.2.92   tg-ops-sz003.tgops.com   <none>           <none>            pod-template-hash=7d549cd44,run=load-generator
test-busybox-pod                          1/1     Running            0          10m   10.244.2.93   tg-ops-sz003.tgops.com   <none>           <none>            hello=world
test-nginx-podaffinity-66cb8c8b87-k8c7v   1/1     Running            0          68s   10.244.1.93   tg-ops-sz002.tgops.com   <none>           <none>            app=affinity,pod-template-hash=66cb8c8b87
test-nginx-podaffinity-66cb8c8b87-n96d9   1/1     Running            0          55s   10.244.1.94   tg-ops-sz002.tgops.com   <none>           <none>            app=affinity,pod-template-hash=66cb8c8b87
test-nginx-podaffinity-66cb8c8b87-sv9zs   1/1     Running            0          68s   10.244.1.92   tg-ops-sz002.tgops.com   <none>           <none>            app=affinity,pod-template-hash=66cb8c8b87
```
