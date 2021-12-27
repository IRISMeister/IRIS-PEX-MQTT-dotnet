from struct import pack, unpack, calcsize

mytuple= tuple(range(10))
mydata=[mytuple]
myfile = open('data1.data', 'wb')

for item in mydata:
    result = pack('llllllllll', item[0], item[1], item[2], item[3], item[4], item[5], item[6], item[7], item[8], item[9])
    myfile.write(result)

myfile.close()

from numpy import *
 
na = array([]) 
for loop in range(100):
    na=append(na,array([loop, 10, 100,101,102,3.14,104,8192,65536,99.999]))
# 書き込み
na.tofile('data2.data')

na = array([]) 
for loop in range(1000):
    na=append(na,array([loop, 10, 100,101,102,3.14,104,8192,65536,99.999]))
# 書き込み
na.tofile('80k.data')

na = array([]) 
for loop in range(4000):
    na=append(na,array([loop, 10, 100,101,102,3.14,104,8192,65536,99.999]))
# 書き込み
na.tofile('320k.data')

exit(0)

na = array([]) 
for loop in range(40000):
    na=append(na,array([loop, 10, 100,101,102,3.14,104,8192,65536,99.999]))
# 書き込み
na.tofile('3200k.data')

na = array([]) 
for loop in range(50000):
    na=append(na,array([loop, 10, 100,101,102,3.14,104,8192,65536,99.999]))
# 書き込み
na.tofile('4000k.data')