from datetime import datetime

now = datetime.now()

print(now)

print(type(now))

dt = datetime(2018, 4, 19, 12, 20)

print(dt)

print(dt.timestamp())
cday = datetime.strptime('2018-6-1 18:19:59', '%Y-%m-%d %H:%M:%S')
print(cday)
print(type(cday))
