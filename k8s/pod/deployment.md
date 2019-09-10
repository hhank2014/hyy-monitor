Deployment 特性

RC的全部功能：Deployment具备上面描述的RC的全部功能
事件和状态查看：可以查看Deployment的升级详细进度和状态
回滚：当升级Pod的时候如果出现问题，可以使用回滚操作回滚到之前的任一版本
版本记录：每一次对Deployment的操作，都能够保存下来，这也是保证可以回滚到任一版本的基础
暂停和启动：对于每一次升级都能够随时暂停和启动

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: deploy-nginx
  labels:
    app: deploy-demo
spec:
  replicas: 3
  template:
    metadata:
      labels:
        app: deploy-demo
    spec:
      containers:
      - name: deploy-nginx
        image: nginx:1.15
        ports:
        - containerPort: 80


# kubectl create -f deploy-demo.yaml
deployment.extensions/deploy-nginx created

# kubectl get deploy
NAME           READY   UP-TO-DATE   AVAILABLE   AGE
deploy-nginx   3/3     3            3           30s


kubectl get rs
NAME                      DESIRED   CURRENT   READY   AGE
deploy-nginx-7c8f7b74cd   3         3         3       87s

kubectl get pod --show-labels
NAME                            READY   STATUS    RESTARTS   AGE    LABELS
deploy-nginx-7c8f7b74cd-2k5m2   1/1     Running   0          2m5s   app=deploy-demo,pod-template-hash=7c8f7b74cd
deploy-nginx-7c8f7b74cd-bnz5v   1/1     Running   0          2m5s   app=deploy-demo,pod-template-hash=7c8f7b74cd
deploy-nginx-7c8f7b74cd-c7qc2   1/1     Running   0          2m5s   app=deploy-demo,pod-template-hash=7c8f7b74cd

滚动升级

kubectl apply -f deploy-demo.yaml
Warning: kubectl apply should be used on resource created by either kubectl create --save-config or kubectl apply
deployment.extensions/deploy-nginx configured

kubectl rollout status deployment/deploy-nginx
deployment "deploy-nginx" successfully rolled out

# kubectl get rs
NAME                      DESIRED   CURRENT   READY   AGE
deploy-nginx-66f96676c6   3         3         3       106s
deploy-nginx-7c8f7b74cd   0         0         0       13m

可以看出一个Deployment拥有多个Replica Set，而一个Replica Set拥有一个或多个Pod。一个Deployment控制多个rs主要是为了支持回滚机制，每当Deployment操作时，Kubernetes会重新生成一个Replica Set并保留，以后有需要的话就可以回滚至之前的状态。

kubectl describe deploy deploy-nginx

Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  14m    deployment-controller  Scaled up replica set deploy-nginx-7c8f7b74cd to 3
  Normal  ScalingReplicaSet  2m16s  deployment-controller  Scaled up replica set deploy-nginx-66f96676c6 to 1
  Normal  ScalingReplicaSet  2m16s  deployment-controller  Scaled down replica set deploy-nginx-7c8f7b74cd to 2
  Normal  ScalingReplicaSet  2m16s  deployment-controller  Scaled up replica set deploy-nginx-66f96676c6 to 2
  Normal  ScalingReplicaSet  2m6s   deployment-controller  Scaled down replica set deploy-nginx-7c8f7b74cd to 0
  Normal  ScalingReplicaSet  2m6s   deployment-controller  Scaled up replica set deploy-nginx-66f96676c6 to

kubectl exec -it deploy-nginx-66f96676c6-cmm9t -- /bin/bash
root@deploy-nginx-66f96676c6-cmm9t:/# nginx -v
nginx version: nginx/1.17.1

回滚Deployment

kubectl rollout history deploy/deploy-nginx
deployment.extensions/deploy-nginx
REVISION  CHANGE-CAUSE
1         <none>
2         <none>

[root@tg-ops-sz001 pod]# kubectl apply -f deploy-demo.yaml --record=true
deployment.extensions/deploy-nginx configured
[root@tg-ops-sz001 pod]# kubectl rollout history deploy/deploy-nginx
deployment.extensions/deploy-nginx
REVISION  CHANGE-CAUSE
2         <none>
3         <none>
4         kubectl apply --filename=deploy-demo.yaml --record=true


升级时最好加上 --record=true 这样可以保留记录，否则只有none

最好通过设置Deployment的.spec.revisionHistoryLimit来限制最大保留的revision numbe

查看升级版本信息

# kubectl rollout history deployment deploy-nginx --revision=3
deployment.extensions/deploy-nginx with revision #3
Pod Template:
  Labels:	app=deploy-demo
	pod-template-hash=577f545947
  Containers:
   deploy-nginx:
    Image:	nginx:1.16
    Port:	80/TCP
    Host Port:	0/TCP
    Environment:	<none>
    Mounts:	<none>
  Volumes:	<none>

回退到当前版本的前一个版本：

kubectl rollout undo deploy deploy-nginx
deployment.extensions/deploy-nginx rolledback

kubectl exec -it deploy-nginx-577f545947-x4zvs -- /bin/bash
root@deploy-nginx-577f545947-x4zvs:/# nginx -v
nginx version: nginx/1.16.0

用revision回退到指定的版本：

kubectl rollout undo deploy deploy-nginx --to-revision=4
deployment.extensions/deploy-nginx rolled back

kubectl rollout status deploy/deploy-nginx
deployment "deploy-nginx" successfully rolled out
