persistentvolume-controller  Failed to provision volume with StorageClass "dynamic": failed to create rbd image: executable file not found in $PATH, command output


provisioner: kubernetes.io/rbd 修改为 provisioner: ceph.com/rbd，意思就是不使用 k8s 内部提供的 rbd 存储类型，而是使用我们刚创建的扩展 rbd 存储。

