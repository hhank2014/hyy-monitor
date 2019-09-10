### k8s rbd

怎么获取key，如下 ,这里需要转换，否则无法识别报错。

```
$ ceph auth get-key client.admin |base64
QVFDN28wZGRSaDVkRkJBQTVFMkJoSlVmWFJKNnNURzA4YU5UTUE9PQ==
```

```
apiVersion: v1
kind: Secret
metadata:
  name: ceph-pv-secret-admin-rbd
data:
  key: QVFDN28wZGRSaDVkRkJBQTVFMkJoSlVmWFJKNnNURzA4YU5UTUE9PQ==
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: ceph-pv-rbd-nginx
  labels:
    app: ceph-rbd
spec:
  capacity:
    storage: 2Gi
  accessModes:
  - ReadWriteOnce
  rbd:
    monitors:
    - 172.31.217.43:6789
    user: admin
    pool: rbd
    image: ceph-image
    secretRef:
      name: ceph-pv-secret-admin-rbd
    fsType: ext4
    readOnly: false
  persistentVolumeReclaimPolicy: Recycle
---
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ceph-pvc-rbd-nginx
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
---
apiVersion: extensions/v1beta1
kind: Deployment
metadata:
  name: nginx-test-rbd
spec:
  replicas: 1
  template:
    metadata:
      labels:
        app: ceph-web-rbd
    spec:
      containers:
      - name: nginx
        image: nginx
        imagePullPolicy: IfNotPresent
        ports:
        - containerPort: 80
          name: nginx-web-rdb
        volumeMounts:
        - name: www
          mountPath: /usr/share/nginx/html
          readOnly: false
      volumes:
      - name: www
        persistentVolumeClaim:
          claimName: ceph-pvc-rbd-nginx
---
apiVersion: v1
kind: Service
metadata:
  name: nginx-test-rbd
spec:
  ports:
  - port: 80
    targetPort: web
  selector:
    app: ceph-web-rbd
```