#!/usr/bin/env python3
#-*- coding: utf-8 -*-
#filename: slack_alert.py
#by hank  2019-06-24

# as follows, you need to do list:
# 1. slack api install
# pip install slackclient
# 2. how to get slack api token
# https://get.slack.help/hc/en-us/articles/215770388-Create-and-regenerate-API-tokens
# https://github.com/slackapi/python-slackclient

import slack

def alert(data):
    sc = slack.WebClient(token = "slack_token")
    result = sc.chat_postMessage(
         username = "aliyun moniotr",
         channel = "monitor",
         text = data
    )
    if result["ok"]:
        pass
    else:
        print("send message failed.")

if __name__ == "__main__":
    alert(data)
