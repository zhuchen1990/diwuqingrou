import time, threading


#
def loop():
    print('2-thread %s is running...' % threading.current_thread().name)
    n = 0
    while n < 5:
        n = n + 1
        print('3-thread %s >>> %s' % (threading.current_thread().name, n))
        time.sleep(1)
    print('4-thread %s ended.' % threading.current_thread().name)


print('1-thread %s is running...' % threading.current_thread().name)
t = threading.Thread(target=loop, name='LoopThreads')
t.start()
t.join()
print('5-thread %s ended.' % threading.current_thread().name)
