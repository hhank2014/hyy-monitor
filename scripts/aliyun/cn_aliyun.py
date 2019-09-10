#!/usr/bin/env python
# coding=utf-8
# filename: en_assets.py
# by hank 2019-07-09

import json
import MySQLdb
from aliyunsdkcore.client import AcsClient
from aliyunsdkecs.request.v20140526 import DescribeInstancesRequest
from aliyunsdkecs.request.v20140526 import DescribeDisksRequest
import slack_send

class alicmd:

    def __init__(self, Account, AccessKey, AccessKeySecret, Region, host, user, passwd, db):
        
        self.Account = Account
        # Auth
        self.client = AcsClient(AccessKey, AccessKeySecret, Region)

        # instance
        self.request = DescribeInstancesRequest.DescribeInstancesRequest()
        self.request.set_PageSize(1)
        self.response = json.loads(self.client.do_action_with_exception(self.request))

        # Disk
        self.disk_request = DescribeDisksRequest.DescribeDisksRequest()
        self.disk_request.set_PageSize(1)
        self.disk_response = json.loads(self.client.do_action_with_exception(self.disk_request))

        # MySQL
        self.mysql_conn = MySQLdb.connect(host = host, user = user, passwd = passwd, db = db, charset="utf8")
        self.db_cursor = self.mysql_conn.cursor()

    def TotalPage(self):

        page_size = 10
        total_page, b = divmod(self.response["TotalCount"], page_size)
        if b:
            total_page = total_page + 1
        return total_page

    def TotalPageDisk(self):

        page_size = 10
        total_page, b = divmod(self.disk_response["TotalCount"], page_size)
        if b:
            total_page = total_page + 1
        return total_page

    def GetInfo(self, TotalPage):

        data = []

        for PageNum in range(1, TotalPage + int(1)):
            request = DescribeInstancesRequest.DescribeInstancesRequest()
            request.set_PageNumber(PageNum)

            response = json.loads(self.client.do_action_with_exception(request))

            for i in response["Instances"]["Instance"]:
                PublicIp = i["PublicIpAddress"]["IpAddress"]
                EipAddress = i["EipAddress"]["IpAddress"]

                if len(PublicIp) == 0:
                    PublicIpAddress = EipAddress
                else:
                    PublicIpAddress = PublicIp[0]

                try:
                    tagsValues = i["Tags"]["Tag"][0]["TagValue"]
                except KeyError:
                    tagsValues = i["InstanceName"]
                    text = "标签 TagValue {} 为空，请登录{} 账号检查。".format(i["InstanceName"], self.Account)
                    slack_send.alert(text)
                    print(text)
                try:
                    tagsKey = i["Tags"]["Tag"][0]["TagKey"]
                except KeyError:
                    tagsKey = i["InstanceName"]
                    text = "标签 TagKey {} 为空，请登录{} 账号检查。".format(i["InstanceName"], self.Account)
                    slack_send.alert(text)
                    print(text)

                info = (
                    i["RegionId"],
                    i["ZoneId"],
                    i["InstanceId"],
                    i["InstanceName"],
                    tagsValues,
                    tagsKey,
                    i["NetworkInterfaces"]["NetworkInterface"][0]["PrimaryIpAddress"],
                    PublicIpAddress,
                    i["InternetMaxBandwidthOut"],
                    i["InstanceType"],
                    i["Cpu"],
                    i["Memory"],
                    i["OSType"],
                    i["OSName"],
                    i["Status"],
                    self.Account,
                    i["CreationTime"],
                    i["ExpiredTime"]
                )
                data.append(info)
        return data

    def GetInfoENdisk(self, TotalPageDisk):

        data = []

        for PageNum in range(1, TotalPageDisk + int(1)):
            request = DescribeDisksRequest.DescribeDisksRequest()
            request.set_PageNumber(PageNum)

            response = json.loads(self.client.do_action_with_exception(request))

            for i in response["Disks"]["Disk"]:

                info = (
                    self.Account,
                    i.get("RegionId"),
                    i.get("ZoneId"),
                    i.get("InstanceId"),
                    i.get("DiskId"),
                    i.get("Device"),
                    i.get("Size"),
                    i.get("Status"),
                    i.get("CreationTime"),
                    i.get("ExpiredTime")
                )
                data.append(info)
        return data

    def StorageDB(self, data):
        for i in data:
            self.db_cursor.execute("insert into cn_assets(RegionId ,ZoneId, InstanceId, InstanceName, TagValue, TagKey, PrivateIpAddress, PublicIpAddress, Bandwidth, InstanceType, Cpu, Memory, OSType, OSName, Status, Account, CreationTime, ExpiredTime) VALUES {}".format(i))
            self.mysql_conn.commit()
        #self.mysql_conn.close()

    def StorageDBDisk(self, disk):
        for i in disk:
            self.db_cursor.execute("insert into cn_assets_disk(Account, RegionId, ZoneId, InstanceId, DiskId, Device, Size, Status, CreationTime, ExpiredTime) VALUES {}".format(i))
            self.mysql_conn.commit()
        self.mysql_conn.close()
        

accounts = [{"AccountName": "name1",  "AccessKey": "", "AccessKeySecret": "" }, {"AccountName": "",  "AccessKey": "", "AccessKeySecret": "" }}
regions = ["cn-hongkong", "ap-southeast-1"]

host = ""
user = ""
passwd = ""
db = "cmdb"

mysql_conn = MySQLdb.connect(host = host, user = user, passwd = passwd, db = db, charset="utf8")
db_cursor = mysql_conn.cursor()
db_cursor.execute("truncate cn_assets;")
db_cursor.execute("truncate cn_assets_disk;")
mysql_conn.commit()

for i in accounts:
    for Region in regions:
        Account = i.get("AccountName")
        AccessKey = i.get("AccessKey")
        AccessKeySecret = i.get("AccessKeySecret")

        ali = alicmd(Account, AccessKey, AccessKeySecret, Region, host, user, passwd, db)

        TotalPage = ali.TotalPage()
        data = ali.GetInfo(TotalPage)
        if data:
            ali.StorageDB(data)

        TotalPageDisk = ali.TotalPageDisk()
        disk = ali.GetInfoENdisk(TotalPageDisk)
        if disk:
           ali.StorageDBDisk(disk)
