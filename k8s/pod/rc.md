rc-demo.yaml
apiVersion: v1
kind: ReplicationController
metadata:
  name: rc-demo
  labels:
    name: rc
spec:
  replicas: 3
  selector:
    name: rc
  template:
    metadata:
      labels:
        name: rc
    spec:
      containers:
      - name: nginx-demo
        image: nginx
        ports:
        - containerPort: 80

kubectl create -f rc-demo.yaml
replicationcontroller/rc-demo created

# kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE     IP            NODE                     NOMINATED NODE   READINESS GATES
rc-demo-2q24g                       1/1     Running   0          2m16s   10.244.2.30   tg-ops-sz003.tgops.com   <none>           <none>
rc-demo-m8txd                       1/1     Running   0          6s      10.244.2.31   tg-ops-sz003.tgops.com   <none>           <none>
rc-demo-pcq6w                       1/1     Running   0          2m16s   10.244.1.30   tg-ops-sz002.tgops.com   <none>           <none>

# kubectl delete pod rc-demo-ttl7t
pod "rc-demo-ttl7t" deleted

# kubectl get pods -o wide
NAME                                READY   STATUS    RESTARTS   AGE     IP            NODE                     NOMINATED NODE   READINESS GATES
rc-demo-2q24g                       1/1     Running   0          4m22s   10.244.2.30   tg-ops-sz003.tgops.com   <none>           <none>
rc-demo-5jprt                       1/1     Running   0          11s     10.244.1.32   tg-ops-sz002.tgops.com   <none>           <none>
rc-demo-m8txd                       1/1     Running   0          2m12s   10.244.2.31   tg-ops-sz003.tgops.com   <none>           <none>

根据AGE最新事件可以看出来，已经生成一个最新的容器

通过RC来修改下Pod的副本数量为2：
vim rc-demo.yaml

kubectl apply -f rc-demo.yaml

或者 

kubectl edit rc rc-demo

kubectl get rc rc-demo
NAME      DESIRED   CURRENT   READY   AGE
rc-demo   2         2         2       9m5s



