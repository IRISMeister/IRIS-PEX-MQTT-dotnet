import io,os
import avro.schema
import avro.io

schema = avro.schema.parse(open('SimpleClass.avsc', 'rb').read())

writer = avro.io.DatumWriter(schema)
bytes_writer = io.BytesIO()
encoder = avro.io.BinaryEncoder(bytes_writer)
with open('shrimp.png', 'rb') as f:
    myBytes=f.read()

#data = {'myInt': 1, 'myLong': 2, 'myBool': True, 'myDouble': 3.14, 'myFloat': 0.01590000092983246, 'myBytes': b'\x01\x02\x03\x04\x05\x06\x07\x08', 'myString': 'this is a 1st SimpleClass', 'myArray': [1,2,3,4,5,6,7,8], 'myMap': {'abc': '123'}}
#data = {'myInt': 1, 'myLong': 2, 'myBool': True, 'myDouble': 3.14, 'myFloat': 0.01590000092983246, 'myBytes': b'\x01\x02\x03\x04\x05\x06\x07\x08', 'myString': 'this is a 1st SimpleClass', 'myArray': [100,200,300,400,500,600,700,800]}
data = {'myInt': 1, 'myLong': 2, 'myBool': True, 'myDouble': 3.14, 'myFloat': 0.01590000092983246, 'myBytes': myBytes , 'myFilename': 'shrimp1.png', 'myString': 'this is a 1st SimpleClass', 'myArray': [100,200,300,400,500,600,700,800]}
writer.write(data,encoder)
data = {'myInt': 10, 'myLong': 3, 'myBool': True, 'myDouble': 2.71, 'myFloat': 0.01590000092983246, 'myBytes': myBytes , 'myFilename': 'shrimp2.png', 'myString': 'this is a 2nd SimpleClass', 'myArray': [900,1000,1100,1200,1300,1400,1500,1600]}
writer.write(data,encoder)
data = {'myInt': 32, 'myLong': 2502, 'myBool': False, 'myDouble': 0.01, 'myFloat': 31.443, 'myBytes': myBytes , 'myFilename': 'shrimp3.png', 'myString': '日本語', 'myArray': [10000,11000,11100,11200,11300,11400,11500,11600]}
writer.write(data,encoder)

for i in range(1, 10, 1):
    myFilename='shrimp'+str(3+i)+'.png'
    data = {'myInt': i, 'myLong': i, 'myBool': True, 'myDouble': i*0.1, 'myFloat': i+0.1, 'myBytes': myBytes , 'myFilename': myFilename, 'myString': '日本語', 'myArray': [10000+i,20000+i,30000+i,40000+i,50000+i,60000+i,70000+i,80000+i]}
    writer.write(data,encoder)

raw_bytes = bytes_writer.getvalue()
print(len(raw_bytes))
print(type(raw_bytes))

f = open('SimpleClass.avro', 'wb')
f.write(raw_bytes)
f.close()

