#/bin/bash
echo "Starting exec aliyun scripts, if don't ,you can ctrl + c"
sleep 5
echo "Start running cn_aliyun.py"
/usr/bin/python3 /data/devops/scripts/aliyun/cn_aliyun.py
sleep 5
echo "Start running en_aliyun.py"
/usr/bin/python3 /data/devops/scripts/aliyun/en_aliyun.py
