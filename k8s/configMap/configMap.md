
# Pod 的配置管理

## ConfigMap概述

ConfigMap 供容器使用的典型用法如下。

1. 生成为容器内的环境变量。
2. 设置容器启动命令的启动参数(需设置为环境变量)。
3. 以 Volume 的形式挂载为容器内部的文件或目录。

## 创建ConfigMap资源、对象


### 通过 yamI 配置文件方式创建

```
# cat cm-app.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-yaml
data:
  apploglevel: info
  appdatadir: /var/data
      
# kubectl create -f cm-app.yaml
configmap/cm-yaml created

# kubectl describe configmap cm-yaml
Name:         cm-yaml
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
apploglevel:
----
info
appdatadir:
----
/var/data
Events:  <none>

# cat cm-app.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-yaml
data:
  apploglevel: info
  appdatadir: /var/data

 cat cm-app-file.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: cm-yaml-file
data:
  cm-yaml-file: |
    172.31.217.45       tg-ops-sz001    tg-ops-sz001
    172.31.217.45 tg-ops-sz001.tgops.com
    172.31.217.43 tg-ops-sz002.tgops.com
    172.31.217.44 tg-ops-sz003.tgops.com

# kubectl create -f cm-app-file.yaml
configmap/cm-yaml-file created

# kubectl describe configmap cm-yaml-file
Name:         cm-yaml-file
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
cm-yaml-file:
----
172.31.217.45       tg-ops-sz001    tg-ops-sz001
172.31.217.45 tg-ops-sz001.tgops.com
172.31.217.43 tg-ops-sz002.tgops.com
172.31.217.44 tg-ops-sz003.tgops.com

Events:  <none>
```
### 通过 kubectl命令行方式创建


通过一from-file参数从文件中进行创建，可以指定 key的名称，也可以在一个命令行中 创建包含多个 key 的 ConfigMap，语法为:
```
# kubectl create configmap NAf但-- from-file=[key=)source --from-file=[key=)source

# kubectl create configmap cm-hosts --from-file=hosts

# kubectl describe configmap cm-hosts
Name:         cm-hosts
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
hosts:
----
127.0.0.1      localhost     localhost.localdomain  localhost4  localhost4.localdomain4
::1            localhost     localhost.localdomain  localhost6  localhost6.localdomain6
172.31.217.45  tg-ops-sz001  tg-ops-sz001
172.31.217.45 tg-ops-sz001.tgops.com
172.31.217.43 tg-ops-sz002.tgops.com
172.31.217.44 tg-ops-sz003.tgops.com

Events:  <none>
```
通过--from-file 参数从目 录 中进行创建，该目 录下的每个配置文件名都被设置为 key. 文件的内容被设置为 value，语法为 :
```
# kubectl create configmap NAME --from-file=config-files-dir

# kubectl create configmap cm-mutl-2file --from-file=test
configmap/cm-mutl-2file created

# kubectl describe configmap cm-mutl-2file
Name:         cm-mutl-2file
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
host.conf:
----
multi on

yum.conf:
----
[main]
cachedir=/var/cache/yum/$basearch/$releasever
keepcache=0
debuglevel=2
logfile=/var/log/yum.log
exactarch=1
obsoletes=1
gpgcheck=1
plugins=1
installonly_limit=5
bugtracker_url=http://bugs.centos.org/set_project.php?project_id=23&ref=http://bugs.centos.org/bug_report_page.php?category=yum
distroverpkg=centos-release

.....................(省略)

# PUT YOUR REPOS HERE OR IN separate files named file.repo
# in /etc/yum.repos.d

Events:  <none>
```
通过 --from-literal从文本中进行创建，直接将指定的 key#=value#创建为 ConfigMap 的内容， 语法为 :
```
# kubectl create configmap NAME --from-literal=keyl=valuel --from-literal= key2=value2

# kubectl create configmap cm-literal --from-literal=loglevel=info --from-literal=appdatadir=/var/data
configmap/cm-literal created

# kubectl describe configmap cm-literal
Name:         cm-literal
Namespace:    default
Labels:       <none>
Annotations:  <none>

Data
====
appdatadir:
----
/var/data
loglevel:
----
info
Events:  <none>
```
