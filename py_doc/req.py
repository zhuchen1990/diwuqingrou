import requests

r = requests.get('https://www.douban.com/')  # 豆瓣首页
r.status_code
r.text
