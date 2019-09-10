```
version: extensions/v1beta1
kind: Ingress
metadata:
spec：
  backend:
    serviceName:
    servicePort:
  rules:
  - host
    http
  tls:
    hosts
    secretName

1 创建service 和 deployment

apiVersion: v1
kind: Service
metadata:
  name: myapp
  namespace: default
spec:
  selector:
    app: myapp
    release: canary
  ports:
  - name: http
    targetPort: 80

---

apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: myapp-deploy
  namespace: default
spec:
  replicas: 2
  selector:
    matchLabels:
      app: myapp
      release: canary
  template:
    metadata:
      labels:
        app: myapp
        release: canary
    spec:
      containers:
      - name: myapp
        image: ikubernetes/myapp:v2
        ports:
        - name: http
          containerPort: 80



2 wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/mandatory.yaml


# kubectl apply -f mandatory.yaml
namespace/ingress-nginx created
configmap/nginx-configuration created
configmap/tcp-services created
configmap/udp-services created
serviceaccount/nginx-ingress-serviceaccount created
clusterrole.rbac.authorization.k8s.io/nginx-ingress-clusterrole created
role.rbac.authorization.k8s.io/nginx-ingress-role created
rolebinding.rbac.authorization.k8s.io/nginx-ingress-role-nisa-binding created
clusterrolebinding.rbac.authorization.k8s.io/nginx-ingress-clusterrole-nisa-binding created
deployment.apps/nginx-ingress-controller created

# kubectl get pod -n ingress-nginx
NAME                                        READY   STATUS    RESTARTS   AGE
nginx-ingress-controller-7995bd9c47-j9nzx   1/1     Running   0          3m42s

# kubectl get cm -n ingress-nginx
NAME                              DATA   AGE
ingress-controller-leader-nginx   0      3m35s
nginx-configuration               0      4m7s
tcp-services                      0      4m7s
udp-services                      0      4m7s

# kubectl get role -n ingress-nginx
NAME                 AGE
nginx-ingress-role   4m26s

# kubectl get sa -n ingress-nginx
NAME                           SECRETS   AGE
default                        1         4m43s
nginx-ingress-serviceaccount   1         4m43s

3 wget https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/static/provider/baremetal/service-nodeport.yaml

# kubectl apply -f service-nodeport.yaml
service/ingress-nginx created

# kubectl get svc -n ingress-nginx
NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx   NodePort   10.101.62.39   <none>        80:31763/TCP,443:31947/TCP   5s


4 定义ingress


# cat ingress-myapp.yaml
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: ingress-myapp
  namespace: default
  annotations:
    kubernetes.io/ingress.class: "nginx"
spec:
  rules:
  - host: test.tgops.cc
    http:
      paths:
      - path:
        backend:
          serviceName: myapp
          servicePort: 80


# kubectl apply -f ingress-myapp.yaml
ingress.extensions/ingress-myapp created
[root@tg-ops-sz001 ingress-nginx]# kubectl get ingress
NAME            HOSTS           ADDRESS   PORTS   AGE
ingress-myapp   test.tgops.cc             80      7s



5 https:

通过acme.sh dns 方式制作证书
kubectl create secret tls demo-tls-ingress-secret --cert=tgops.cc.pem --key=tgops.cc.key

ingress 新增tls配置

  tls:
  - hosts:
    - test.tgops.cc
    secretName: demo-tls-ingress-secret

kubectl apply -f ingress-myapp.yaml


# kubectl get svc -n ingress-nginx
NAME            TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)                      AGE
ingress-nginx   NodePort   10.101.62.39   <none>        80:31763/TCP,443:31947/TCP   136m

https://test.tgops.cc:31947/  即可
```
