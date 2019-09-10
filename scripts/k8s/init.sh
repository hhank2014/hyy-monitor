#!/bin/bash

Service="hello"
ImageURL="harborURL"
ImageGroup="tgweb"
NodesSelector="ingress-hello-lb"
Key="key1"
TaintsNode="ingress-hello-lb"
TaintsEffect="NoSchedule"
dockerHubUser="USERNAME"
dockerHubPassword="PASSWORD"
BUILD_ID=3


if [ ! -d ${Service} ];then
	cp ./ops ${Service} -r
else
	rm -rf ./${Service}
	cp ./ops ${Service} -r
fi

DockerImageUpdate() {
	docker login harbor.tgops.cc --username=${dockerHubUser} --password=${dockerHubPassword}
	cd ./${Service}/nginx
	docker build -t ${ImageURL}/${ImageGroup}/${Service}/nginx:${BUILD_ID} .
	docker push ${ImageURL}/${ImageGroup}/${Service}/nginx:${BUILD_ID}
	cd ../php
	docker build -t ${ImageURL}/${ImageGroup}/${Service}/php:${BUILD_ID} .
	docker push ${ImageURL}/${ImageGroup}/${Service}/php:${BUILD_ID}
}

UpdateYaml() {
	cd ../../
	echo "1. ingress-controller mandatory.yaml"
	sed -i s/TAG_NAME/${Service}/g ./${Service}/ingress/mandatory.yaml

        echo "2. select nodeselector nodes"
        sed -i s/NODESSELECTOR/${NodesSelector}/g ./${Service}/ingress/mandatory.yaml

        echo "3. tolerations"
        sed -i s/KEY/${Key}/g ./${Service}/ingress/mandatory.yaml
        sed -i s/TAINTSNODE/${TaintsNode}/g  ./${Service}/ingress/mandatory.yaml
        sed -i s/TAINTSEFFECT/${TaintsEffect}/g ./${Service}/ingress/mandatory.yaml

        echo "4. TAG_NAME"
        sed -i s/TAG_NAME/${Service}/g ./${Service}/yaml/*.yaml

        echo "5. ImageURL"
        sed -i "s/ImageNginxURL/${ImageURL}\/${ImageGroup}\/${Service}\/nginx:${BUILD_ID}/g" ./${Service}/yaml/Deployment.yaml
        sed -i "s/ImagePhPURL/${ImageURL}\/${ImageGroup}\/${Service}\/php:${BUILD_ID}/g" ./${Service}/yaml/Deployment.yaml
}

Deploy() {
	kubectl apply -f ./${Service}/ingress/mandatory.yaml  --record
	kubectl apply -f ./${Service}/rbac/rbac.yaml --record
	kubectl apply -f ./${Service}/yaml/ --record
}

UpdateRbac(){
cat << EOF >> ./rbac/rbac.yaml
  - kind: ServiceAccount
    name: nginx-ingress-serviceaccount
    namespace: ingress-${Service}
EOF
}

IfOrNotRbac() {
	pwd
	str=`grep '${Service}' ./rbac/rbac.yaml`
	if [ -z "$str" ];then
		UpdateRbac
	fi
}

Main() {
	DockerImageUpdate
	UpdateYaml
	IfOrNotRbac
	Deploy
}

Main
