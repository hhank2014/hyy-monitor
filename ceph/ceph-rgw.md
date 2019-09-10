# ceph-rgw


### INSTALL CEPH OBJECT GATEWAY
```
ceph-deploy install --rgw tg-ops-sz001 tg-ops-sz002 tg-ops-sz003
```
### CREATE A GATEWAY INSTANCE
```
ceph-deploy rgw create tg-ops-sz001 tg-ops-sz002 tg-ops-sz003

$ sudo netstat -tnlp|grep 7480
tcp        0      0 0.0.0.0:7480            0.0.0.0:*               LISTEN      3419316/radosgw
```
log as following:

sudo systemctl enable ceph-radosgw@rgw.tg-ops-sz003
sudo systemctl start ceph-radosgw@rgw.tg-ops-sz003

ceph-deploy purge <gateway-node1> [<gateway-node2>]
ceph-deploy purgedata <gateway-node1> [<gateway-node2>]


if your node name is gateway-node1, add a section like this after the [global] section:
```
[client.rgw.gateway-node1]
rgw_frontends = "civetweb port=80"

ceph-deploy --overwrite-conf config push <gateway-node> [<other-nodes>]
sudo systemctl restart ceph-radosgw.service
```
### USING SSL WITH CIVETWEB

```
[client.rgw.gateway-node1]
rgw_frontends = civetweb port=443s ssl_certificate=/etc/ceph/private/keyandcert.pem
```
New in version Luminous.

Furthermore, civetweb can be made to bind to multiple ports, by separating them with + in the configuration. This allows for use cases where both ssl and non-ssl connections are hosted by a single rgw instance. For eg:
```
[client.rgw.gateway-node1]
rgw_frontends = civetweb port=80+443s ssl_certificate=/etc/ceph/private/keyandcert.pem
```
### CREATE A USER
```
[cehper@tg-ops-sz001 my-cluster]$ radosgw-admin user create --uid=tgops --display-name="tgops" --email="hank@tg10010.com"
{
    "user_id": "tgops",
    "display_name": "tgops",
    "email": "hank@tg10010.com",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [],
    "keys": [
        {
            "user": "tgops",
            "access_key": "JGUU4SL4FT2EZ8K2METM",
            "secret_key": "hiXI8NSq6ktVttyOmPMdDEOhZclK13OTwzm7Z6Up"
        }
    ],
    "swift_keys": [],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}
```

### CREATE A SUBUSER

```
[cehper@tg-ops-sz001 my-cluster]$ radosgw-admin subuser create --uid=tgops --subuser=tgops:swift --access=full
{
    "user_id": "tgops",
    "display_name": "tgops",
    "email": "hank@tg10010.com",
    "suspended": 0,
    "max_buckets": 1000,
    "auid": 0,
    "subusers": [
        {
            "id": "tgops:swift",
            "permissions": "full-control"
        }
    ],
    "keys": [
        {
            "user": "tgops",
            "access_key": "W9JOTLZQGPKWN5DNG2V9",
            "secret_key": "vq68SRO7KrcCNzTTXc2qAwEyUCHaK2iBCfczuivf"
        }
    ],
    "swift_keys": [
        {
            "user": "tgops:swift",
            "secret_key": "0Gd1wBzAxBO9c1frJnMsT98tqE6FBAhLmzO9vPOf"
        }
    ],
    "caps": [],
    "op_mask": "read, write, delete",
    "default_placement": "",
    "placement_tags": [],
    "bucket_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "user_quota": {
        "enabled": false,
        "check_on_raw": false,
        "max_size": -1,
        "max_size_kb": 0,
        "max_objects": -1
    },
    "temp_url_keys": [],
    "type": "rgw",
    "mfa_ids": []
}


[cehper@tg-ops-sz001 my-cluster]$ radosgw-admin user info --uid=tgops
```

# S3 API
```
yum install -y s3cmd
```
```
[cehper@tg-ops-sz001 my-cluster]$ s3cmd --configure

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3. Leave them empty for using the env variables.
Access Key:
Secret Key:
Default Region [US]: HK

Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target Amazon S3.
S3 Endpoint [s3.amazonaws.com]: ^C
Configuration aborted. Changes were NOT saved.
[cehper@tg-ops-sz001 my-cluster]$ s3cmd --configure

Enter new values or accept defaults in brackets with Enter.
Refer to user manual for detailed description of all options.

Access key and Secret key are your identifiers for Amazon S3. Leave them empty for using the env variables.
Access Key: JGUU4SL4FT2EZ8K2METM
Secret Key: hiXI8NSq6ktVttyOmPMdDEOhZclK13OTwzm7Z6Up
Default Region [US]: HK

Use "s3.amazonaws.com" for S3 Endpoint and not modify it to the target Amazon S3.
S3 Endpoint [s3.amazonaws.com]:

Use "%(bucket)s.s3.amazonaws.com" to the target Amazon S3. "%(bucket)s" and "%(location)s" vars can be used
if the target S3 system supports dns based buckets.
DNS-style bucket+hostname:port template for accessing a bucket [%(bucket)s.s3.amazonaws.com]:

Encryption password is used to protect your files from reading
by unauthorized persons while in transfer to S3
Encryption password:
Path to GPG program [/bin/gpg]:

When using secure HTTPS protocol all communication with Amazon S3
servers is protected from 3rd party eavesdropping. This method is
slower than plain HTTP, and can only be proxied with Python 2.7 or newer
Use HTTPS protocol [Yes]: no

On some networks all internet access must go through a HTTP proxy.
Try setting it here if you can't connect to S3 directly
HTTP Proxy server name:

New settings:
  Access Key: JGUU4SL4FT2EZ8K2METM
  Secret Key: hiXI8NSq6ktVttyOmPMdDEOhZclK13OTwzm7Z6Up
  Default Region: HK
  S3 Endpoint: s3.amazonaws.com
  DNS-style bucket+hostname:port template for accessing a bucket: %(bucket)s.s3.amazonaws.com
  Encryption password:
  Path to GPG program: /bin/gpg
  Use HTTPS protocol: False
  HTTP Proxy server name:
  HTTP Proxy server port: 0

Test access with supplied credentials? [Y/n] n

Save settings? [y/N] y
Configuration saved to '/home/cehper/.s3cfg'
```


### 创建默认pool
```
[cehper@tg-ops-sz001 my-cluster]$ cat a.sh
#!/bin/bash

PG_NUM=2
PGP_NUM=3
SIZE=3

for i in `cat /home/cehper/pool`
        do
        ceph osd pool create $i $PG_NUM
        ceph osd pool set $i size $SIZE
        done

for i in `cat /home/cehper/pool`
        do
        ceph osd pool set $i pgp_num $PGP_NUM
        done
[cehper@tg-ops-sz001 my-cluster]$ cat /home/cehper/pool
.rgw
.rgw.root
.rgw.control
.rgw.gc
.rgw.buckets
.rgw.buckets.index
.rgw.buckets.extra
.log
.intent-log
.usage
.users
.users.email
.users.swift
.users.uid
```

# Client node
```
[cehper@tg-ops-sz001 my-cluster]$ s3cmd mb s3://test
Bucket 's3://test/' created

[cehper@tg-ops-sz001 my-cluster]$ s3cmd ls
2019-08-06 07:12  s3://test

[cehper@tg-ops-sz001 my-cluster]$ s3cmd put /etc/hosts s3://test
upload: '/etc/hosts' -> 's3://test/hosts'  [1 of 1]
 395 of 395   100% in    1s   270.49 B/s  done

[cehper@tg-ops-sz001 my-cluster]$ s3cmd ls s3://test/
2019-08-06 07:17       395   s3://test/hosts
```

# Swift API
```
sudo yum install -y python-pip
sudo pip install --upgrade python-swiftclient

[cehper@tg-ops-sz001 my-cluster]$ swift -A http://tg-ops-sz001:7480/auth/v1.0 -U tgops:swift -K 0Gd1wBzAxBO9c1frJnMsT98tqE6FBAhLmzO9vPOf list
test
[cehper@tg-ops-sz001 my-cluster]$ swift -A http://tg-ops-sz001:7480/auth/v1.0 -U tgops:swift -K 0Gd1wBzAxBO9c1frJnMsT98tqE6FBAhLmzO9vPOf stat -v
                                 StorageURL: http://tg-ops-sz001:7480/swift/v1
                                 Auth Token: AUTH_rgwtk0b00000074676f70733a7377696674ef447786cd0c8a9957824a5d88f3c4015b0ced3ee7fdf5e9cf2a0563b435670945738e22
                                    Account: v1
                                 Containers: 1
                                    Objects: 1
                                      Bytes: 395
Objects in policy "default-placement-bytes": 0
  Bytes in policy "default-placement-bytes": 0
   Containers in policy "default-placement": 1
      Objects in policy "default-placement": 1
        Bytes in policy "default-placement": 395
                              Accept-Ranges: bytes
                                X-Timestamp: 1565077719.03574
                X-Account-Bytes-Used-Actual: 4096
                                 X-Trans-Id: tx000000000000000000041-005d4930d7-111e-default
                               Content-Type: text/plain; charset=utf-8
                     X-Openstack-Request-Id: tx000000000000000000041-005d4930d7-111e-default

 
[cehper@tg-ops-sz001 my-cluster]$ swift -A http://tg-ops-sz001:7480/auth/v1.0 -U tgops:swift -K 0Gd1wBzAxBO9c1frJnMsT98tqE6FBAhLmzO9vPOf post test02   # post 新建bucket
[cehper@tg-ops-sz001 my-cluster]$ swift -A http://tg-ops-sz001:7480/auth/v1.0 -U tgops:swift -K 0Gd1wBzAxBO9c1frJnMsT98tqE6FBAhLmzO9vPOf list
test
test02
```

这里也可以用s3cmd 来验证

```
[cehper@tg-ops-sz001 my-cluster]$ s3cmd ls
2019-08-06 07:12  s3://test
2019-08-06 07:50  s3://test02
```



