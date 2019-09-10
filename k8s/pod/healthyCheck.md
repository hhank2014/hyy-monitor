cat livenessprove-demo.yaml
apiVersion: v1
kind: Pod
metadata:
  name: livenessprobe-demo
  labels:
    test: livenessprobe
spec:
  containers:
  - name: liveness
    image: busybox
    args:
    - /bin/sh
    - -c
    - touch /tmp/healthy;sleep 30;rm -rf /tmp/healthy;sleep 600
    livenessProbe:
      exec:
        command:
        - cat
        - /tmp/healthy
      initialDelaySeconds: 5
      periodSeconds: 5

kubectl create -f livenessprove-demo.yaml

kubectl describe pod livenessprobe-demo

  Normal   Scheduled  111s                default-scheduler                Successfully assigned default/livenessprobe-demo to tg-ops-sz003.tgops.com
  Warning  Unhealthy  64s (x3 over 74s)   kubelet, tg-ops-sz003.tgops.com  Liveness probe failed: cat: can not open '/tmp/healthy': No such file or directory
  Normal   Killing    64s                 kubelet, tg-ops-sz003.tgops.com  Container liveness failed liveness probe, will be restarted
  Normal   Pulling    34s (x2 over 110s)  kubelet, tg-ops-sz003.tgops.com  Pulling image "busybox"
  Normal   Pulled     30s (x2 over 106s)  kubelet, tg-ops-sz003.tgops.com  Successfully pulled image "busybox"
  Normal   Created    30s (x2 over 106s)  kubelet, tg-ops-sz003.tgops.com  Created container liveness
  Normal   Started    30s (x2 over 106s)  kubelet, tg-ops-sz003.tgops.com  Started container liveness

在容器启动的时候，执行了如下命令：

 /bin/sh -c "touch /tmp/healthy; sleep 30; rm -rf /tmp/healthy; sleep 600"

在容器最开始的30秒内有一个/tmp/healthy文件，在这30秒内执行cat /tmp/healthy命令都会返回一个成功的返回码。30秒后，我们删除这个文件，现在执行cat /tmp/healthy是不是就会失败了，这个时候就会重启容器了

kubectl describe pod liveness-exec

[root@tg-ops-sz001 k8s]# kubectl get pod livenessprobe-demo
NAME                 READY   STATUS    RESTARTS   AGE
livenessprobe-demo   1/1     Running   1          2m6
