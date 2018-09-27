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
@app.route('/WebHookTest/', methods=['POST'])
def webHook():
    post_data = request.data
    items = json.loads(post_data.decode("utf-8"))['alerts']
    print(items)
    test_token = get_token(url, corpid, corpsecret)
    for i in items:
        try:
            alertname = i['labels']['alertname']
            if alertname == 'DeadMansSwitch' or 'KubeControllerManagerDown' or 'KubeSchedulerDown' or 'KubeVersionMismatch':
                break
        except:
            alertname = "未知名称或者没有"
        try:
            instance = i['labels']['instance']
        except:
            instance = "未知主机或者与主机无关"
        try:
            description = i['annotations']['description']
        except:
            description = i['annotations']['message']
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
    return "ok"


if __name__ == '__main__':
    app.debug = True
    app.run(host='0.0.0.0', port='8080')
