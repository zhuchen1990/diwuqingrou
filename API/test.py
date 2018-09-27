items = [{'status': 'firing',
          'labels': {'alertname': 'NodeFilesystemUsage', 'device': 'rootfs', 'endpoint': 'https', 'fstype': 'rootfs',
                     'instance': '192.168.145.132:9100', 'job': 'node-exporter', 'mountpoint': '/',
                     'namespace': 'monitoring', 'pod': 'node-exporter-t7dkq', 'prometheus': 'monitoring/k8s',
                     'service': 'node-exporter', 'severity': 'node'}, 'annotations': {
        'description': '192.168.145.132:9100: Filesystem usage is above 80% (current value is: 65.852965641888',
        'summary': '192.168.145.132:9100: High Filesystem usage detected'},
          'startsAt': '2018-09-27T01:24:08.191320551Z', 'endsAt': '0001-01-01T00:00:00Z',
          'generatorURL': 'http://prometheus-k8s-0:9090/graph?g0.expr=(node_filesystem_size{device="rootfs"}+-+node_filesystem_free{device="rootfs"})+/+node_filesystem_size{device="rootfs"}+*+100+>+50&g0.tab=1'},
         {'status': 'firing',
          'labels': {'alertname': 'NodeFilesystemUsage', 'device': 'rootfs', 'endpoint': 'https', 'fstype': 'rootfs',
                     'instance': '192.168.145.134:9100', 'job': 'node-exporter', 'mountpoint': '/',
                     'namespace': 'monitoring', 'pod': 'node-exporter-pxn7r', 'prometheus': 'monitoring/k8s',
                     'service': 'node-exporter', 'severity': 'node'}, 'annotations': {
             'description': '192.168.145.134:9100: Filesystem usage is above 80% (current value is: 50.086483665344375',
             'summary': '192.168.145.134:9100: High Filesystem usage detected'},
          'startsAt': '2018-09-27T01:24:08.191320551Z', 'endsAt': '0001-01-01T00:00:00Z',
          'generatorURL': 'http://prometheus-k8s-0:9090/graph?g0.expr=(node_filesystem_size{device="rootfs"}+-+node_filesystem_free{device="rootfs"})+/+node_filesystem_size{device="rootfs"}+*+100+>+50&g0.tab=1'}]

import urllib.request
import json
from flask import Flask
from flask import request

app = Flask(__name__)


# --------------------------------
# 获取企业微信token
# --------------------------------
def get_token(url, corpid, corpsecret):
    token_url = '%s/cgi-bin/gettoken?corpid=%s&corpsecret=%s' % (url, corpid, corpsecret)
    token = json.loads(urllib.request.urlopen(token_url).read().decode())['access_token']
    return token


# --------------------------------
# 构建告警信息json
# --------------------------------
def messages(msg):
    values = {
        "touser": '@all',
        "msgtype": 'text',
        "agentid": 1000002,  # 偷懒没有使用变量了，注意修改为对应应用的agentid
        "text": {'content': msg},
        "safe": 0
    }
    msges = (bytes(json.dumps(values), 'utf-8'))
    return msges


# --------------------------------
# 发送告警信息
# --------------------------------
def send_message(url, token, data):
    send_url = '%s/cgi-bin/message/send?access_token=%s' % (url, token)
    respone = urllib.request.urlopen(urllib.request.Request(url=send_url, data=data)).read()
    x = json.loads(respone.decode())['errcode']
    if x == 0:
        print('Succesfully')
    else:
        print('Failed')


# ------------
# 配置信息
# ------------
corpid = 'ww507909e3fbe4267d'
corpsecret = '2aDwnIeO_iRg2GmWwVuWs-TSM0ibwlYV5wtkWFeLFH4'
url = 'https://qyapi.weixin.qq.com'


# ------------
# 接收报警信息,并发送到企业微信
# ------------
def webHook():
    print(items)
    test_token = get_token(url, corpid, corpsecret)
    for i in items:
        try:
            alertname = i['labels']['alertname']
        except:
            alertname = "未知名称或者没有"
        try:
            instance = i['labels']['instance']
        except:
            instance = "未知主机或者与主机无关"
        try:
            description = i['annotations']['description']
        except:
            description = "没有描述信息"
        try:
            summary = i['annotations']['summary']
        except:
            summary = "没有结论信息"
        try:
            startAt = i['startsAt']
        except:
            startAt = "未知开始时间或者没有开始时间"
        message = '''@警报名称:%s\n\n@主机信息:%s\n\n@描述信息:%s\n\n@总结信息:%s\n\n@开始时间:%s\n\n''' % (
        alertname, instance, description, summary, startAt)
        msg_data = messages(message)
        send_message(url, test_token, msg_data)


webHook()
