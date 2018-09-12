import psutil

a = psutil.cpu_times()
b = psutil.cpu_count()
c = psutil.cpu_count(logical=False)
print(a)
print(b)
print(c)
for x in range(10):
    print(psutil.cpu_percent(interval=1, percpu=True))
print(psutil.virtual_memory())
print(psutil.swap_memory())
