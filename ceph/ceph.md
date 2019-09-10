# INSTALLATION

## Install ceph

```
sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://dl.fedoraproject.org/pub/epel/7/x86_64/ 
sudo yum install --nogpgcheck -y epel-release && sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-7 
sudo rm /etc/yum.repos.d/dl.fedoraproject.org*
```

## Create ceph's user

```
username=cehper
useradd ${username}
echo 'a123456ceph'  | passwd --stdin ${username}
echo "${username} ALL = (root) NOPASSWD:ALL" | sudo tee /etc/sudoers.d/${username}
chmod 0440 /etc/sudoers.d/${username}
```

# STORAGE CLUSTER QUICK START

```
mkdir my-cluster
cd my-cluster

```

If at any point you run into trouble and you want to start over, execute the following to purge the Ceph packages, and erase all its data and configuration:

```
ceph-deploy purge {ceph-node} [{ceph-node}]
ceph-deploy purgedata {ceph-node} [{ceph-node}]
ceph-deploy forgetkeys
rm ceph.*
```
## CREATE A CLUSTER

### Create the cluster

```
ceph-deploy new tg-ops-sz001 tg-ops-sz002 tg-ops-sz003
```

### Install Ceph packages

```
ceph-deploy install tg-ops-sz001 tg-ops-sz002 tg-ops-sz003
```

### Deploy the initial monitor(s) and gather the keys:

```
ceph-deploy mon create-initial
```

### Add OSDs

```
ceph-deploy osd create --data /dev/vdb tg-ops-sz001
ceph-deploy osd create --data /dev/vdb tg-ops-sz002
ceph-deploy osd create --data /dev/vdb tg-ops-sz003
```
### Check your cluster’s health

```
ceph health
ceph -s
```

### ADDING MONITORS


```
ceph-deploy mon add {mod-nodes}

for example

ceph-deploy mon add node1 node2 node3

```

### REMOVE A MONITOR

```
ceph-deploy mon destroy {host-name [host-name]...}
```

Once you have added your new Ceph Monitors, Ceph will begin synchronizing the monitors and form a quorum. You can check the quorum status by executing the following:

```
ceph quorum_status --format json-pretty
```

### LIST DISKS
```
ceph-deploy disk list node-name
```

### ZAP DISKS

To zap a disk (delete its partition table) in preparation for use with Ceph, execute the following:

```
ceph-deploy disk zap {osd-server-name}:{disk-name}
ceph-deploy disk zap osdserver1:sdb
```
### CREATE OSDS

Once you create a cluster, install Ceph packages, and gather keys, you may create the OSDs and deploy them to the OSD node(s).

```
ceph-deploy osd create --data {data-disk} {node-name}
```

### LIST OSDS

To list the OSDs deployed on a node(s), execute the following command:

```
ceph-deploy osd list {node-name}

[cehper@tg-ops-sz001 my-cluster]$ sudo /usr/sbin/ceph-volume lvm list


====== osd.0 =======

  [block]    /dev/ceph-e5af86f6-c8a0-4d70-999c-73f3d38f3b5b/osd-block-2c287dc0-5840-4ea1-9cac-706615cb626f

      type                      block
      osd id                    0
      cluster fsid              695dc799-c7a5-4e24-9fab-8f4943a77a06
      cluster name              ceph
      osd fsid                  2c287dc0-5840-4ea1-9cac-706615cb626f
      encrypted                 0
      cephx lockbox secret
      block uuid                nSefhg-erLV-KqX6-TQzc-Rmqt-0bFK-gEi1rQ
      block device              /dev/ceph-e5af86f6-c8a0-4d70-999c-73f3d38f3b5b/osd-block-2c287dc0-5840-4ea1-9cac-706615cb626f
      vdo                       0
      crush device class        None
      devices                   /dev/vdb

``` 
### STARTING ALL DAEMONS

```
sudo systemctl start ceph-osd.target
sudo systemctl start ceph-mon.target
sudo systemctl start ceph-mds.target
```

### LIST POOLS

```
ceph osd lspools
```

### CREATE A POOL

To create a pool, execute:

```
ceph osd pool create {pool-name} {pg-num} [{pgp-num}] [replicated] \
     [crush-rule-name] [expected-num-objects]
ceph osd pool create {pool-name} {pg-num}  {pgp-num}   erasure \
     [erasure-code-profile] [crush-rule-name] [expected_num_objects]
```

### DELETE A POOL

```
ceph osd pool delete {pool-name} [{pool-name} --yes-i-really-really-mean-it]
```
### RENAME A POOL

```
ceph osd pool rename {current-pool-name} {new-pool-name}
```
### MAKE A SNAPSHOT OF A POOL

```
[cehper@tg-ops-sz001 my-cluster]$ ceph osd pool mksnap tgops snap-tgops
created pool tgops snap snap-tgops
```

### REMOVE A SNAPSHOT OF A POOL

```
ceph osd pool rmsnap {pool-name} {snap-name}
```
### SET POOL VALUES

```
ceph osd pool set {pool-name} {key} {value}
``` 
### GET POOL VALUES

```
ceph osd pool get {pool-name} {key}
```

# CREATE A BLOCK DEVICE POOL

### CREATE A BLOCK DEVICE USER

```
ceph auth get-or-create client.{ID} mon 'profile rbd' osd 'profile {profile name} [pool={pool-name}][, profile ...]'
```
With Urls: <https://docs.ceph.com/docs/master/rados/operations/user-management/#add-a-user>

### CREATING A BLOCK DEVICE IMAGE

```
rbd create --size 4096 test001/rbd001

[cehper@tg-ops-sz001 my-cluster]$ rbd ls test001
rbd001

[cehper@tg-ops-sz001 my-cluster]$ rbd info test001/rbd001
rbd image 'rbd001':
	size 4 GiB in 1024 objects
	order 22 (4 MiB objects)
	id: 5f596b8b4567
	block_name_prefix: rbd_data.5f596b8b4567
	format: 2
	features: layering, exclusive-lock, object-map, fast-diff, deep-flatten
	op_features:
	flags:
	create_timestamp: Tue Aug  6 11:19:03 2019
```

### REMOVING A BLOCK DEVICE IMAGE

```
[cehper@tg-ops-sz001 my-cluster]$ rbd rm test001/rbd001
Removing image: 100% complete...done.
```
### RESTORING A BLOCK DEVICE IMAGE

```
[cehper@tg-ops-sz001 my-cluster]$ rbd trash mv test001/rbd001
[cehper@tg-ops-sz001 my-cluster]$ rbd trash ls test001
5f806b8b4567 rbd001

[cehper@tg-ops-sz001 my-cluster]$ rbd trash restore test001/5f806b8b4567
[cehper@tg-ops-sz001 my-cluster]$ rbd ls test001
rbd001
```
### CREATE SNAPSHOT

```
[cehper@tg-ops-sz001 my-cluster]$ rbd snap create test001/rbd001@snap-rbd001
[cehper@tg-ops-sz001 my-cluster]$ rbd snap ls test001/rbd001
SNAPID NAME         SIZE TIMESTAMP
     4 snap-rbd001 4 GiB Tue Aug  6 11:35:27 2019
```
### ROLLBACK SNAPSHOT
```
[cehper@tg-ops-sz001 my-cluster]$ rbd snap purge test001/rbd001
Removing all snapshots: 100% complete...done.
[cehper@tg-ops-sz001 my-cluster]$ rbd snap ls test001/rbd001
```
# Client operator

```
# rbd map --image test001/rbd001

rbd: sysfs write failed
RBD image feature set mismatch. You can disable features unsupported by the kernel with "rbd feature disable rbd001 object-map fast-diff deep-flatten".
In some cases useful info is found in syslog - try "dmesg | tail".


# rbd feature disable test001/rbd001 exclusive-lock object-map deep-flatten fast-diff
# rbd showmapped
id pool    image  snap device
0  test001 rbd001 -    /dev/rbd0

挂载到本地 

# df -h /rbd
文件系统        容量  已用  可用 已用% 挂载点
/dev/rbd0       4.0G   33M  4.0G    1% /rbd

取消映射

# rbd unmap /dev/rbd0
```

# ceph base command

1. 查看osd 的目录树:  ceph osd tree
2. 查看机器的实时运行状态 ：ceph –w
3. 查看ceph的存储空间 ：ceph df
4. 查看mon的状态信息 ：ceph mon stat
5. 查看osd运行状态 : ceph osd stat

# Dashboard
```
ceph mgr module enable dashboard

$ ceph mgr services
{
    "dashboard": "http://tg-ops-sz001.tgops.com:8080/"
}

create user and password

ceph dashboard set-login-credentials admin admin123a@
```
