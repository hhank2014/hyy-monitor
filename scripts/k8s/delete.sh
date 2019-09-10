#!/bin/bash

Service=$1



if [ -z ${Service} ];then

	echo "Usage: $1 can't be empty"
	echo "Usage: sh delete.sh ProjectName"
else
	echo -e "\033[1;32m===================Attention please, everyone!===================\033[0m"
	echo -e "\033[31mProjeect: '${Service}' will be delete, Please choose Yes or No:\033[0m"
	echo -n "Please input Yes/No:"
	
	read option

	if [ ${option} = "No" ];then
		exit
	elif [ ${option} = "Yes" ];then
		kubectl delete -f ../services/${Service}/ingress/mandatory.yaml
		kubectl delete -f ../services/${Service}/yaml/
	else
		echo "unkonwn"
	fi
fi
