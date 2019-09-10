# 错误集： 

1、映射块设备提示rbd: sysfs write failed的解决方法

RBD image feature set mismatch. Try disabling features unsupported by the kernel with "rbd feature disable".
In some cases useful info is found in syslog - try "dmesg | tail".
rbd: map failed: (6) No such device or address

解决办法：

现这种错误的原因是OS kernel不支持块设备镜像的一些特性，所以映射失败。查看该镜像支持了哪些特性：

```
[root@node3 ~]# rbd info testpool/foo
rbd image 'foo':
        size 1024 MB in 256 objects
        order 22 (4096 kB objects)
        block_name_prefix: rbd_data.3723643c9869
        format: 2
        features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
        flags: 
        create_timestamp: Sat Oct 21 14:38:04 2017
        
```        
可以看到特性feature一栏，由于我OS的kernel只支持layering，其他都不支持，所以需要把部分不支持的特性disable掉。


### 方法一：
直接diable这个rbd镜像的不支持的特性：

```
[root@node3 ~]#  rbd  feature disable testpool/foo  exclusive-lock object-map fast-diff deep-flatten
[root@node3 ~]# rbd info testpool/foo
rbd image 'foo':
        size 1024 MB in 256 objects
        order 22 (4096 kB objects)
        block_name_prefix: rbd_data.3723643c9869
        format: 2
        features: layering
        flags: 
        create_timestamp: Sat Oct 21 14:38:04 2017
```
### 方法二：
创建rbd镜像时就指明需要的特性，如：

```
[root@node3 ~]# rbd create testpool/foo1 --size 1024 --image-feature layering
[root@node3 ~]# rbd info testpool/foo1
rbd image 'foo1':
        size 1024 MB in 256 objects
        order 22 (4096 kB objects)
        block_name_prefix: rbd_data.3752643c9869
        format: 2
        features: layering
        flags: 
        create_timestamp: Sat Oct 21 14:06:47 2017
```
### 方法三：
如果还想一劳永逸，那么就在执行创建rbd镜像命令的主机中，修改Ceph配置文件/etc/ceph/ceph.conf，在global section下，增加：

```
rbd_default_features = 1
```

注意：该方法需要先删除之前创建过的镜像，再创建该镜像

通过上面三个方法的任意一种之后，再次尝试映射rdb镜像到本地块设备，成功！

```
[root@node3 ~]# rbd map testpool/foo 
/dev/rbd0
```