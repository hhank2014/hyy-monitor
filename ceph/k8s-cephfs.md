### k8s cephfs

怎么获取key，如下 ,这里需要转换，否则无法识别报错。

```
$ ceph auth get-key client.admin |base64
QVFDN28wZGRSaDVkRkJBQTVFMkJoSlVmWFJKNnNURzA4YU5UTUE9PQ==
```

```
apiVersion: v1
kind: Secret
metadata:
  name: ceph-pv-secret-admin
data:
  key: QVFDN28wZGRSaDVkRkJBQTVFMkJoSlVmWFJKNnNURzA4YU5UTUE9PQ==
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ceph-pv
  labels:
    app: ceph
spec:
  capacity:
    storage: 2Gi
  accessModes:
  - ReadOnlyMany
  persistentVolumeReclaimPolicy: Retain
  cephfs:
    monitors:
      - 172.31.217.43:6789
      - 172.31.217.44:6789
      - 172.31.217.45:6789
    user: admin
    secretRef:
      name: ceph-pv-secret-admin
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ceph-pvc
spec:
  accessModes:
  - ReadOnlyMany
  resources:
    requests:
      storage: 2Gi
  selector:
    matchLabels:
      app: ceph
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-test
spec:
  replicas: 4
  template:
    metadata:
      labels:
        app: ceph-web
    spec:
      containers:
      - name: nginx
        image: ikubernetes/myapp:v2
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          name: nginx-web
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
          readOnly: false
      volumes:
      - name: www
        persistentVolumeClaim:
          claimName: ceph-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-test
spec:
  ports:
  - protocol: TCP
    port: 80
    targetPort: 80
  selector:
    app: ceph-web
```