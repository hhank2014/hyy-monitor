kubectl delete -f prometheus-config.yaml
kubectl create -f prometheus-config.yaml
curl -X POST "http://10.96.217.94:9090/-/reload"
