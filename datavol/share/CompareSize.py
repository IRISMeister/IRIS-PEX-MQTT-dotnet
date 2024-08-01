import io,os
import avro.schema
import avro.io
import json
import base64
import random

schema = avro.schema.parse(open('SimpleClass.avsc', 'rb').read())

writer = avro.io.DatumWriter(schema)
bytes_writer = io.BytesIO()
encoder = avro.io.BinaryEncoder(bytes_writer)

#with open('shrimp.png', 'rb') as f:
#    myBytes=f.read()

arraysize=100
myBytes = bytes(range(0, arraysize))

rondom_list1 = []

for k in range(arraysize):
  x = random.random()
  rondom_list1.append(x)

data = {'myInt': 1, 'myLong': 2, 'myBool': True, 'myDouble': 3.14, 'myFloat': 0.01590000092983246, 'myBytes': myBytes , 'myFilename': 'data.hex', 'myString': 'this is a 1st SimpleClass', 'myArray': rondom_list1}
writer.write(data,encoder)

raw_bytes = bytes_writer.getvalue()
print(len(raw_bytes))
print(type(raw_bytes))

f = open('compare.avro', 'wb')
f.write(raw_bytes)
f.close()

data['myBytes']=base64.b64encode(data['myBytes']).decode('ascii')
with open('compare.json', 'w') as f:
    json.dump(data,f)

