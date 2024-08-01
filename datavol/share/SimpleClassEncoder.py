import io,os
import avro.schema
import avro.io
import random

schema = avro.schema.parse(open('SimpleClass.avsc', 'rb').read())

writer = avro.io.DatumWriter(schema)
bytes_writer = io.BytesIO()
encoder = avro.io.BinaryEncoder(bytes_writer)

#バイナリファイルを使用する場合。
#with open('shrimp.png', 'rb') as f:
#    myBytes=f.read()

arraysize=8
myBytes = bytes(range(0, arraysize))

rondom_list1 = []

for k in range(arraysize):
  x = random.random()
  rondom_list1.append(x)

data = {'myInt': 1, 'myLong': 2, 'myBool': True, 'myDouble': 3.14, 'myFloat': 0.01590000092983246, 'myBytes': myBytes , 'myFilename': 'shrimp1.png', 'myString': 'this is a 1st SimpleClass', 'myArray': rondom_list1}
writer.write(data,encoder)
data = {'myInt': 10, 'myLong': 3, 'myBool': True, 'myDouble': 2.71, 'myFloat': 0.01590000092983246, 'myBytes': myBytes , 'myFilename': 'shrimp2.png', 'myString': 'this is a 2nd SimpleClass', 'myArray': rondom_list1}
writer.write(data,encoder)
data = {'myInt': 32, 'myLong': 2502, 'myBool': False, 'myDouble': 0.01, 'myFloat': 31.443, 'myBytes': myBytes , 'myFilename': 'shrimp3.png', 'myString': '日本語', 'myArray': rondom_list1}
writer.write(data,encoder)

for i in range(1, 10, 1):
    myFilename='shrimp'+str(3+i)+'.png'
    data = {'myInt': i, 'myLong': i, 'myBool': True, 'myDouble': i*0.1, 'myFloat': i+0.1, 'myBytes': myBytes , 'myFilename': myFilename, 'myString': '日本語', 'myArray': rondom_list1}
    writer.write(data,encoder)

raw_bytes = bytes_writer.getvalue()
print(len(raw_bytes))
print(type(raw_bytes))

f = open('SimpleClass.avro', 'wb')
f.write(raw_bytes)
f.close()

